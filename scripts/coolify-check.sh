#!/usr/bin/env bash
# Verifica que los compose del kit cumplen el contrato Coolify del MVP Hefesto.
# - Punto 1: servicios sin profiles no exponen puertos, container_name, privileged,
#   cap_add, devices, host (network/pid/ipc), unconfined, ni binds fuera del repo o docker.sock.
# - Punto 2: no hay 'name:' a nivel raíz ni en volumes/networks declarados en el YAML.
# - Para apps supabase-pg: en el render aparecen DB_NAME y DB_SSLMODE pedidos.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

list_vars() {
    # Variables referenciadas como ${VAR} o $VAR en el compose, deduplicadas.
    grep -oE '\$\{?[A-Z][A-Z0-9_]*\}?' "$1" \
        | sed -E 's/^\$\{?//; s/\}?$//' \
        | sort -u
}

# Devuelve los nombres declarados como claves top-level dentro de un bloque (volumes:, networks:, services:).
block_has_name() {
    local key="$1" compose="$2"
    awk -v key="$key:" '
        $0 ~ "^"key { in_block=1; next }
        in_block && /^[a-zA-Z]/ { in_block=0 }
        in_block && /^[[:space:]]+name:/ { print FILENAME ":" NR ":" $0 }
    ' "$compose"
}

check_compose() {
    local label="$1"
    local compose="$2"
    local base_dir="$3"
    local app_type="$4"

    local tmp
    tmp="$(mktemp -d)"
    local rc=0

    # Generar .env ficticio a partir de las ${VAR} del compose y de la app.
    : > "$tmp/.env"
    local v
    for v in $(list_vars "$compose"); do
        case "$v" in
            PUBLIC_URL|*_HOST|*_URL)
                echo "$v=https://ejemplo.invalid" >> "$tmp/.env" ;;
            *)
                echo "$v=x1234567890abcdef" >> "$tmp/.env" ;;
        esac
    done
    case "$app_type" in
        supabase-pg)
            echo "DB_SSLMODE=disable" >> "$tmp/.env"
            echo "DB_NAME=mvp_prueba" >> "$tmp/.env"
            ;;
    esac

    # Renderizar el compose y dejarlo en disco para jq.
    local rendered="$tmp/rendered.json"
    if ! docker compose --project-directory "$base_dir" -f "$compose" \
            --env-file "$tmp/.env" config --format json > "$rendered" 2> "$tmp/err"; then
        echo "$label: falla al renderizar compose"
        cat "$tmp/err"
        rm -rf "$tmp"
        return 1
    fi

    # Servicios sin profiles: solo esos importan para los sandbox de Traefik.
    local svc
    while IFS= read -r svc; do
        [ -z "$svc" ] && continue

        local has_forbidden=0
        if [ "$(jq --arg s "$svc" '.services[$s].ports // [] | length' "$rendered")" != "0" ]; then
            echo "$label: $svc: expone 'ports' (prohibido por contrato 1)"; has_forbidden=1; fi
        if [ -n "$(jq -r --arg s "$svc" '.services[$s].container_name // ""' "$rendered")" ]; then
            echo "$label: $svc: define 'container_name' (prohibido)"; has_forbidden=1; fi
        if jq -e --arg s "$svc" '.services[$s] | has("privileged") or has("cap_add") or has("devices")' "$rendered" >/dev/null 2>&1; then
            echo "$label: $svc: usa privileged/cap_add/devices (prohibido)"; has_forbidden=1; fi
        if jq -e --arg s "$svc" '.services[$s].network_mode == "host"' "$rendered" >/dev/null 2>&1; then
            echo "$label: $svc: network_mode=host (prohibido)"; has_forbidden=1; fi
        if jq -e --arg s "$svc" '.services[$s].pid == "host" or .services[$s].ipc == "host"' "$rendered" >/dev/null 2>&1; then
            echo "$label: $svc: pid o ipc=host (prohibido)"; has_forbidden=1; fi
        if jq -e --arg s "$svc" '.services[$s].security_opt // [] | any(. == "unconfined")' "$rendered" >/dev/null 2>&1; then
            echo "$label: $svc: security_opt incluye 'unconfined' (prohibido)"; has_forbidden=1; fi

        # Binds prohibidos: docker.sock, o binds que NO estén dentro del repo_root.
        local bind
        while IFS= read -r bind; do
            [ -z "$bind" ] && continue
            # Binds dentro del repo se permiten (Docker los resuelve a absolutos).
            case "$bind" in
                "$repo_root"/*|"$repo_root") continue ;;
            esac
            case "$bind" in
                /*) ;; # sólo flagueamos los absolutos si están fuera del repo
                *) continue ;;
            esac
            case "$bind" in
                .docker.sock|*/.docker.sock|*.docker.sock|*/.docker/*)
                    echo "$label: $svc: bind a docker.sock: $bind (prohibido)"
                    has_forbidden=1
                    ;;
                *)
                    echo "$label: $svc: bind fuera del repo: $bind (prohibido)"
                    has_forbidden=1
                    ;;
            esac
        done < <(jq -r --arg s "$svc" '.services[$s].volumes // [] | map(select(type=="object" and .type == "bind") | .source) | .[]' "$rendered")

        if [ "$has_forbidden" -ne 0 ]; then rc=1; fi
    done < <(jq -r '.services | to_entries | map(select((.value.profiles // []) | length == 0)) | map(.key) | .[]' "$rendered")

    # Punto 2: 'name:' en raíz, en volumes o networks declarados en el YAML.
    if grep -E '^name:' "$compose" >/dev/null 2>&1; then
        echo "$label: define 'name:' a nivel raíz (prohibido por contrato 2)"
        rc=1
    fi
    if [ -n "$(block_has_name 'volumes' "$compose")" ]; then
        echo "$label: volúmenes declarados con 'name' fijo (prohibido)"
        block_has_name 'volumes' "$compose" | sed 's/^/  /'
        rc=1
    fi
    if [ -n "$(block_has_name 'networks' "$compose")" ]; then
        echo "$label: redes declaradas con 'name' fijo (prohibido)"
        block_has_name 'networks' "$compose" | sed 's/^/  /'
        rc=1
    fi

    # supabase-pg: DB_NAME y DB_SSLMODE deben verse en el render (variables de servicio o literales).
    case "$app_type" in
        supabase-pg)
            local rendered_text
            rendered_text="$(cat "$rendered")"
            if ! printf '%s\n' "$rendered_text" | grep -q 'mvp_prueba'; then
                echo "$label: supabase-pg: DB_NAME=mvp_prueba no aparece en el render"
                rc=1
            fi
            if ! printf '%s\n' "$rendered_text" | grep -q 'disable'; then
                echo "$label: supabase-pg: DB_SSLMODE=disable no aparece en el render"
                rc=1
            fi
            ;;
    esac

    rm -rf "$tmp"
    if [ "$rc" -eq 0 ]; then
        echo "$label: OK"
    fi
    return "$rc"
}

# Apps del kit:
check_compose "radar" "$repo_root/compose.yaml" "$repo_root" "supabase-pg"

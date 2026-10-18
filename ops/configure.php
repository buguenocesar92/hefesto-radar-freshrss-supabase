<?php
declare(strict_types=1);
// Only managed keys are refreshed. Preserve salt, users and unrelated native settings.
$host = getenv('HEFESTO_DB_HOST') ?: '';
$user = getenv('HEFESTO_DB_USER') ?: '';
$password = getenv('HEFESTO_DB_PASSWORD') ?: '';
$url = getenv('HEFESTO_PUBLIC_URL') ?: '';
$sslmode = getenv('HEFESTO_DB_SSLMODE') ?: (getenv('DB_SSLMODE') ?: 'verify-full');
$dbname = getenv('HEFESTO_DB_NAME') ?: (getenv('DB_NAME') ?: 'postgres');
if (!preg_match('/^[A-Za-z0-9_]{1,63}$/D', $dbname) || !in_array($sslmode, ['disable','allow','prefer','require','verify-ca','verify-full'], true)) {
    fwrite(STDERR, "DB_NAME o DB_SSLMODE invalidos\n"); exit(1);
}
if (!preg_match('/^[a-zA-Z0-9.-]+$/D', $host) || $password === '' || $user === '') {
    fwrite(STDERR, "Host o credenciales faltantes/invalidos\n"); exit(1);
}
if (!filter_var($url, FILTER_VALIDATE_URL) || !in_array(parse_url($url, PHP_URL_SCHEME), ['http', 'https'], true)) {
    fwrite(STDERR, "URL invalida\n"); exit(1);
}
if (getenv('HEFESTO_BOOTSTRAP') !== 'true' && parse_url($url, PHP_URL_SCHEME) !== 'https') {
    fwrite(STDERR, "Produccion requiere HTTPS\n"); exit(1);
}
$params = 'sslmode=' . $sslmode . ';connect_timeout=15';
if (in_array($sslmode, ['verify-ca', 'verify-full'], true)) {
    $params .= ';sslrootcert=/certs/ca.crt';
}
try {
    $pdo = new PDO('pgsql:host=' . $host . ';port=5432;dbname=' . $dbname . ';' . $params, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    if ($pdo->query('SELECT current_user')->fetchColumn() !== 'freshrss_app') {
        throw new RuntimeException('Rol incorrecto');
    }
} catch (Throwable $e) {
    fwrite(STDERR, "No se pudo validar PostgreSQL/TLS/rol. Revise host, CA y credenciales; no se muestran secretos.\n"); exit(1);
}
$path = '/var/www/FreshRSS/data/config.php';
$config = is_file($path) ? (require $path) : [];
if (!is_array($config)) { throw new RuntimeException('Config nativa invalida'); }
$config['db'] = ['type' => 'pgsql', 'host' => $host . ':5432', 'user' => $user, 'password' => $password,
    'base' => $dbname, 'prefix' => 'freshrss_', 'connection_uri_params' => $params, 'pdo_options' => []];
$config['base_url'] = rtrim($url, '/');
$config['title'] = 'Hefesto Radar';
$config['default_user'] = 'admin';
$config['auth_type'] = 'form';
$config['allow_anonymous'] = false;
$config['allow_anonymous_refresh'] = false;
$config['api_enabled'] = false;
$config['allow_robots'] = false;
$config['pubsubhubbub_enabled'] = false;
$config['disable_update'] = true;
$config['limits']['max_registrations'] = 1;
$target = is_file($path) ? $path : '/var/www/FreshRSS/data/config.custom.php';
$tmp = $target . '.tmp';
umask(0077);
if (file_put_contents($tmp, "<?php\nreturn " . var_export($config, true) . ";\n") === false) {
    throw new RuntimeException('No se pudo escribir configuracion');
}
chmod($tmp, 0640);
chgrp($tmp, 'www-data');
if (!rename($tmp, $target)) { throw new RuntimeException('No se pudo guardar configuracion'); }
// Initial custom config can contain old credentials; remove it after native install.
if ($target === $path && is_file(dirname($path) . '/config.custom.php')) {
    unlink(dirname($path) . '/config.custom.php');
}
echo "Configuracion PostgreSQL/TLS actualizada sin mostrar secretos.\n";

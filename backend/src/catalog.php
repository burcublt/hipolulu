<?php
declare(strict_types=1);
function reply(int $status, array $data): never {
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    exit;
}
function database(): PDO {
    if (!class_exists('PDO') || !in_array('mysql', PDO::getAvailableDrivers(), true)) {
        throw new RuntimeException('pdo_mysql_missing');
    }
    // Production configuration lives outside the public document root.
    $file = getenv('APP_CONFIG_FILE');
    $defaultFile = dirname(__DIR__) . '/config/production.php';
    if (!$file && !getenv('DB_HOST') && is_file($defaultFile)) {
        $file = $defaultFile;
    }
    if (!$file && !is_readable(getenv('DB_PASSWORD_FILE') ?: '/run/secrets/db_app')) {
        throw new RuntimeException('database_config_missing');
    }
    if ($file && !is_readable($file)) {
        throw new RuntimeException('database_config_unreadable');
    }
    $config = $file ? require $file : [];
    if (!is_array($config)) {
        throw new RuntimeException('Invalid database configuration');
    }
    $password = $config['password'] ?? trim((string)file_get_contents(getenv('DB_PASSWORD_FILE') ?: '/run/secrets/db_app'));
    $host = $config['host'] ?? getenv('DB_HOST') ?: 'localhost';
    $name = $config['database'] ?? getenv('DB_NAME') ?: 'hippolulu_dev';
    $user = $config['user'] ?? getenv('DB_USER') ?: 'hippolulu_api';
    return new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4",$user,$password,[
        PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES=>false,
    ]);
}
function rows(PDO $db, string $sql, array $parameters=[]): array {
    $statement=$db->prepare($sql);
    $statement->execute($parameters);
    $rows=$statement->fetchAll();
    foreach ($rows as &$row) {
        foreach (['image','audio','cover'] as $kind) {
            if (array_key_exists($kind.'_key', $row)) $row[$kind.'_url'] = mediaUrl($row[$kind.'_key']);
        }
        if (array_key_exists('locked',$row)) $row['locked']=(bool)$row['locked'];
        foreach (['sort_order','content_count','level_number','pair_count','preview_seconds','lives','piece_count','grid_rows','grid_columns'] as $key) {
            if (isset($row[$key])) $row[$key]=(int)$row[$key];
        }
    }
    return $rows;
}

function logCatalogFailure(Throwable $error): void {
    $reason = 'unexpected_error';
    $safeReasons = ['pdo_mysql_missing', 'database_config_missing', 'database_config_unreadable', 'Invalid database configuration'];
    if (in_array($error->getMessage(), $safeReasons, true)) {
        $reason = $error->getMessage();
    } elseif ($error instanceof PDOException) {
        $code = (int)($error->errorInfo[1] ?? 0);
        $reason = match ($code) {
            1045 => 'database_login_rejected',
            1044 => 'database_permission_denied',
            1049 => 'database_not_found',
            2002, 2003 => 'database_host_unreachable',
            1146 => 'database_table_missing',
            default => 'database_error_' . $code,
        };
    } elseif ($error instanceof ParseError) {
        $reason = 'php_config_syntax_error';
    }
    $line = gmdate('c') . ' ' . $reason . PHP_EOL;
    // Fixed sanitized categories only: never log exception messages or credentials.
    $directory = dirname(__DIR__) . '/logs';
    if ((is_dir($directory) || @mkdir($directory, 0700, true)) && is_writable($directory)) {
        @file_put_contents($directory . '/api-error.log', $line, FILE_APPEND | LOCK_EX);
    }
    error_log(trim($line));
}

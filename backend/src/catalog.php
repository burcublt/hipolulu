<?php
declare(strict_types=1);
function reply(int $status, array $data): never {
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    exit;
}
function database(): PDO {
    // Production configuration lives outside the public document root.
    $file = getenv('APP_CONFIG_FILE');
    $config = $file ? require $file : [];
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
        if (array_key_exists('locked',$row)) $row['locked']=(bool)$row['locked'];
        foreach (['sort_order','content_count','level_number','pair_count','preview_seconds','lives','piece_count','grid_rows','grid_columns'] as $key) {
            if (isset($row[$key])) $row[$key]=(int)$row[$key];
        }
    }
    return $rows;
}

<?php
declare(strict_types=1);

function mediaUrl(?string $key): ?string {
    if ($key === null) return null;
    $base = rtrim(getenv('API_BASE_URL') ?: 'https://hippolulu-api.bodrumdublin.com', '/');
    return $base . '/v1/media?key=' . rawurlencode($key);
}

function serveMedia(PDO $db): never {
    $key = $_GET['key'] ?? null;
    if (!is_string($key) || strlen($key) > 400 || !str_starts_with($key, 'assets/') || str_contains($key, '..') || str_contains($key, '\\') || str_contains($key, "\0")) {
        reply(400, ['error' => 'invalid_media_key']);
    }
    $result = rows($db, 'SELECT id,storage_key FROM media WHERE storage_key=?', [$key]);
    if (!$result) reply(404, ['error' => 'media_not_found']);
    $id = $result[0]['id'];
    // Covers advertise published themes. Game content requires a free published
    // parent until store-verified entitlement support is implemented.
    $allowed = rows($db, "SELECT 1 allowed FROM themes t JOIN games g ON g.id=t.game_id
        WHERE t.cover_media_id=? AND t.status='published' AND g.status='published'
        UNION ALL SELECT 1 FROM contents c JOIN themes t ON t.game_id=c.game_id AND t.id=c.theme_id
        JOIN games g ON g.id=c.game_id LEFT JOIN content_audio ca ON ca.content_id=c.id
        WHERE (c.image_id=? OR ca.media_id=?) AND c.status='published'
        AND t.status='published' AND g.status='published' AND t.locked=0 AND g.locked=0
        UNION ALL SELECT 1 FROM matching_levels WHERE completion_image_id=? LIMIT 1", [$id,$id,$id,$id]);
    if (!$allowed) reply(403, ['error' => 'media_access_denied']);
    $root = realpath(getenv('MEDIA_STORAGE_ROOT') ?: dirname(__DIR__) . '/storage');
    $file = $root ? realpath($root . '/' . $key) : false;
    if (!$file || !str_starts_with($file, $root . DIRECTORY_SEPARATOR) || !is_file($file) || !is_readable($file)) {
        reply(404, ['error' => 'media_file_missing']);
    }
    $mime = match (strtolower(pathinfo($file, PATHINFO_EXTENSION))) {
        'webp' => 'image/webp', 'png' => 'image/png', 'jpg','jpeg' => 'image/jpeg',
        'mp3' => 'audio/mpeg', default => null,
    };
    if (!$mime) reply(415, ['error' => 'unsupported_media_type']);
    $size = filesize($file);
    $start=0; $end=$size-1;
    $range=$_SERVER['HTTP_RANGE'] ?? null;
    if ($range !== null) {
        if (!preg_match('/^bytes=(\d*)-(\d*)$/D', $range, $m) || ($m[1]==='' && $m[2]==='')) {
            header("Content-Range: bytes */$size"); reply(416,['error'=>'invalid_range']);
        }
        if ($m[1]==='') $start=max(0,$size-(int)$m[2]);
        else { $start=(int)$m[1]; if($m[2]!=='') $end=min($end,(int)$m[2]); }
        if ($start>$end || $start>=$size) {
            header("Content-Range: bytes */$size"); reply(416,['error'=>'invalid_range']);
        }
    }
    $stream=fopen($file,'rb');
    if ($stream===false) reply(404,['error'=>'media_file_missing']);
    if ($range!==null) {http_response_code(206);header("Content-Range: bytes $start-$end/$size");}
    header('Content-Type: '.$mime);
    header('Accept-Ranges: bytes');
    header('Content-Length: '.($end-$start+1));
    header('Cache-Control: private, no-store');
    fseek($stream,$start);
    $remaining=$end-$start+1;
    while ($remaining>0 && !feof($stream)) {
        $buffer=fread($stream,min(65536,$remaining));
        if ($buffer===false || $buffer==='') break;
        echo $buffer; $remaining-=strlen($buffer);
    }
    fclose($stream);exit;
}

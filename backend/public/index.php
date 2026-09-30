<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/catalog.php';
require dirname(__DIR__) . '/src/media.php';
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');
try {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        header('Allow: GET');
        reply(405, ['error' => 'method_not_allowed']);
    }
    $locale = $_GET['locale'] ?? 'en';
    if (!is_string($locale) || !in_array($locale, ['en', 'tr', 'es'], true)) {
        reply(400, ['error' => 'unsupported_locale']);
    }
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $db = database();
    if ($path === '/v1/media') serveMedia($db);
    if ($path === '/v1/health') {
        $db->query('SELECT 1');
        reply(200, ['status' => 'ok']);
    }
    if ($path === '/v1/games') {
        reply(200, ['data' => rows($db,
            "SELECT g.id,g.sort_order,g.locked,COALESCE(t.title,e.title,g.id) title FROM games g
             LEFT JOIN game_translations t ON t.game_id=g.id AND t.locale=?
             LEFT JOIN game_translations e ON e.game_id=g.id AND e.locale='en'
             WHERE g.status='published' ORDER BY g.sort_order,g.id", [$locale])]);
    }
    if (preg_match('#^/v1/games/(puzzle|matching)/themes$#', $path, $m)) {
        reply(200, ['data' => rows($db,
            "SELECT t.id,t.game_id,t.sort_order,t.locked,COALESCE(l.title,e.title,t.id) title,
             m.storage_key cover_key,(SELECT COUNT(*) FROM contents c WHERE c.game_id=t.game_id AND c.theme_id=t.id AND c.status='published') content_count
             FROM themes t JOIN games g ON g.id=t.game_id
             LEFT JOIN theme_translations l ON l.game_id=t.game_id AND l.theme_id=t.id AND l.locale=?
             LEFT JOIN theme_translations e ON e.game_id=t.game_id AND e.theme_id=t.id AND e.locale='en'
             LEFT JOIN media m ON m.id=t.cover_media_id
             WHERE t.game_id=? AND t.status='published' AND g.status='published' ORDER BY t.sort_order,t.id", [$locale,$m[1]])]);
    }
    if (preg_match('#^/v1/games/(puzzle|matching)/themes/([a-z0-9_-]+)/contents$#', $path, $m)) {
        $theme=rows($db,"SELECT t.locked FROM themes t JOIN games g ON g.id=t.game_id WHERE t.game_id=? AND t.id=? AND t.status='published' AND g.status='published'",[$m[1],$m[2]]);
        if (!$theme) reply(404,['error'=>'theme_not_found']);
        // No request parameter may grant entitlement. Verified store access comes later.
        if ($theme[0]['locked']) reply(403,['error'=>'subscription_required']);
        reply(200,['data'=>rows($db,
            "SELECT c.slug,c.sort_order,COALESCE(t.title,e.title,c.slug) title,i.storage_key image_key,a.storage_key audio_key
             FROM contents c JOIN media i ON i.id=c.image_id
             LEFT JOIN content_translations t ON t.content_id=c.id AND t.locale=?
             LEFT JOIN content_translations e ON e.content_id=c.id AND e.locale='en'
             LEFT JOIN content_audio ca ON ca.content_id=c.id AND ca.locale=?
             LEFT JOIN media a ON a.id=ca.media_id
             WHERE c.game_id=? AND c.theme_id=? AND c.status='published' ORDER BY c.sort_order,c.slug",[$locale,$locale,$m[1],$m[2]])]);
    }
    if ($path === '/v1/games/matching/levels') {
        reply(200,['data'=>rows($db,'SELECT level_number,pair_count,preview_seconds,lives FROM matching_levels ORDER BY level_number')]);
    }
    if ($path === '/v1/games/puzzle/settings') {
        reply(200,['data'=>['default_piece_count'=>(int)$db->query("SELECT default_piece_count FROM puzzle_settings WHERE game_id='puzzle'")->fetchColumn(),
            'variants'=>rows($db,'SELECT piece_count,grid_rows,grid_columns FROM puzzle_variants ORDER BY piece_count')]]);
    }
    reply(404,['error'=>'not_found']);
} catch (Throwable $e) {
    // Do not expose credentials, SQL or filesystem paths in HTTP responses.
    logCatalogFailure($e);
    reply(503,['error'=>'service_unavailable']);
}

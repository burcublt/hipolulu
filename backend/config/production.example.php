<?php
declare(strict_types=1);

// Upload as config/production.php and fill in the cPanel database credentials.
// Use full database/user names shown in cPanel, including any account prefix.
return [
    'host' => 'localhost',
    'database' => 'CPANEL_DATABASE_NAME',
    'user' => 'CPANEL_DATABASE_USER',
    'password' => 'CPANEL_DATABASE_PASSWORD',
];

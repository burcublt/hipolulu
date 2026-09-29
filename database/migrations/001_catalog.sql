CREATE TABLE games (
 id VARCHAR(32) PRIMARY KEY,
 sort_order INT NOT NULL,
 locked BOOLEAN NOT NULL DEFAULT FALSE,
 status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft'
) ENGINE=InnoDB;
CREATE TABLE locales (code VARCHAR(8) PRIMARY KEY) ENGINE=InnoDB;
CREATE TABLE media (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 storage_key VARCHAR(400) COLLATE utf8mb4_bin NOT NULL UNIQUE,
 kind ENUM('image','audio') NOT NULL,
 sha256 CHAR(64) NOT NULL,
 byte_size BIGINT UNSIGNED NOT NULL
) ENGINE=InnoDB;
CREATE TABLE themes (
 game_id VARCHAR(32) NOT NULL,
 id VARCHAR(64) NOT NULL,
 sort_order INT NOT NULL,
 locked BOOLEAN NOT NULL DEFAULT TRUE,
 status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
 PRIMARY KEY(game_id,id),
 FOREIGN KEY(game_id) REFERENCES games(id),
 INDEX catalog_order(game_id,status,sort_order)
) ENGINE=InnoDB;
CREATE TABLE theme_translations (
 game_id VARCHAR(32) NOT NULL,
 theme_id VARCHAR(64) NOT NULL,
 locale VARCHAR(8) NOT NULL,
 title VARCHAR(200) NOT NULL,
 PRIMARY KEY(game_id,theme_id,locale),
 FOREIGN KEY(game_id,theme_id) REFERENCES themes(game_id,id),
 FOREIGN KEY(locale) REFERENCES locales(code)
) ENGINE=InnoDB;
CREATE TABLE contents (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 game_id VARCHAR(32) NOT NULL,
 theme_id VARCHAR(64) NOT NULL,
 slug VARCHAR(120) COLLATE utf8mb4_bin NOT NULL,
 image_id BIGINT UNSIGNED NOT NULL,
 sort_order INT NOT NULL,
 status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
 UNIQUE KEY content_identity(game_id,theme_id,slug),
 FOREIGN KEY(game_id,theme_id) REFERENCES themes(game_id,id),
 FOREIGN KEY(image_id) REFERENCES media(id)
) ENGINE=InnoDB;
CREATE TABLE content_translations (
 content_id BIGINT UNSIGNED NOT NULL,
 locale VARCHAR(8) NOT NULL,
 title VARCHAR(200) NOT NULL,
 PRIMARY KEY(content_id,locale),
 FOREIGN KEY(content_id) REFERENCES contents(id),
 FOREIGN KEY(locale) REFERENCES locales(code)
) ENGINE=InnoDB;
CREATE TABLE content_audio (
 content_id BIGINT UNSIGNED NOT NULL,
 locale VARCHAR(8) NOT NULL,
 media_id BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY(content_id,locale),
 FOREIGN KEY(content_id) REFERENCES contents(id),
 FOREIGN KEY(locale) REFERENCES locales(code),
 FOREIGN KEY(media_id) REFERENCES media(id)
) ENGINE=InnoDB;
CREATE TABLE matching_levels (
 level_number INT PRIMARY KEY,
 pair_count INT NOT NULL,
 preview_seconds INT NOT NULL,
 lives INT NOT NULL DEFAULT 5,
 completion_image_id BIGINT UNSIGNED NOT NULL,
 FOREIGN KEY(completion_image_id) REFERENCES media(id)
) ENGINE=InnoDB;
CREATE TABLE puzzle_settings (
 game_id VARCHAR(32) PRIMARY KEY,
 default_piece_count INT NOT NULL,
 FOREIGN KEY(game_id) REFERENCES games(id)
) ENGINE=InnoDB;

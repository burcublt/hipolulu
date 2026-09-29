ALTER TABLE themes ADD cover_media_id BIGINT UNSIGNED NULL,
 ADD CONSTRAINT theme_cover_fk FOREIGN KEY(cover_media_id) REFERENCES media(id);
CREATE TABLE game_translations (
 game_id VARCHAR(32) NOT NULL,
 locale VARCHAR(8) NOT NULL,
 title VARCHAR(200) NOT NULL,
 PRIMARY KEY(game_id,locale),
 FOREIGN KEY(game_id) REFERENCES games(id),
 FOREIGN KEY(locale) REFERENCES locales(code)
) ENGINE=InnoDB;
CREATE TABLE puzzle_variants (
 piece_count INT PRIMARY KEY,
 grid_rows INT NOT NULL,
 grid_columns INT NOT NULL
) ENGINE=InnoDB;

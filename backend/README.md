# HippoLulu katalog API — PHP 8.2 / MariaDB 10.11

## Yerel çalıştırma

Docker Desktop açık olmalı. Proje kökünde:

```sh
python3 database/scripts/mariadb_local.py setup
python3 database/scripts/mariadb_local.py verify
python3 backend/tests/catalog_test.py
docker compose stop
# Tekrar başlatmak için:
docker compose start
```

API: http://127.0.0.1:8088/v1/health
Veritabanı DataGrip için yalnızca 127.0.0.1:3307 üzerinden açılır. API de yalnızca localhost'a bağlanır.
Eski yerel MySQL instance ve `.local/database` yedeği korunur. MariaDB named volume `hippolulu-local_maria_data` içindedir; `docker compose down -v` veri siler, rutin kullanımda çalıştırmayın.

Compose MariaDB 10.11 serisini kullanır. Kurulumda çözümlenen sürüm 10.11.19; GoDaddy 10.11.18. Aynı seriyle şema test edilmiştir, hosting'e dağıtım sonrası da kontrol gerekir.

## GET uçları

- `/v1/health`
- `/v1/games?locale=tr`
- `/v1/games/puzzle/themes?locale=tr`
- `/v1/games/matching/themes?locale=tr`
- `/v1/games/puzzle/themes/animals/contents?locale=tr`
- `/v1/games/matching/themes/animals/contents?locale=tr`
- `/v1/games/matching/levels`
- `/v1/games/puzzle/settings`

Dil `en`, `tr`, `es`; varsayılan `en`. Başlık eksikse İngilizce, o da eksikse sabit kimlik/slug döner. Ses eksikse null; başka dilde ses otomatik oynatılmaz.

Yalnızca published oyun/tema/içerik sunulur. Metadata'daki locked boolean açıkça döner. Kilitli tema içeriği 403 verir; query parametresiyle abonelik hakkı alınamaz. Mağaza doğrulaması gelene kadar kilitli içeriğe API erişimi yoktur. Dosya yolları `image_key`, `audio_key`, `cover_key` olarak göreli; indirme adresleri `image_url`, `audio_url`, `cover_url` olarak döner. `/v1/media?key=assets/...` kayıtlı ve erişime açık dosyaları sunar; HTTP byte range desteklenir. Dosyalar public dışında `storage/assets` altında tutulur. Yayındaki tema kapakları, ücretsiz yayınlanmış içerikler ve seviye tamamlama görselleri sunulur; taslak ve kilitli içerik dosyaları engellenir. Aynı dosya ücretsiz bir içerikte de kullanılıyorsa erişilebilir.

API kullanıcısı yalnızca SELECT yetkilidir. Hatalarda SQL/şifre veya sunucu dosya yolu HTTP'ye yazılmaz. PDO prepared statement kullanılır. Yönetim paneli, yazma uçları, abonelik doğrulama ve Flutter entegrasyonu henüz eklenmedi.

## GoDaddy dağıtım hazırlığı

Alan adının document root'u `backend/public` olmalı; `src`, yapılandırma ve şifre dosyaları public dışında kalmalı. Apache için public/.htaccess eklendi. PHP 8.2 ve pdo_mysql gerekir.

`APP_CONFIG_FILE` public dışındaki bir PHP config dosyasının mutlak yolunu gösterir. Dosya `host`, `database`, `user`, `password` anahtarlarını içeren bir array döndürür. Gerçek değerleri Git'e koymayın. cPanel'de ayrı katalog kullanıcısına SELECT verin; migration için ayrı yetkili kullanıcı kullanın. Docker geliştirme sunucusu üretimde kullanılmaz.

API şimdilik bütün veriyi küçük mevcut katalog için döndürür; katalog büyümeden sayfalama/cache/rate limiting eklenmelidir.

## DataGrip

`python3 database/scripts/datagrip_setup.py` yerel verileri düzenlemek için ayrı kullanıcıyı oluşturur.
MariaDB data source: host `127.0.0.1`, port `3307`, database `hippolulu_dev`, user `hippolulu_datagrip`.
Şifre `.local/mariadb/datagrip_password` dosyasındadır (Git dışında). Socket/SSH tunnel gerekmez.
Docker Desktop ve compose servisleri açık olmalıdır. DataGrip kullanıcısının yetkileri yalnızca hippolulu_dev veritabanında SELECT, INSERT, UPDATE, DELETE ve SHOW VIEW şeklindedir. API kullanıcısı salt okunur kalır; tablo şeması değiştirme yetkisi verilmez.

## Medya paketlerini yükleme

`python3 database/scripts/package_media.py` yerel MariaDB kayıtlarını dosya boyutu ve SHA-256 ile doğrular ve `build/deploy` altında iki ZIP üretir.

1. `hippolulu-storage.zip` ve `hippolulu-media-api.zip` dosyalarını cPanel'deki `hippolulu/` klasörüne yükleyin ve aynı klasöre çıkartın. API dosyalarını değiştirmeden önce mevcut sürümün yedeğini alın.
2. Sonuç `hippolulu/storage/assets/...`, `hippolulu/public/index.php` ve `hippolulu/src/media.php` olmalıdır. `config/production.php` pakette yoktur; mevcut ayarlar korunur.
3. Yeniden SQL aktarımı gerekmez. Veritabanındaki göreli storage_key alanları değişmez.
4. `/v1/games/matching/themes/animals/contents?locale=tr` yanıtındaki image_url ve audio_url adreslerini açarak kontrol edin.

Canlı URL varsayılanı `https://hippolulu-api.bodrumdublin.com`; başka ortamda `API_BASE_URL` ile değiştirilebilir. `MEDIA_STORAGE_ROOT` varsayılanı backend kökündeki storage klasörüdür. Docker bunu /media olarak ayarlar. DB_HOST ortam değişkeni verilirse otomatik production.php yüklenmez; açık APP_CONFIG_FILE her zaman önceliklidir.

## 2 Ekim katalog güncellemesi

Yerel katalog: 115 içerik, 345 içerik çevirisi (tr/en/es), 198 medya dosyası.
`database/scripts/build_catalog_update.py` dosya envanterinden ek seed üretir; önceden uygulanmış seed dosyalarını yeniden üretmeyin. Yeni değişikliklerde yeni numaralı seed kullanın.
`database/scripts/export_catalog.py` iki çıktı üretir:
- `build/deploy/hippolulu-catalog-update.sql`: Mevcut 001–003 kurulumu üzerine uygulanır; kayıtları silmez. Önce canlı veritabanını dışa aktararak yedekleyin.
- `build/deploy/hippolulu-catalog-full.sql`: Yalnızca boş veritabanına aktarılacak tam kopya. Mevcut dolu veritabanına uygulanmaz.

Canlı güncelleme sırası: storage ZIP yükle/çıkar, mevcut veritabanında update SQL içe aktar, API kontrolü. SQL dosyalarını public klasörüne yüklemeyin.
Tüm sesler envanterdedir; alternatif `_2` kayıtları, görseli olmayan panda/crocodile ve yanlış klasördeki `vegetables/en/avacado.mp3` otomatik eşleştirilmez. Bu sesin içeriği dinlenerek doğrulanmalıdır. Türkçe/İspanyolca ses dosyaları bulunmayan içeriklerde audio_url null kalır; metin çevirisi ses üretmez.
Flutter hâlâ yerel asset kullanır; API entegrasyonu ayrı sonraki adımdır. Yeni puzzle klasörleri pubspec.yaml'a eklenmiştir.

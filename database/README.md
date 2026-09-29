# HippoLulu yerel içerik veritabanı

## Kurulum ve kullanım

Mevcut Homebrew MySQL 9.6 kullanılır. Global MySQL servisine veya diğer uygulamaların verilerine dokunulmaz. Veri dizini `.local/database/data`; TCP kapalı, yalnızca yerel Unix socket açıktır.

```sh
python3 database/scripts/local_db.py setup
python3 database/scripts/local_db.py verify
python3 database/scripts/local_db.py shell
python3 database/scripts/local_db.py backup
python3 database/scripts/local_db.py stop
python3 database/scripts/local_db.py start
```

Veritabanı: `hippolulu_dev`. Socket: `/tmp/hippolulu-dev-mysql.sock`.
Yönetici bağlantısı `.local/database/admin.cnf`; backend için sınırlı DML yetkili kullanıcı `.local/database/app.cnf`. Şifreler rastgele üretilir, dosyalar yalnızca kullanıcı tarafından okunabilir ve Git dışında tutulur. Flutter bu dosyaları kullanmaz; ileride API'ye bağlanır.

## Model

- `games`, `themes`: sabit mevcut kimlikler, sıralama, bağımsız `locked`, draft/published/archived.
- `game_translations`, `theme_translations`, `content_translations`: locale başına metin. Eksik çeviri uydurulmaz; panelde tamamlanacak.
- `media`: dosya yolu, SHA256, byte boyutu, image/audio türü. Dosya binary verisi DB'de değil.
- `contents`: tema içindeki görseller. İçerik kimliği oyun+tema+slug ile korunur.
- `content_audio`: içerik ve dil başına mevcut birebir isimli ses dosyası.
- `matching_levels`: mevcut altı seviyenin çift sayısı, gösterim süresi, canı ve bitiş görseli.
- `puzzle_settings`, `puzzle_variants`: varsayılan 12 parça; mevcut 6/8/12 gridleri.
- `schema_migrations`: uygulanan dosyalar ve hashleri.

İlk dört tema `locked=false` olarak açıkça kaydedilir; sıralama değişikliği erişim durumunu değiştirmez. İçeriği boş temalar draft olur, metadata korunur. Gerçek içerik sayısı `contents` üzerinden hesaplanır; UI'daki sabit adetler aktarılmaz. Kullanıcının oyun ilerlemesi içerik tablosuna yazılmaz.

`import_notes.txt` eksik ses/çeviri ve boş temaları listeler. Mevcut dosyalardan gelen isimler korunur; yazım hataları ve alternatif sesler otomatik birleştirilmez. Katalog API'si için yayın doğrulaması (örneğin matching seviyesinde yeterli çift olması) backend aşamasında eklenecek.

## Migration ve ilk aktarım

`setup` migration ve seed dosyalarını bir kez uygular, tekrar çalıştırma veri çoğaltmaz. Uygulanmış SQL'i değiştirmek yerine yeni numaralı dosya ekleyin. MySQL DDL otomatik commit yapar; başarısız DDL varsa yeniden denemeden önce durumu inceleyin. Seed dosyaları transaction içinde çalışır.

`build_seed.py` ilk katalog ihracını yeniden üretir; uygulanmış seed'i sonradan değiştirmek için kullanılmamalı. Canlı içerik düzenlemeleri yönetim paneli üzerinden yapılacak.

## Sunucuya taşıma

GoDaddy paketinin MySQL/MariaDB sürümü ve backend desteği henüz bilinmiyor. Yerelde 9.6 ile çalışması hedef sunucuyla uyumluluk garantisi değildir. SQL genel InnoDB/utf8mb4 yapılarını kullanır; hedef sürüm öğrenildiğinde aynı sürümde test edilmeli.

İlk dağıtımda migration+seed veya boş DB'ye yedek geri yükleme yollarından biri seçilir; ikisi üst üste uygulanmaz. Yerel kullanıcı hesapları sunucuya taşınmaz. GoDaddy'de ayrı DB/kullanıcı açılır; hosting izinleri nedeniyle CREATE DATABASE/USER içeren yerel kurulum scripti sunucuda çalıştırılmaz.

Media dosyaları da ayrıca yüklenir. Storage key göreli kalır; alan adı API yapılandırmasından gelir. Yedekler `.local/database/` içinde tutulur. Sunucuya ilk aktarım sonrasında canlı DB'yi local dump ile ezmeyin.

Bu aşama yalnızca içerik veritabanıdır. Flutter henüz DB/API kullanmaz. Backend, yönetim paneli, mağaza transaction doğrulaması ve abonelik tabloları sonraki aşamadır; ebeveyn sorusu abonelik hakkı vermez.

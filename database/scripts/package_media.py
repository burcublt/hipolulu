"""Package only DB-registered media, validate hashes, preserve private storage layout."""
import hashlib,json,subprocess,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
r=subprocess.run(['docker','compose','-f',str(ROOT/'compose.yaml'),'exec','-T','db','mariadb','--defaults-file=/run/admin.cnf','--batch','--skip-column-names','hippolulu_dev','-e','SELECT storage_key,sha256,byte_size FROM media ORDER BY storage_key'],capture_output=True,text=True,check=True)
files=[]
for line in r.stdout.splitlines():
 key,digest,size=line.split('\t');p=(ROOT/key).resolve()
 assert p.is_relative_to(ROOT/'assets') and p.is_file(),key
 assert p.stat().st_size==int(size) and hashlib.sha256(p.read_bytes()).hexdigest()==digest,key
 files.append((key,p))
out=ROOT/'build/deploy';out.mkdir(parents=True,exist_ok=True)
archive=out/'hippolulu-storage.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for key,p in files:z.write(p,'storage/'+key)
with zipfile.ZipFile(archive) as z:assert z.testzip() is None and len(z.namelist())==len(files)
with zipfile.ZipFile(out/'hippolulu-media-api.zip','w',zipfile.ZIP_DEFLATED) as z:
 for name in ['public/index.php','public/.htaccess','src/catalog.php','src/media.php']:z.write(ROOT/'backend'/name,name)
print(f'{len(files)} files, {archive.stat().st_size/1024/1024:.1f} MB. Both ZIPs extract into hippolulu/. No credentials or SQL included.')

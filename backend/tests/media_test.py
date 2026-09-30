import json,hashlib,urllib.request,urllib.error,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];BASE='http://127.0.0.1:8088'
def get(url,code=200,headers=None):
 try:
  with urllib.request.urlopen(urllib.request.Request(url,headers=headers or {})) as r:status,data,h=r.status,r.read(),r.headers
 except urllib.error.HTTPError as e:status,data,h=e.code,e.read(),e.headers
 assert status==code,(status,code,data[:100]);return data,h
items=json.loads(get(BASE+'/v1/games/matching/themes/animals/contents?locale=en')[0])['data']
for field in ['image','audio']:
 item=next(i for i in items if i[field+'_url'])
 content,h=get(item[field+'_url']);assert content==(ROOT/item[field+'_key']).read_bytes()
 partial,h=get(item[field+'_url'],206,{'Range':'bytes=0-15'});assert partial==content[:16]
 get(item[field+'_url'],416,{'Range':'bytes=999999999-'})
get(BASE+'/v1/media?key=../../config/production.php',400)
get(BASE+'/v1/media?key=assets/missing.webp',404)
# Draft theme cover is registered but must not be publicly readable.
r=subprocess.run(['docker','compose','exec','-T','db','mariadb','--defaults-file=/run/admin.cnf','-N','-B','hippolulu_dev','-e',"SELECT m.storage_key FROM themes t JOIN media m ON m.id=t.cover_media_id WHERE t.status='draft' LIMIT 1"],capture_output=True,text=True,check=True)
from urllib.parse import quote
get(BASE+'/v1/media?key='+quote(r.stdout.strip(),safe=''),403)
print('PASS: image/audio bytes match sources; ranges; invalid paths; missing and draft media denied.')

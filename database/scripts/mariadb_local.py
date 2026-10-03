"""Compose setup and repeatable migration; preserves the original MySQL instance."""
import argparse,hashlib,secrets,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
LOCAL=ROOT/'.local/mariadb'
def compose(*args,**kwargs):
 return subprocess.run(['docker','compose','-f',str(ROOT/'compose.yaml'),*args],check=True,**kwargs)
def sql(text):
 return compose('exec','-T','db','mariadb','--defaults-file=/run/admin.cnf','--batch','--skip-column-names','hippolulu_dev',input=text,text=True,capture_output=True).stdout
parser=argparse.ArgumentParser();parser.add_argument('action',choices=['setup','verify']);a=parser.parse_args()
if a.action=='setup':
 LOCAL.mkdir(parents=True,exist_ok=True);LOCAL.chmod(0o700)
 for name in ['root','app']:
  p=LOCAL/f'{name}_password'
  if not p.exists():p.write_text(secrets.token_hex(24));p.chmod(0o600)
 p=LOCAL/'admin.cnf';p.write_text('[client]\nuser=root\npassword='+ (LOCAL/'root_password').read_text()+'\n');p.chmod(0o600)
 compose('up','-d','--build','--wait')
 sql('CREATE TABLE IF NOT EXISTS schema_migrations (name VARCHAR(180) PRIMARY KEY, sha256 CHAR(64) NOT NULL, applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);')
 for folder in ['migrations','seeds']:
  for p in sorted((ROOT/'database'/folder).glob('*.sql')):
   name=folder+'/'+p.name;digest=hashlib.sha256(p.read_bytes()).hexdigest()
   old=sql(f"SELECT sha256 FROM schema_migrations WHERE name='{name}';").strip()
   if old:
    if old!=digest:raise RuntimeError(f'Applied migration changed: {name}')
    continue
   sql(('START TRANSACTION;\n' if folder=='seeds' else '')+p.read_text()+f"\nINSERT INTO schema_migrations(name,sha256) VALUES ('{name}','{digest}');"+('COMMIT;' if folder=='seeds' else ''))
   print('Applied',name)
 sql("REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hippolulu_api'@'%'; GRANT SELECT ON hippolulu_dev.* TO 'hippolulu_api'@'%';")
print(sql('SELECT VERSION(); SELECT game_id,COUNT(*),SUM(locked=0) FROM themes GROUP BY game_id; SELECT COUNT(*) FROM contents;'))
assert int(sql('SELECT COUNT(*) FROM contents;').strip())>=74
assert sql('SELECT COUNT(*) FROM themes WHERE locked=0;').strip()=='8'
print('MariaDB catalog verified.')

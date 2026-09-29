"""Isolated local MySQL; no global services/configs modified."""
import argparse,hashlib,json,os,secrets,shutil,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
LOCAL=ROOT/'.local/database'; DATA=LOCAL/'data'; SOCKET='/tmp/hippolulu-dev-mysql.sock'
LOCAL.mkdir(parents=True,exist_ok=True);LOCAL.chmod(0o700)
MYSQL=shutil.which('mysql');SERVER=shutil.which('mysqld');ADMIN=shutil.which('mysqladmin')
CFG=LOCAL/'admin.cnf'
def run(args,**kw): return subprocess.run(args,check=True,**kw)
def sql(text):
 return run([MYSQL,f'--defaults-file={CFG}','--batch','--skip-column-names'],input=text,text=True,capture_output=True).stdout

def start():
 if CFG.exists():
  probe=subprocess.run([ADMIN,f'--defaults-file={CFG}','ping'],capture_output=True)
  if probe.returncode==0: return
 if not (DATA/'mysql').exists():
  run([SERVER,'--no-defaults','--initialize-insecure',f'--datadir={DATA}',f'--log-error={LOCAL}/mysql.log'])
 run([SERVER,'--no-defaults',f'--datadir={DATA}',f'--socket={SOCKET}','--skip-networking','--mysqlx=0',f'--pid-file={LOCAL}/mysql.pid',f'--log-error={LOCAL}/mysql.log','--daemonize'])
 if not CFG.exists():
  password=secrets.token_hex(24)
  # Write recovery credentials before changing root; never echo secrets.
  CFG.write_text(f'[client]\nuser=root\npassword={password}\nsocket={SOCKET}\n');CFG.chmod(0o600)
  run([MYSQL,'--no-defaults','-uroot',f'--socket={SOCKET}'],input=f"ALTER USER 'root'@'localhost' IDENTIFIED BY '{password}';",text=True,capture_output=True)
 sql("CREATE DATABASE IF NOT EXISTS hippolulu_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
 if not (LOCAL/'app.cnf').exists():
  password=secrets.token_hex(24)
  sql(f"CREATE USER 'hippolulu_app'@'localhost' IDENTIFIED BY '{password}'; GRANT SELECT,INSERT,UPDATE,DELETE ON hippolulu_dev.* TO 'hippolulu_app'@'localhost';")
  p=LOCAL/'app.cnf';p.write_text(f'[client]\nuser=hippolulu_app\npassword={password}\nsocket={SOCKET}\ndatabase=hippolulu_dev\n');p.chmod(0o600)

def migrate():
 sql('USE hippolulu_dev; CREATE TABLE IF NOT EXISTS schema_migrations (name VARCHAR(180) PRIMARY KEY, sha256 CHAR(64) NOT NULL, applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);')
 for folder in ['migrations','seeds']:
  for p in sorted((ROOT/'database'/folder).glob('*.sql')):
   name=folder+'/'+p.name; digest=hashlib.sha256(p.read_bytes()).hexdigest()
   old=sql(f"USE hippolulu_dev; SELECT sha256 FROM schema_migrations WHERE name='{name}';").strip()
   if old:
    if old!=digest: raise RuntimeError(f'Applied file changed: {name}; add a new migration instead.')
    continue
   # DDL auto-commits in MySQL. Failed schema migrations need inspection, not blind retry.
   content=p.read_text()
   sql('USE hippolulu_dev; '+ ('START TRANSACTION;\n' if folder=='seeds' else '')+content+f"\nINSERT INTO schema_migrations(name,sha256) VALUES('{name}','{digest}');"+('COMMIT;' if folder=='seeds' else ''))
   print('Applied',name)

def verify():
 print(sql("USE hippolulu_dev; SELECT game_id, COUNT(*), SUM(locked=0) FROM themes GROUP BY game_id; SELECT 'contents',COUNT(*) FROM contents; SELECT 'media',COUNT(*) FROM media; SELECT 'levels',COUNT(*) FROM matching_levels;"))
 assert sql("USE hippolulu_dev; SELECT COUNT(*) FROM themes WHERE locked=0;").strip()=='8'
 assert sql("USE hippolulu_dev; SELECT COUNT(*) FROM matching_levels;").strip()=='6'
 print('Verified catalog and free-theme rules.')

parser=argparse.ArgumentParser();parser.add_argument('action',choices=['setup','start','stop','verify','shell','backup']);args=parser.parse_args()
if args.action in ['setup','start']:
 start()
 if args.action=='setup': migrate();verify()
 print('Local MySQL ready (socket only):',SOCKET)
elif args.action=='stop': run([ADMIN,f'--defaults-file={CFG}','shutdown'])
elif args.action=='verify': verify()
elif args.action=='shell': run([MYSQL,f'--defaults-file={CFG}','hippolulu_dev'])
elif args.action=='backup':
 p=LOCAL/f'catalog-{time.strftime("%Y%m%d-%H%M%S")}.sql'
 with p.open('w') as f:
  run([shutil.which('mysqldump'),f'--defaults-file={CFG}','--single-transaction','--no-tablespaces','--set-gtid-purged=OFF','hippolulu_dev'],stdout=f)
 p.chmod(0o600);print(p)

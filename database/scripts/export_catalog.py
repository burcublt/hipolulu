"""Export full snapshot and non-destructive update for an existing deployment."""
from pathlib import Path
import subprocess,hashlib
ROOT=Path(__file__).resolve().parents[2];out=ROOT/'build/deploy';out.mkdir(parents=True,exist_ok=True)
r=subprocess.run(['docker','compose','exec','-T','db','mariadb-dump','--defaults-file=/run/admin.cnf','--single-transaction','--skip-add-drop-table','--skip-comments','--no-tablespaces','hippolulu_dev'],capture_output=True,text=True,check=True,cwd=ROOT)
s='\n'.join(line for line in r.stdout.splitlines() if 'enable the sandbox mode' not in line)+'\n'
(out/'hippolulu-catalog-full.sql').write_text(s)
p=ROOT/'database/seeds/004_asset_catalog_update.sql';digest=hashlib.sha256(p.read_bytes()).hexdigest()
(out/'hippolulu-catalog-update.sql').write_text('START TRANSACTION;\n'+p.read_text()+f"\nINSERT INTO schema_migrations(name,sha256) VALUES('seeds/004_asset_catalog_update.sql','{digest}') ON DUPLICATE KEY UPDATE sha256=VALUES(sha256);\nCOMMIT;\n")
print('Exported full snapshot (empty database only) and additive update (existing database).')

"""Create a separate read-only local DataGrip login, without printing its secret."""
import secrets,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[2]
local=root/'.local/mariadb'
password_file=local/'datagrip_password'
if not password_file.exists():
 password_file.write_text(secrets.token_hex(20));password_file.chmod(0o600)
password=password_file.read_text().strip()
assert len(password)==40 and all(c in '0123456789abcdef' for c in password)
cmd=['docker','compose','-f',str(root/'compose.yaml')]
subprocess.run(cmd+['up','-d','--wait'],check=True)
sql=f"CREATE USER IF NOT EXISTS 'hippolulu_datagrip'@'%' IDENTIFIED BY '{password}'; ALTER USER 'hippolulu_datagrip'@'%' IDENTIFIED BY '{password}'; GRANT SELECT, SHOW VIEW ON hippolulu_dev.* TO 'hippolulu_datagrip'@'%';"
subprocess.run(cmd+['exec','-T','db','mariadb','--defaults-file=/run/admin.cnf'],input=sql,text=True,check=True,capture_output=True)
config=local/'datagrip.cnf'
config.write_text(f'[client]\nuser=hippolulu_datagrip\npassword={password}\nhost=127.0.0.1\nport=3307\nprotocol=TCP\ndatabase=hippolulu_dev\n');config.chmod(0o600)
subprocess.run(['php','-r',
    '$c=parse_ini_file($argv[1]); $p=new PDO("mysql:host=127.0.0.1;port=3307;dbname=hippolulu_dev;charset=utf8mb4",$c["user"],$c["password"]); echo "Contents: ".$p->query("SELECT COUNT(*) FROM contents")->fetchColumn().PHP_EOL;', str(config)],check=True)

print('DataGrip TCP connection verified. Password saved to .local/mariadb/datagrip_password')

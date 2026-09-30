"""Run against the local Compose environment only."""
import json,subprocess,urllib.request,urllib.error
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def request(path,status=200,method='GET'):
 try:
  with urllib.request.urlopen(urllib.request.Request('http://127.0.0.1:8088'+path,method=method)) as r:code,body=r.status,r.read()
 except urllib.error.HTTPError as e:code,body=e.code,e.read()
 assert code==status,(path,code,body)
 return json.loads(body)
def sql(query):
 return subprocess.run(['docker','compose','-f',str(ROOT/'compose.yaml'),'exec','-T','db','mariadb','--defaults-file=/run/admin.cnf','hippolulu_dev','-N','-B'],input=query,text=True,check=True,capture_output=True).stdout
assert request('/v1/health')['status']=='ok'
assert len(request('/v1/games')['data'])==2
for locale in ['tr','en','es']:
 for game in ['puzzle','matching']:
  themes=request(f'/v1/games/{game}/themes?locale={locale}')['data']
  assert themes and all(isinstance(t['locked'],bool) for t in themes)
  content=request(f'/v1/games/{game}/themes/animals/contents?locale={locale}')['data']
  assert content and all(c['image_key'].startswith('assets/') for c in content)
assert request('/v1/games?locale=tr')['data'][0]['title']=='YAPBOZ'
assert len(request('/v1/games/matching/levels')['data'])==6
assert request('/v1/games/puzzle/settings')['data']['default_piece_count']==12
request('/v1/games?locale=xx',400)
request('/v1/games?locale[]=tr',400)
request('/v1/games',405,'POST')
request('/v1/unknown',404)
request('/v1/games/puzzle/themes/space/contents',404)
# A temporary fixture tests published locked-theme protection without changing real content.
fixture='api_test_locked'
assert sql(f"SELECT COUNT(*) FROM themes WHERE game_id='puzzle' AND id='{fixture}';").strip()=='0'
sql(f"INSERT INTO themes(game_id,id,sort_order,locked,status) VALUES('puzzle','{fixture}',999,1,'published');")
try:
 request(f'/v1/games/puzzle/themes/{fixture}/contents',403)
 request(f'/v1/games/puzzle/themes/{fixture}/contents?hasAllAccess=true&locked=false',403)
finally:
 sql(f"DELETE FROM themes WHERE game_id='puzzle' AND id='{fixture}';")
assert request('/v1/games/puzzle/themes/animals/contents')['data']
print('PASS: locales, catalog, game rules, draft filtering, locked-content guard, invalid inputs and methods.')

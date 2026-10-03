"""Generate an additive catalog seed from assets; preserve existing content IDs."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
titles=json.loads((ROOT/'database/content_titles.json').read_text())
def q(s):return "'"+str(s).replace("'","''")+"'"
lines=['SET NAMES utf8mb4;']
def emit(s):lines.append(s+';')
for old,new in json.loads((ROOT/'database/media_renames.json').read_text()).items():
 emit(f'UPDATE media SET storage_key={q(new)} WHERE storage_key={q(old)}')
for old,new in [('cabybara','capybara'),('avokado','avocado')]:
 emit(f"UPDATE contents SET slug={q(new)} WHERE game_id='puzzle' AND slug={q(old)}")
# Foods is an additional locked theme. It does not change the first four free themes.
emit("INSERT INTO themes(game_id,id,sort_order,locked,status) VALUES('matching','foods',13,1,'published') ON DUPLICATE KEY UPDATE id=VALUES(id)")
for locale,title in zip(['en','tr','es'],['Foods','Yiyecekler','Alimentos']):
 emit(f"INSERT INTO theme_translations VALUES('matching','foods',{q(locale)},{q(title)}) ON DUPLICATE KEY UPDATE title=VALUES(title)")
for theme,names in {'insects':['Insects','Böcekler','Insectos'],'fairytales':['Fairy Tales','Masallar','Cuentos de hadas'],'jobs':['Jobs','Meslekler','Profesiones'],'nature':['Nature','Doğa','Naturaleza']}.items():
 for locale,title in zip(['en','tr','es'],names):emit(f"INSERT INTO theme_translations VALUES('matching',{q(theme)},{q(locale)},{q(title)}) ON DUPLICATE KEY UPDATE title=VALUES(title)")
def media(p):
 key=p.relative_to(ROOT).as_posix()
 emit(f"INSERT INTO media(storage_key,kind,sha256,byte_size) VALUES({q(key)},{q('audio' if p.suffix=='.mp3' else 'image')},{q(hashlib.sha256(p.read_bytes()).hexdigest())},{p.stat().st_size}) ON DUPLICATE KEY UPDATE sha256=VALUES(sha256),byte_size=VALUES(byte_size)")
 return f'(SELECT id FROM media WHERE storage_key={q(key)})'
count=0
for game,folder in [('puzzle','puzzles'),('matching','matching')]:
 for directory in sorted((ROOT/'assets/images'/folder).iterdir()):
  if not directory.is_dir():continue
  theme='dinosaur' if game=='puzzle' and directory.name=='dinosaurs' else directory.name
  images=sorted(p for p in directory.iterdir() if p.suffix.lower() in ['.webp','.png','.jpg','.jpeg'])
  if not images:continue
  emit(f"UPDATE themes SET status='published' WHERE game_id={q(game)} AND id={q(theme)} AND status='draft'")
  for order,p in enumerate(images,1):
   slug=p.stem;assert slug in titles,slug
   mid=media(p);count+=1
   identity=f'game_id={q(game)} AND theme_id={q(theme)} AND slug={q(slug)}'
   emit(f"INSERT INTO contents(game_id,theme_id,slug,image_id,sort_order,status) VALUES({q(game)},{q(theme)},{q(slug)},{mid},{order},'published') ON DUPLICATE KEY UPDATE image_id=VALUES(image_id),sort_order=VALUES(sort_order)")
   cid=f'(SELECT id FROM contents WHERE {identity})'
   for locale,title in titles[slug].items():
    emit(f'INSERT INTO content_translations VALUES({cid},{q(locale)},{q(title)}) ON DUPLICATE KEY UPDATE title=VALUES(title)')
    if game=='matching':
     audio=ROOT/f'assets/voices/{directory.name}/{locale}/{slug}.mp3'
     if audio.exists():
      aid=media(audio)
      emit(f'INSERT INTO content_audio VALUES({cid},{q(locale)},{aid}) ON DUPLICATE KEY UPDATE media_id=VALUES(media_id)')
# Preserve alternative/unpaired recordings in the media inventory, without attaching
# an unverified recording to a different content item.
for p in sorted((ROOT/'assets/voices').rglob('*.mp3')):media(p)
(ROOT/'database/seeds/004_asset_catalog_update.sql').write_text('-- Additive asset and translation update.\n'+'\n'.join(lines)+'\n')
print(f'Generated update for {count} contents in three languages.')

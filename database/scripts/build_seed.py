"""Export existing assets and metadata; never invent missing content/translations."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
out=[]
def q(s): return "'"+str(s).replace("'","''")+"'"
def insert(table,cols,values):
 out.append(f"INSERT INTO {table} ({','.join(cols)}) VALUES ({','.join(str(v) if isinstance(v,int) else q(v) for v in values)});")
langs={l:json.loads((ROOT/f'lib/l10n/app_{l}.arb').read_text()) for l in ['en','tr','es']}
for l in langs: insert('locales',['code'],[l])
for i,g in enumerate(['puzzle','matching','coloring','counting']):
 insert('games',['id','sort_order','locked','status'],[g,i+1,int(i>=2),'published' if i<2 else 'draft'])
media={}
def add_media(path):
 if path not in media:
  p=ROOT/path
  if not p.is_file(): return None
  media[path]=len(media)+1
  insert('media',['id','storage_key','kind','sha256','byte_size'],[media[path],path,'audio' if p.suffix=='.mp3' else 'image',hashlib.sha256(p.read_bytes()).hexdigest(),p.stat().st_size])
 return media[path]
notes=[];count=0
for game,filename,pattern in [('puzzle','puzzle_theme_selections.dart',r'ThemeItem\(\s*id: \'([^\']+)\'(.*?)\n  \),'),('matching','matching_theme_select.dart',r'MatchingThemeData\(\s*id: \'([^\']+)\'(.*?)\n    \),')]:
 text=(ROOT/'lib'/filename).read_text()
 for order,(theme,body) in enumerate(re.findall(pattern,text,re.S),1):
  locked=int('locked: true' in body)
  paths=[]
  for prefix in ([f'assets/images/puzzles/{theme}',f'assets/images/matching/{theme}',f'assets/images/{theme}'] if game=='puzzle' else [f'assets/images/matching/{theme}',f'assets/images/{theme}']):
   paths=sorted(p for p in (ROOT/prefix).glob('*') if p.suffix.lower() in ['.png','.jpg','.jpeg','.webp'])
   if paths: break
  insert('themes',['game_id','id','sort_order','locked','status'],[game,theme,order,locked,'published' if paths else 'draft'])
  keymatch=re.search(r'l10n\.(\w+)',body)
  key=keymatch[1] if keymatch else 'theme'+('Dinosaur' if theme=='dinosaurs' else theme[0].upper()+theme[1:])
  for lang,data in langs.items():
   if key in data: insert('theme_translations',['game_id','theme_id','locale','title'],[game,theme,lang,data[key]])
   else: notes.append(f'Missing translation: {game}/{theme}/{lang}')
  if not paths: notes.append(f'Empty draft theme: {game}/{theme}')
  for order,p in enumerate(paths,1):
   mid=add_media(p.relative_to(ROOT).as_posix());count+=1
   insert('contents',['id','game_id','theme_id','slug','image_id','sort_order','status'],[count,game,theme,p.stem,mid,order,'published'])
   if game=='matching':
    for lang in langs:
     audio=f'assets/voices/{theme}/{lang}/{p.stem}.mp3'
     aid=add_media(audio)
     if aid: insert('content_audio',['content_id','locale','media_id'],[count,lang,aid])
     else: notes.append(f'Missing audio: {audio}')
text=(ROOT/'lib/matching_game.dart').read_text()
for level,pairs,seconds,path in re.findall(r'MatchingLevel\(\s*level: (\d+),\s*pairCount: (\d+),\s*previewSeconds: (\d+),\s*completeCharacter: \'([^\']+)\'',text):
 insert('matching_levels',['level_number','pair_count','preview_seconds','lives','completion_image_id'],[int(level),int(pairs),int(seconds),5,add_media(path)])
insert('puzzle_settings',['game_id','default_piece_count'],['puzzle',12])
(ROOT/'database/seeds/001_existing_catalog.sql').write_text('-- Generated from existing Flutter metadata and assets. Apply once.\n'+ '\n'.join(out)+'\n')
(ROOT/'database/import_notes.txt').write_text('\n'.join(notes)+'\nContent titles are intentionally not invented from filenames.\n')
print(f'Exported {count} contents, {len(media)} media. See database/import_notes.txt.')

import json
with open('graphify-out/.graphify_detect.json', encoding='utf-16') as f:
    text = f.read()
    d = json.loads(text)
print(f"Corpus: {d.get('total_files')} files ~ {d.get('total_words')} words")
print(f"  code: {len(d.get('files',{}).get('code',[]))} files")
print(f"  docs: {len(d.get('files',{}).get('document',[]))} files")
print(f"  images: {len(d.get('files',{}).get('image',[]))} files")
with open('graphify-out/.graphify_detect.json', 'w', encoding='utf-8') as f:
    json.dump(d, f)

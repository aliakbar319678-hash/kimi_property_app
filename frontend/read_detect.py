import json
with open('graphify-out/.graphify_detect.json', encoding='utf-16le') as f:
    text = f.read()
    try:
        d = json.loads(text)
    except Exception as e:
        print("Fallback utf-8")
        # maybe it's not utf-16le
        with open('graphify-out/.graphify_detect.json', encoding='utf-8') as f2:
            d = json.loads(f2.read())
print(f"Corpus: {d.get('total_files')} files ~ {d.get('total_words')} words")
print(f"  code: {len(d.get('files',{}).get('code',[]))} files")
print(f"  docs: {len(d.get('files',{}).get('document',[]))} files")
print(f"  images: {len(d.get('files',{}).get('image',[]))} files")
with open('graphify-out/.graphify_detect.json', 'w', encoding='utf-8') as f:
    json.dump(d, f)

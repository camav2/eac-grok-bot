import json,sys,re
path=sys.argv[1]
out=sys.argv[2]
text=open(path).read()
text=re.sub(r'</?cursor_untrusted_data_1337[^>]*>','',text)
i,j=text.find('{'),text.rfind('}')
obj=json.loads(text[i:j+1])
ids=[t['id'] for t in obj.get('threads',[])]
open(out,'w').write('\n'.join(ids)+('\n' if ids else ''))
print(len(ids))
if not ids:
    print('EMPTY')
else:
    t=obj['threads'][-1]
    m=t['messages'][0] if t.get('messages') else {}
    print('oldest_sample', t['id'], m.get('date'), m.get('sender'))

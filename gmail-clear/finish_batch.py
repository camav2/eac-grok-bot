from pathlib import Path
import sys
batch_n, head_span = sys.argv[1], sys.argv[2]
arch = Path('/workspace/gmail-clear/archived_ids.txt')
batch = Path('/workspace/gmail-clear/batch_current_ids.txt')
run_ids_path = Path('/workspace/gmail-clear/this_run_ids.txt')
existing = set(arch.read_text().split())
batch_ids = [x for x in batch.read_text().split() if x]
new = [i for i in batch_ids if i not in existing]
with arch.open('a') as f:
    for i in new: f.write(i+'\n')
run_existing = set(run_ids_path.read_text().split())
added_run = [i for i in batch_ids if i not in run_existing]
with run_ids_path.open('a') as f:
    for i in added_run: f.write(i+'\n')
run_count = len(run_existing)+len(added_run)
Path('/workspace/gmail-clear/run_count.txt').write_text(str(run_count)+'\n')
lines = sum(1 for _ in arch.open() if _.strip())
status = f"""archived_this_run={run_count}
empty=no
batch={batch_n}_done
head_span={head_span}
archived_ids_file_lines={lines}
method=search_threads in:inbox pageSize50 THREAD_VIEW_METADATA_ONLY -> unlabel_thread [INBOX,UNREAD] -> fresh search each batch
"""
Path('/workspace/gmail-clear/STATUS.txt').write_text(status)
print(status)

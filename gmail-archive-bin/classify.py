import json, re, sys

ARCHIVE = "Label_7245181107248167094"
LABEL_4 = "Label_4"
PROTECTED_IDS = {
    "1a080335143db3e6","1a055b4ee632ad17","1a06a44345616242","1a068b917ae36cfc",
    "1a019547ba05ba06","19fdce650dc58ae1","19fd501ed83a01a9","19fc86609874c53f",
    "19f50bb5b13f8cda","19f1abbcbd269449","19f164d0f7c762a2","19f163b0d6e1e9a7",
}

NOISE_SENDER_RE = re.compile(
    r"(noreply|no-reply|donotreply|do-not-reply|notifications?@|notify@|mailer-daemon|"
    r"newsletter|news@|updates?@|bounce|automated|receipts?@|"
    r"circle\.so|intercom|mailchimp|sendgrid|postmark|mandrill|"
    r"stripe\.com|paypal\.com|shopify|squarespace|wix\.com|"
    r"linkedin\.com|facebookmail|twitter\.com|instagram|"
    r"googleusercontent|accounts\.google|docs\.google|drive-shares|"
    r"calendar-notification|zoom\.us|notion\.so|slack\.com|"
    r"github\.com|gitlab\.com|atlassian|asana\.com|"
    r"hubspot|mailgun|"
    r"amazon\.com|aws\.amazon|apple\.com|microsoft\.com|"
    r"eventbrite|meetup\.com|typeform|surveymonkey|"
    r"canva\.com|figma\.com|dropbox\.com|"
    r"substack\.com|beehiiv|convertkit|klaviyo)",
    re.I,
)

BOOKING_SUBJ = re.compile(r"\b(new booking|booking (confirmed|cancelled|updated)|appointment)\b", re.I)
MICHELLE = re.compile(r"michelle@red-zebra\.com\.au", re.I)
TIDYCAL = re.compile(r"@?tidycal\.com", re.I)
NOISE_SUBJ = re.compile(
    r"(unsubscribe|newsletter|weekly digest|daily digest|your receipt|order confirmation|"
    r"payment (received|successful)|invoice #|we miss you|just for you|"
    r"security alert|new (sign-?in|login)|verify your|password reset|confirm your email|"
    r"mentioned you|commented on|shared .+ with you|invitation to (edit|view|join)|"
    r"your statement|account statement|shipping confirmation|tracking number|"
    r"community digest|weekly roundup)",
    re.I,
)

def is_noise_msg(mm):
    s = mm.get("sender") or ""
    sj = mm.get("subject") or ""
    sender_noise = bool(NOISE_SENDER_RE.search(s)) or bool(
        re.search(r"(noreply|no-reply|donotreply|notifications?)@", s, re.I)
    )
    if sender_noise:
        return True
    # Subject-only noise only when sender looks automated (no personal mailbox)
    # Avoid archiving human forwards that quote "shared with you" etc.
    if NOISE_SUBJ.search(sj):
        # personal-looking: name@domain without noreply keywords already handled
        local = s.split("<")[-1].split("@")[0].strip().lower() if "@" in s else ""
        if local and local not in {"info","hello","support","contact","admin","office","team","mail"}:
            # likely human mailbox — do not treat subject alone as noise
            return False
        return True
    return False

def decide(t):
    tid = t["id"]
    msgs = t.get("messages") or []
    m = msgs[0] if msgs else {}
    all_labs = set()
    for mm in msgs:
        all_labs |= set(mm.get("labelIds") or [])
    sender = m.get("sender") or ""
    subj = m.get("subject") or ""
    senders = " | ".join((mm.get("sender") or "") for mm in msgs)
    subjs = " | ".join((mm.get("subject") or "") for mm in msgs)

    if ARCHIVE in all_labs:
        return "skip_already", tid, sender, subj, sorted(all_labs)
    if tid in PROTECTED_IDS or any((mm.get("id") in PROTECTED_IDS) for mm in msgs):
        return "skip_protected_id", tid, sender, subj, sorted(all_labs)
    if MICHELLE.search(senders):
        return "skip_michelle", tid, sender, subj, sorted(all_labs)
    if LABEL_4 in all_labs:
        return "skip_label4", tid, sender, subj, sorted(all_labs)
    if TIDYCAL.search(senders) or BOOKING_SUBJ.search(subjs):
        return "skip_booking", tid, sender, subj, sorted(all_labs)

    if "INBOX" not in all_labs:
        return "label_only", tid, sender, subj, sorted(all_labs)

    inbox_msgs = [mm for mm in msgs if "INBOX" in (mm.get("labelIds") or [])]
    if inbox_msgs and all(is_noise_msg(mm) for mm in inbox_msgs):
        return "label_and_archive", tid, sender, subj, sorted(all_labs)
    return "skip_inbox_human", tid, sender, subj, sorted(all_labs)

def classify_file(path, out_prefix):
    text = open(path).read()
    text = re.sub(r"</?cursor_untrusted_data[^>]*>", "", text)
    obj = json.loads(text[text.find("{"):text.rfind("}")+1])
    threads = obj.get("threads") or []
    token = obj.get("nextPageToken")
    counts = {}
    labelable, archive_inbox, skips = [], [], []
    for t in threads:
        d, tid, sender, subj, labs = decide(t)
        counts[d] = counts.get(d,0)+1
        if d == "label_only":
            labelable.append(tid)
        elif d == "label_and_archive":
            labelable.append(tid); archive_inbox.append(tid)
        else:
            skips.append({"id":tid,"reason":d,"sender":sender[:80],"subj":(subj or "")[:60]})
    out = {"count_threads":len(threads),"nextPageToken":token,"counts":counts,
           "labelable":labelable,"archive_inbox":archive_inbox,"skips":skips}
    open(out_prefix+".json","w").write(json.dumps(out, indent=2))
    open(out_prefix.replace("decide","to_label")+".txt" if False else out_prefix+"_label.txt","w")
    # simpler:
    base = out_prefix
    open(base+"_meta.json","w").write(json.dumps(out, indent=2))
    open(base+"_label.txt","w").write("\n".join(labelable)+("\n" if labelable else ""))
    open(base+"_archive.txt","w").write("\n".join(archive_inbox)+("\n" if archive_inbox else ""))
    return out

if __name__ == "__main__":
    # args: search_dump_path out_prefix
    out = classify_file(sys.argv[1], sys.argv[2])
    print(json.dumps({"n":out["count_threads"],"token":out["nextPageToken"],"counts":out["counts"],
                      "label":len(out["labelable"]),"arch":len(out["archive_inbox"])}))

# f3anon.sh ROOT: stdin to stdout without the directory ROOT (the md5 of the hand-written cases does not depend on where the tree is) and without the text of
# an aborted assertion (see f3norm.sh)
sed -E "s|$1/||g" | sed -E '/^exit\(ATS\)/d; /^([^ ]*\/)?(src?\/)pats_[A-Za-z0-9_]+\.[sd]ats: [0-9]+\(line=[0-9]+, offs=[0-9]+\) -- [0-9]+\(line=[0-9]+, offs=[0-9]+\)$/d; /^$/d'

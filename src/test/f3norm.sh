# f3norm.sh FILE: the stderr of f3dump/f3dump1 without the text of an aborted assertion (assertloc: ATS1 prints "exit(ATS): [assert] failed: LOC" and an empty
# line, the ATS2 port prints LOC of the port's own source), which differs by construction; used by f3files.sh before the comparison.
sed -E '/^exit\(ATS\)/d; /^\/.*\/src?\/pats_[A-Za-z0-9_]+\.[sd]ats: [0-9]+\(line=[0-9]+, offs=[0-9]+\) -- [0-9]+\(line=[0-9]+, offs=[0-9]+\)$/d; /^$/d' "$1"

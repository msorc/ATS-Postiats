# usage: sh lexcompare.sh LIST  -- compares lexdump1 (ATS1 lexer) with lexdump (ATS2) in the modes file/string/getc/charlst/tokbuf
A1=./lexdump1
A2=${A2:-./lexdump}
n=0; bad=0; ntok=0
while read f; do
  n=$((n+1))
  $A1 "$f" > /tmp/lexcompare.o1.txt 2>&1; $A1 -s "$f" > /tmp/lexcompare.o1s.txt 2>&1
  ntok=$((ntok + $(wc -l < /tmp/lexcompare.o1.txt)))
  for m in -f -s -g -c; do
    $A2 $m "$f" > /tmp/lexcompare.o2.txt 2>&1
    ref=/tmp/lexcompare.o1.txt; [ $m = -s ] && ref=/tmp/lexcompare.o1s.txt
    if ! cmp -s $ref /tmp/lexcompare.o2.txt; then echo "MISMATCH $m $f"; bad=$((bad+1)); fi
  done
  # tokbuf mode: no comments; COMMENT_rest becomes EOF
  grep -av "COMMENT_line()\|COMMENT_block()" /tmp/lexcompare.o1.txt | sed 's/COMMENT_rest()/EOF()/' > /tmp/lexcompare.o1t.txt
  $A2 -t "$f" > /tmp/lexcompare.o2t.txt 2>&1
  # after EOF-from-COMMENT_rest the ATS1 dump continues? it stops at T_COMMENT_rest? no: cut after first EOF()
  awk 'BEGIN{e=0} { if (!e) { print } else if ($0 ~ /error\(lexing\)|additional errors/) print } /^: [0-9]+\(line=[0-9]+, offs=[0-9]+\) -- [0-9]+\(line=[0-9]+, offs=[0-9]+\) EOF\(\)$/ { e=1 }' /tmp/lexcompare.o1t.txt > /tmp/lexcompare.o1t2.txt
  if ! cmp -s /tmp/lexcompare.o1t2.txt /tmp/lexcompare.o2t.txt; then echo "MISMATCH -t $f"; bad=$((bad+1)); fi
done < "$1"
echo "files=$n lines(ATS1)=$ntok mismatches=$bad"

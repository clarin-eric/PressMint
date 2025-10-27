pwd
cd PressMint

changed_files=$(git diff --name-only HEAD HEAD~1)
press_changed=$(echo "$changed_files"|grep 'Samples/PressMint-.*/'|sed -n 's/^Samples\/PressMint-\([-A-Z]*\).*.xml$/\1/p'|sort|uniq|tr '\n' ' '|sed 's/ *$//')
scripts_changed=$(echo "$changed_files"|egrep  "^(Schema|Scripts)")
press_all=$(echo Samples/PressMint-*|sed 's/Samples\/PressMint-\([-A-Z]*\)/\1/g'|sort)


press_process=$(test -z "${press_changed}" && echo "${press_all}" || echo "${press_changed}")
press_process=$(echo "[\"$press_process\"]"|sed 's/  */","/g'| sed 's/^\[""\]$/[]/;s/,""//')

max_press_changed_size=0
all_press_changed_size=0
for press in $press_changed;
do
  size=$(find Samples/PressMint-$press -type f -name "PressMint-$press*.xml"  -print0 | du -c --block-size=1000000 --files0-from=-|tail -1|cut -f 1)
  echo "::notice:: Samples/PressMint-$press size =${size} MB"
  max_press_changed_size=$(( $max_press_changed_size < $size ? $size : $max_press_changed_size ))
  all_press_changed_size=$(echo "$all_press_changed_size+$size"|bc)
done

echo "::notice:: total changed press tei files size=${all_press_changed_size} MB"


press_changed=$(echo "[\"$press_changed\"]"|sed 's/  */","/g'| sed 's/^\[""\]$/[]/;s/,""//')

echo "DEBUG: changed_files=${changed_files}"

echo "DEBUG: press_changed=${press_changed}"

echo "DEBUG: scripts_changed=${scripts_changed}"

echo "DEBUG: press_all=${press_all}"

echo "DEBUG: press_process=${press_process}"


echo "press_process=${press_process}" >> $GITHUB_OUTPUT
echo "press_all=${press_all}" >> $GITHUB_OUTPUT
echo "press_changed=${press_changed}" >> $GITHUB_OUTPUT
echo "scripts_changed=${scripts_changed}" | tr "\n" " " | sed "s/$/\n/" >> $GITHUB_OUTPUT
echo "all_press_changed_size=${all_press_changed_size}" >> $GITHUB_OUTPUT
echo "max_press_changed_size=${max_press_changed_size}" >> $GITHUB_OUTPUT
#!/bin/bash

if [ 2 -ne $# ]; then
	echo "Usage: $0 region nation" > /dev/stderr
	echo "Be sure to use the name as shown on the nation page. For instance, underscores, not spaces"
	exit 1
fi

# nation name must have underscores instead of spaces
region="$1"
nation="$2"

WGET_FLAGS='--quiet --user-agent=rkulhanek_cardscript'


wget $WGET_FLAGS  "https://www.nationstates.net/page=deck/nation=$nation" "-Onation"
wget $WGET_FLAGS "https://www.nationstates.net/cgi-bin/api.cgi?region=$region&q=nations" "-Oregion"

maxnum=$(grep 'paginate' "nation" | sed 's/">/">\n/g' | sed -nr '/start=/ { s/.*start=([0-9]*)">/\1/; p; }' | sort -n | tail -1)

echo -n 'Throttling download at one page per second: .'
for i in $(seq 30 30 "$maxnum"); do
	wget $WGET_FLAGS "https://www.nationstates.net/page=deck/nation=$nation?start=$i" "-O-" >> "nation"
	echo -n '.'
	sleep 6
done
echo

sed -rn '/class="deckcard-title"/ { s/.*nname">([^<]*)<.*/\1/; p; }' < "nation" | tr 'A-Z ' 'a-z_' | sort -u > nation2

for i in $(sed -nr '/<NATIONS>/ { s/:/\n/g; p; }' < region | sed 's/<.*//' | sort); do
	echo -n "$i : "
	grep -c "$i" < nation2
done | awk '{printf("%3d : %s\n", $3,$1);}' | sort -nr


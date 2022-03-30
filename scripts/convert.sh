#!/bin/bash

for FILE in `ls *.cfg`
do
	grep "GENERIC_PLAYOUT_TYPE=SDI" $FILE >/dev/null
	if [ $? -eq 0 ]; then
		#echo "Skipping $FILE"
		continue
	fi
	grep "\- SDI " $FILE >/dev/null
	if [ $? -ne 0 ]; then
		#echo "Skipping $FILE"
		continue
	fi
	grep "filter:a" $FILE >/dev/null
	if [ $? -eq 0 ]; then
		#echo "Skipping $FILE"
		continue
	fi
	grep "RESERVED INUSE" $FILE >/dev/null
	if [ $? -eq 0 ]; then
		#echo "Skipping $FILE"
		continue
	fi

	. ./$FILE

#	grep "filter:a" $PLAYOUTAPP >/dev/null
#	if [ $? -eq 0 ]; then
#		#echo "Skipping $FILE"
#		continue
#	fi

#	grep "LTN_ENABLE_AUDIO_ALL" $PLAYOUTAPP >/dev/null
#	if [ $? -eq 0 ]; then
#		#echo "Skipping $FILE"
#		continue
#	fi

	grep "TestPattern" $PLAYOUTAPP >/dev/null
	if [ $? -eq 0 ]; then
		#echo "Skipping $FILE"
		continue
	fi

	echo $CASENAME
	cat $PLAYOUTAPP
	FILENAME=`grep VPBASE $PLAYOUTAPP | sed 's!.*VPBASE!VPBASE!g' | sed 's! .*!!g'`

cat >x <<EOF
# Variable configurables used for testing

CASENAME="$CASENAME"

# GENERIC_PLAYOUT_TYPE (optional, but upper case mandatory) options:
#  NONE
#  IP_TS
#  SDI (unsupported)
#  NDI (unsupported)
#  PCAP (unsupported)
GENERIC_PLAYOUT_TYPE=SDI

GENERIC_PLAYOUT_APP=decklink-generic-decode-to-sdi.sh
GENERIC_ARGS="$GENERIC_ARGS --audioleveldown5"
GENERIC_ARGS="$GENERIC_ARGS --input \$$FILENAME"
EOF

	cat x
	echo -n "Y/N: " ; read answer
	if [ "$answer" == "y" ]; then
		cp x $FILE
		rm -f $PLAYOUTAPP
	fi
done

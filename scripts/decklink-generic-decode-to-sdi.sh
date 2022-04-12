#!/bin/bash -x

DECKLINK_OUTPUT=""
MAPPING=""
FILENAME=""
OUTPUT_PORT=""
VIDEO_FILTERS=""
AUDIO_LEVEL_DOWN=""
PROGRAM_NUMBER=""
DOWNMIX="-ac 2"

USAGETXT=$(cat <<-END
  Usage: $0\n
     --program-number 707     -- For an MPTS input, selects the right program number"
     --input          file.ts -- Absolute filename .ts|mov|mp4 etc\n
     --mapping        string  -- Eg. '-map 0:6 -map 0:10 -- select specific audio and video streams from a MPTS'\n
     --output-port    #       -- Eg. 1..4\n
     --burnwriter             -- Enable burnwriter [def: disabled]\n
     --time                   -- Enable timestamp in frame [def: disabled]\n
     --enableallaudio         -- Enable decoding of all audio channels\n
     --disabledownmix         -- By default we downmix 5.1. Disbale this feature\n
END
)

if [ $# -eq 0 ]; then
  echo -e $USAGETXT
  exit 1
fi

while (($#))
do
        case $1 in
        --audioleveldown5)
		AUDIO_LEVEL_DOWN="-filter:a \"volume=-5dB\""
		;;
        --disabledownmix)
		DOWNMIX=""
		;;
        --enableallaudio)
		export LTN_ENABLE_AUDIO_ALL=1
		;;
        --program-number)
                shift
                PROGRAM_NUMBER="-selected_program $1"
		;;
        --input)
                shift
                FILENAME=$1
		;;
        --mapping)
                shift
                MAPPING=$1
		;;
        --output-url)
                shift
                OUTPUT_URL=$1
		;;
        --time)
                if [ "$VIDEO_FILTERS" == "" ]; then
                        VIDEO_FILTERS="-vf drawtext=fontfile=MONACO.TTF:text='%{pts}':x=250:y=500:fontsize=64:fontcolor=yellow:box=1:boxcolor=black"
                else
                	VIDEO_FILTERS="$VIDEO_FILTERS,drawtext=fontfile=MONACO.TTF:text='%{pts}':x=250:y=500:fontsize=64:fontcolor=yellow:box=1:boxcolor=black"
		fi
		;;
        --burnwriter)
                if [ "$VIDEO_FILTERS" == "" ]; then
                        VIDEO_FILTERS="-vf burnwriter"
                else
                	VIDEO_FILTERS="$VIDEO_FILTERS,burnwriter"
		fi
                ;;
        --output-port)
                shift
                OUTPUT_PORT=$1
		if [ $OUTPUT_PORT -lt 1 ] || [ $OUTPUT_PORT -gt 4 ]; then
			usage
			echo "Illegal port number, should be 1..4"
			exit 1
		fi
		;;
        *)
                echo $USAGETXT
		echo "$1 is illegal"
                exit 1
		;;
        esac
        shift
done

# Mapping is not mandatory

if [ "$FILENAME" == "" ]; then
	echo "--input is mandatory"
	exit 1
fi
if [ "$OUTPUT_PORT" == "" ]; then
	echo "--output-port is mandatory"
	exit 1
fi

lspci | grep "DeckLink 8K Pro" >/dev/null
if [ $? -eq 0 ]; then
	if [ "$OUTPUT_PORT" -eq 1 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (1)"; fi
	if [ "$OUTPUT_PORT" -eq 2 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (3)"; fi
	if [ "$OUTPUT_PORT" -eq 3 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (2)"; fi
	if [ "$OUTPUT_PORT" -eq 4 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (4)"; fi
else
	if [ "$OUTPUT_PORT" -eq 1 ]; then DECKLINK_OUTPUT="DeckLink Duo (1)"; fi
	if [ "$OUTPUT_PORT" -eq 2 ]; then DECKLINK_OUTPUT="DeckLink Duo (3)"; fi
	if [ "$OUTPUT_PORT" -eq 3 ]; then DECKLINK_OUTPUT="DeckLink Duo (2)"; fi
	if [ "$OUTPUT_PORT" -eq 4 ]; then DECKLINK_OUTPUT="DeckLink Duo (4)"; fi
fi

echo filename $FILENAME
echo $DECKLINK_OUTPUT

while [ 1 ]; do
	#decoder-0.12 -y -i $FILENAME $MAPPING -ar 48000 \
	#decoder-0.34 -y $PROGRAM_NUMBER -i $FILENAME $MAPPING -ar 48000 \
	decoder-0.36-dev -y $PROGRAM_NUMBER -i $FILENAME $MAPPING -ar 48000 \
		$VIDEO_FILTERS \
		$AUDIO_LEVEL_DOWN \
		-acodec pcm_s16le $DOWNMIX -vcodec v210 -cea708_line 11 -use_3glevel_a on -f decklink "$DECKLINK_OUTPUT"
	#sleep 0.1
done

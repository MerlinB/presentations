#!/bin/bash
read -p "Titel des Vortrags: " TITLE
read -p "Pfad zu Vortrag: " AUDIO_IN

ffmpeg \
	-y \
	-t 11 -i Intro.mp3 -i $AUDIO_IN \
  -filter_complex "[1:a]volume=10[loud];\
    [0:a][loud]concat=n=2:v=0:a=1[out]" \
  -map "[out]" -map_metadata -1 -metadata title="$TITLE" -ac 1 -ar 44100 -b:a 96k $TITLE.mp3

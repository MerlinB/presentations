#!/bin/bash
read -p "Titel des Vortrags: " TITLE

read -p "Pfad zu Vortrag: " VIDEO_IN

while true; do
    read -p "Präsentation vorhanden? [Y]" yn
		yn=${yn:-Y}
    case $yn in
        [Yy]* ) 
					read -p "Pfad zu Präsentation: " PRESENTATION_IN
					read -p "Sekunden vom Anfang der Präsentation zu schneiden: [0] " SS
					SS=${SS:-0}
					break;;
        [Nn]* ) break;;
    esac
done

ffmpeg \
	-y \
	-loop 1 -t 11 -i scholarium_logo.png -i Intro.mp3 \
	-filter_complex "\
		color=white@0:1920x1080,format=yuva444p[c];\
		[c]split[c1][c2];\
		[0:v]scale=1000:-1[logo];\
		[logo]fade=in:st=0.5:d=3:alpha=1,fade=out:st=8:d=2:alpha=1[ovr1];\
		[c1]drawtext=fontsize=55:fontfile=garamond_regular.otf:text='$TITLE':x=(w-text_w)/2:y=H/2,fade=in:st=2:d=2:alpha=1,fade=out:st=8:d=2:alpha=1[ovr2];\
		[c2][ovr1]overlay=W/2-w/2:H/3-h/2:shortest=1[out1];\
		[out1][ovr2]overlay=0:0:shortest=1[out2]" \
	-map "[out2]" -map 1:a \
	intro_$TITLE.mp4

if [ -n "$PRESENTATION_IN" ] ; then
	ffmpeg \
		-y \
		-t 60 -i $VIDEO_IN -ss $SS -i $PRESENTATION_IN -i intro_$TITLE.mp4 \
		-filter_complex "\
			[1]crop=iw*0.96:ih*0.9:iw*0.02:ih*0.1[c];\
			[c]scale=-1:1080[s];\
			[2]scale=1920:-1[i];\
			[s]pad=1920:1080:0:0[v];\
			[0]scale=800:-1[p];\
			[v][p]overlay=x=W-w:y=H-h:shortest=1[out];\
			[i][2:a][out][0:a]concat=n=2:v=1:a=1[video][audio]" \
		-map [video] -map [audio] \
		-c:v libx265 -preset fast -c:a aac -b:a 192k \
		$TITLE.mp4
else
	ffmpeg \
		-y \
		-t 60 -i $VIDEO_IN -i intro_$TITLE.mp4 \
		-filter_complex "\
			[0]scale=-1:1080[s];\
			[s]pad=1920:1080:ow/2-iw/2:0[v];\
			[1]scale=1920:-1[i];\
			[i][1:a][v][0:a]concat=n=2:v=1:a=1[video][audio]" \
		-map [video] -map [audio] \
		-c:v libx265 -preset fast -c:a aac -b:a 192k \
		$TITLE.mp4
fi


#[s]select='if(gt(scene,0.0001),st(1,t),lte(t-ld(1),1))'[p];\
#[0:v]scale=iw:-1[scaled];\
#[1][scaled]overlay=0:0[out];\
#[out]trim=start=3:end=5" \

#select='if(gt(scene,0.0001),st(1,t),lte(t-ld(1),1))',\
#setpts=N/FRAME_RATE/TB"

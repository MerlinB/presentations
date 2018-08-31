ffmpeg \
	-y \
	-t 60 -i Krypto.mp4 \
	-t 60 -i Krypto30.mov \
	-pix_fmt yuv420p \
	-filter_complex "\
		[1]crop=iw*0.96:ih*0.9:iw*0.02:ih*0.1[c];\
		[c]scale=-1:1080[s];\
		[s]pad=1920:1080:0:0[v];\
		[0]scale=800:-1[p];\
		[v][p]overlay=x=W-w:y=H-h[out]" \
	-map [out] \
	-map 0:a \
	-c:v libx265 -preset fast -c:a aac -b:a 192k \
	output.mp4


		#[s]select='if(gt(scene,0.0001),st(1,t),lte(t-ld(1),1))'[p];\
		#[0:v]scale=iw:-1[scaled];\
		#[1][scaled]overlay=0:0[out];\
		#[out]trim=start=3:end=5" \

		#select='if(gt(scene,0.0001),st(1,t),lte(t-ld(1),1))',\
		#setpts=N/FRAME_RATE/TB"



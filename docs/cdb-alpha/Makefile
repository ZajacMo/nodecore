install: tmp-final.webp
	cp tmp-final.webp ../../.cdb-alpha.webp

tmp-final.webp: tmp-full.png
	convert tmp-full.png \
	-define webp:alpha-compression=1 \
	-define webp:alpha-filtering=2 \
	-define webp:alpha-quality=80 \
	-define webp:exact=false \
	-define webp:auto-filter=true \
	-define webp:lossless=false \
	-define webp:low-memory=false \
	-define webp:method=6 \
	-quality 80 \
	tmp-final.webp

tmp-full.png: tmp-fg.png
	convert \
		../../.cdb-release.jpg \
		tmp-fg.png \
		-composite tmp-full.png

tmp-fg.png:
	convert \
		../../.cdb-release.jpg \
		-alpha Off \
		-blur 0x3 \
		-negate \
		-modulate 30,100,50 \
		-negate \
		alpha-mask.png \
		-alpha Off \
		-compose CopyOpacity \
		-composite tmp-fg.png

# -channel rgb -negate
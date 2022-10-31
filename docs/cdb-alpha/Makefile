install: tmp-final.jpg
	cp tmp-final.jpg ../../.cdb-alpha.jpg

tmp-final.jpg: tmp-full.png
	guetzli \
		--quality 85 \
		--verbose \
		tmp-full.png \
		tmp-final.jpg

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
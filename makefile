
all : FORCE
	touch ga.tra
	make ga.pat
	
flip : flip.c
	gcc -o flip flip.c
	mv ./flip ${HOME}/clar/denartha

#  upon a new release of tetex, need to go in and edit
#  /usr/share/texmf/tex/generic/config/language.dat
#  (other language.dat's seem not to have an effect)
#   then you need to run:
#  % initex latex.ltx    (or "fmtutil --all"?) to rebuild web2c/latex.fmt
#  but be sure default permission for root are 644, not 600!
install :
	cp -f gahyph.tex /usr/share/texmf/tex/generic/hyphen
	chmod 444 /usr/share/texmf/tex/generic/hyphen/gahyph.tex
	cp -f gahyph.tex /usr/share/texmf/source/generic/babel
	chmod 444 /usr/share/texmf/source/generic/babel/gahyph.tex

gahyph.tex : FORCE
	make ga.pat
	cp -f gahyph.tex gahyph.tex.bak
	cat ga.pat | sed 's/á/^^e1/g; s/é/^^e9/g; s/í/^^ed/g; s/ó/^^f3/g; s/ú/^^fa/g;' > ga.pat.tmp
	sed '/\\patterns{/r ga.pat.tmp' gahyphtemplate.tex > gahyph.tex
	rm -f ga.pat.tmp

ga.pat : ga.dic ga.tra
	patgen ga.dic /dev/null ga.pat ga.tra  < inps

pattmp.1 : todo.dic ga.tra ga.pat
	patgen todo.dic ga.pat /dev/null ga.tra  < dummy

tobar : FORCE
	cat /mathhome/kps/gaeilge/diolaim/tobar/* | tokenize | egrep '...*-' | sort -u > tobar

# updates todo.raw too
deanta.raw : todo.raw
	touch deanta.raw
	cp deanta.raw deanta.raw.bak
	cp todo.raw todo.raw.bak
	(egrep -v '^[^/]*[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#]+[aeiouáéíóúAEIOUÁÉÍÓÚ]' todo.raw; cat deanta.raw) > temp.raw
	sed -i -n '/^[^/]*[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#]*[aeiouáéíóúAEIOUÁÉÍÓÚ]/p' todo.raw
	sort -u temp.raw | tr -d "#" > deanta.raw
	rm -f temp.raw
	diff deanta.raw.bak deanta.raw | more

flipped.raw : todo.raw
	cat todo.raw | sed '/\//!{s/$$/\//}' | sed 's/\//\n\//' | flip | sed '/^\//!{N; s/\n//}' | sort | sed 's/\//\n\//' | flip | sed '/^\//!{N; s/\n//}' > flipped.raw

endings.4 : flipped.raw
	cat flipped.raw | tr -d "|" | sed 's/\/.*//' | sed 's/^.*\(....\)$$/\1/' | sort | uniq -c | sort -r -n > endings.4

endings.5 : flipped.raw
	cat flipped.raw | tr -d "|" | sed 's/\/.*//' | sed 's/^.*\(.....\)$$/\1/' | sort | uniq -c | sort -r -n > endings.5

# strip out hyphens after 1st and before last TWICE:
# once before ispell so that "d'" etc. aren't added to "a|treoraigh"
# and once after since ispell generates such hyphens, e.g. "é|adh", etc.
ga.dic : deanta.raw
	cat deanta.raw | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > ga.dic

todo.dic : todo.raw
	cat todo.raw | tr -d "#" | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > todo.dic

todo.tex : todo.raw
	(echo '\showhyphens{'; cat todo.raw | tr -d "#|" | sed 's/\/.*//'; echo '}') > todo.temp
	sed '/HERE/r todo.temp' todotemplate.tex > todo.tex
	rm -f todo.temp

# really only used to test "gaeilgehyph.aff"; everything matches
# as of 1/20/04, 9pm.
hyphtest :
	cat todo.raw deanta.raw | tr -d "#" | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | tr -d "|" | sort -u | egrep -v -e '-' > hyphtest.1
	sort -u ${HOME}/gaeilge/ispell/ispell-gaeilge/aspell.txt | egrep -v -e '-' > hyphtest.2
	diff hyphtest.2 hyphtest.1
	rm -f hyphtest.1 hyphtest.2
#	cat ga.dic | tr -d "!" | ispell -l -dgaeilge

longs :
	cat todo.raw | tr "|" "\n" | tr "#" "\n" | sed 's/\/.*//' | sort | uniq -c | egrep '[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ]+[aeiouáéíóúAEIOUÁÉÍÓÚ]' | sort -r -n

clean :
	rm -f pattmp* gahyph.tex todo.tex endings.* flipped.raw

distclean :
	make clean
	rm -f ga.pat ga.dic todo.dic

FORCE :

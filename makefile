
all : gahyph.tex dist

up : deanta.raw
	
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

installhtml : mile.html
	cp -f index.html ${HOME}/public_html/fleiscin
	cp -f sonrai.html ${HOME}/public_html/fleiscin
	cp -f mile.html ${HOME}/public_html/fleiscin
	chmod 444 ${HOME}/public_html/fleiscin/*.html

mile.html : ga.pat miletemp.html
	beocorp | keepok | egrep -v "'" | egrep -v -e '-' | sort | uniq -c | sort -n -r | sed 's/^ *[1-9][0-9]* //' | head -n 1000 > mile.dic
	(echo "2"; echo "1"; echo "y") | patgen mile.dic ga.pat /dev/null ga.tra
	cat pattmp.5 | tr "." "-" | sed 's/$$/<br>/; s/^/ /' | egrep -n '.' > mile.dic
	sed '/^Please/r mile.dic' miletemp.html > mile.html

dist : hyph_ga_IE.zip

gahyph.tex : ga.pat gahyphtemplate.tex
	rm -f gahyph.tex
	cat ga.pat | sed 's/á/^^e1/g; s/é/^^e9/g; s/í/^^ed/g; s/ó/^^f3/g; s/ú/^^fa/g;' > ga.pat.tmp
	sed '/\\patterns{/r ga.pat.tmp' gahyphtemplate.tex > gahyph.tex
	rm -f ga.pat.tmp
	chmod 400 gahyph.tex

hyph_ga_IE.dic : ga.pat
	(echo "ISO8859-1"; cat ga.pat) > hyph_ga_IE.dic
	chmod 644 hyph_ga_IE.dic

hyph_ga_IE.zip : hyph_ga_IE.dic README_hyph_ga_IE.txt
	zip hyph_ga_IE.zip hyph_ga_IE.dic README_hyph_ga_IE.txt

ga.pat : ga.dic ga.tra
	patgen ga.dic /dev/null ga.pat ga.tra  < inps

# strip out hyphens after 1st and before last TWICE:
# once before ispell so that "d'" etc. aren't added to "a|treoraigh"
# and once after since ispell generates such hyphens, e.g. "é|adh", etc.
ga.dic : deanta.raw
	cat deanta.raw | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > ga.dic

# updates todo.raw too
deanta.raw : todo.raw
	touch deanta.raw
	cp deanta.raw deanta.raw.bak
	(egrep -v '^[^/]*[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#]+[aeiouáéíóúAEIOUÁÉÍÓÚ]' todo.raw; cat deanta.raw) > temp.raw
	sed -i -n '/^[^/]*[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#]*[aeiouáéíóúAEIOUÁÉÍÓÚ]/p' todo.raw
	sort -u temp.raw | tr -d "#" > deanta.raw
	rm -f temp.raw
	diff deanta.raw.bak deanta.raw | more
	rm -f deanta.raw.bak

clean :
	rm -f pattmp* todo.dic todo.tex endings.* flipped.raw longs.txt tobar *.aux *.log ambig.txt *.dvi todo.5 todofull.5

distclean :
	make clean
	rm -f ga.pat ga.dic todo.dic gahyph.tex hyph_ga_IE.*

#############################################################################
#              stuff for bootstrapping (working on todo.raw)


# used to test current pattern set on "todo" with the following 
# (basically using patgen vs. TeX itself!)
todo.5 : todo.raw ga.tra ga.pat
	cat todo.raw | tr -d "#" | sed 's/\/.*//' | egrep -v '[A-ZÁÉÍÓÚ]' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > todo.dic
	(echo "2"; echo "1"; echo "y") | patgen todo.dic ga.pat /dev/null ga.tra
	rm -f todo.dic
	cat pattmp.5 | egrep -v '!' | egrep -v '\.[^aeiouáéíóú]+\.' | egrep -v '[aeiouáéíóú][^aeiouáéíóú.*]+[aeiouáéíóú]' | sort -u > todo.5

todofull.5 : todo.raw ga.tra ga.pat
	cat todo.raw | tr -d "#" | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > todo.dic
	(echo "2"; echo "1"; echo "y") | patgen todo.dic ga.pat /dev/null ga.tra
	rm -f todo.dic
	mv -f pattmp.5 todofull.5

# hyphenates todo list, using TeX not patgen
todo.tex : todo.raw todotemplate.tex
	(echo '\showhyphens{'; cat todo.raw | tr -d "#|" | sed 's/\/.*//'; echo '}') > todo.temp
	sed '/HERE/r todo.temp' todotemplate.tex > todo.tex
	rm -f todo.temp

# shows remaining long strings; work on em manually
longs.txt : todo.raw
	cat todo.raw | tr "|" "\n" | tr "#" "\n" | sed 's/\/.*//' | sort | uniq -c | egrep '[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ]+[aeiouáéíóúAEIOUÁÉÍÓÚ]' | sort -r -n > longs.txt

#############################################################################
#                           stuff for testing

ambig.txt : ga.dic
	cat ga.dic | tr -d '!' | sort | uniq -c | egrep -v '1' > ambig.txt

#############################################################################
#                     stuff for reversing todolist                          #
flip : flip.c
	gcc -o flip flip.c
	mv ./flip ${HOME}/clar/denartha

flipped.raw : todo.raw
	cat todo.raw | sed '/\//!{s/$$/\//}' | sed 's/\//\n\//' | flip | sed '/^\//!{N; s/\n//}' | sort | sed 's/\//\n\//' | flip | sed '/^\//!{N; s/\n//}' > flipped.raw

endings.4 : flipped.raw
	cat flipped.raw | tr -d "|" | sed 's/\/.*//' | sed 's/^.*\(....\)$$/\1/' | sort | uniq -c | sort -r -n > endings.4

endings.5 : flipped.raw
	cat flipped.raw | tr -d "|" | sed 's/\/.*//' | sed 's/^.*\(.....\)$$/\1/' | sort | uniq -c | sort -r -n > endings.5
##############################################################################
#                              DEFUNCT STUFF
#
# really only used to test "gaeilgehyph.aff"; everything matches
# as of 1/20/04, 9pm.
hyphtest :
	cat todo.raw deanta.raw | tr -d "#" | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | tr -d "|" | sort -u | egrep -v -e '-' > hyphtest.1
	sort -u ${HOME}/gaeilge/ispell/ispell-gaeilge/aspell.txt | egrep -v -e '-' > hyphtest.2
	diff hyphtest.2 hyphtest.1
	rm -f hyphtest.1 hyphtest.2

#   never pursued the idea of extracting example from
#   Tobar na Gaedhilge...
tobar : FORCE
	cat /mathhome/kps/gaeilge/diolaim/tobar/* | tokenize | egrep '...*-' | sort -u > tobar
##############################################################################

FORCE :

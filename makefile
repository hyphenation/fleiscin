
all : gahyph.tex dist

#  upon a new release of tetex, need to redo the "installation instructs"
#  as given in usaid.html.
install :
	cp -f gahyph.tex /usr/share/texmf/tex/generic/hyphen
	chmod 444 /usr/share/texmf/tex/generic/hyphen/gahyph.tex
	(cd /usr/share/texmf/web2c; initex latex.ltx; chmod 444 latex.fmt)
#	cp -f gahyph.tex /usr/share/texmf/source/generic/babel
#	chmod 444 /usr/share/texmf/source/generic/babel/gahyph.tex

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
	patgen ga.dic tosaigh.pat ga.pat ga.tra  < inps.full
	mv pattmp.? ga.log

# strip out hyphens after 1st and before last TWICE:
# once before ispell so that "d'" etc. aren't added to "a|treoraigh"
# and once after since ispell generates such hyphens, e.g. "é|adh", etc.
ga.dic : deanta.raw
	cat deanta.raw | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sed 's/|\(.\)\//\1\//' | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | tr "[:upper:]" "[:lower:]" | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > ga.dic

#  1/30/04, done with todo.raw -> deanta.raw; so no more make target!
#deanta.raw :
#	touch deanta.raw
#	cp deanta.raw deanta.raw.bak
#	(egrep -v '^[^/]*[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#]+[aeiouáéíóúAEIOUÁÉÍÓÚ]' todo.raw; cat deanta.raw) > temp.raw
#	sed -i -n '/^[^/]*[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#][^aeiouáéíóúAEIOUÁÉÍÓÚ/|#]*[aeiouáéíóúAEIOUÁÉÍÓÚ]/p' todo.raw
#	sort -u temp.raw | tr -d "#" > deanta.raw
#	rm -f temp.raw
#	diff deanta.raw.bak deanta.raw | more
#	rm -f deanta.raw.bak

check : FORCE
	@echo 'Illegal characters:'
	@if egrep '[^/a-zA-ZáéíóúÁÉÍÓÚ|]' deanta.raw; then echo "Problem."; fi;
	@echo 'Syllables with no vowels:'
	@if egrep '\|[^aeiouáéíóú|]+\|' deanta.raw | egrep -v '\|nn\|a'; then echo "Problem."; fi;
	@echo 'Bad aitches:'
	@if egrep '[bcdfgmpstBCDFGMPST]\|h' deanta.raw; then echo "Problem."; fi;

# writes list of words with bad hyphens but which aren't explicitly ambig.
bugs.txt : ga.pat ambig.txt
	cat ambig.txt | sed 's/.*/\/^&$$\/d/' > words.sed
	egrep '\.' ga.log | tr -d '.!*' | sed -f words.sed > bugs.txt
	rm -f words.sed

ambig.txt : ga.dic
	cat ga.dic | tr -d '!' | sort | uniq -c | egrep -v '1' | sed 's/^ *[0-9]* //' > ambig.txt

clean :
	rm -f pattmp* todo.dic todo.tex endings.* flipped.raw longs.txt tobar *.aux *.log ambig.txt *.dvi todo.5 todofull.5 bugs.txt bugs-nlc.txt

distclean :
	make clean
	rm -f ga.pat ga.dic todo.dic gahyph.tex hyph_ga_IE.* mile.dic mile.txt
#############################################################################
#        web page stuff
installhtml : mile.html
	cp -f index.html ${HOME}/public_html/fleiscin
	cp -f sonrai.html ${HOME}/public_html/fleiscin
	cp -f mile.html ${HOME}/public_html/fleiscin
	cp -f usaid.html ${HOME}/public_html/fleiscin
	chmod 444 ${HOME}/public_html/fleiscin/*.html

mile.html : mile.dic miletemp.html
	cat mile.dic | head -n 1000 | sed 's/$$/<br>/; s/^/ /' | egrep -n '.' | sed 's/^1[^0-9]/<td width="25%">&/; s/^1000.*/&<\/td>/' | sed 's/^251/<\/td><td width="25%">251/; s/^501/<\/td><td width="25%">501/; s/^751/<\/td><td width="25%">751/' > mile.dic.temp
	sed '/^Please/r mile.dic.temp' miletemp.html > mile.html
	rm -f mile.dic.temp

mile.dic : ga.pat ga.tra mile.txt
	(echo "2"; echo "1"; echo "y") | patgen mile.txt ga.pat /dev/null ga.tra
	cat pattmp.? | tr "." "-" > mile.dic
	rm -f pattmp.?

# implicitly depends on entire corpus
mile.txt :
	brillcorp | keepok -n | egrep -v '^[Tt]he$$' | egrep -v "'" | egrep -v -e '-' | egrep '^([aiáéíó]$$|..)' | head -n 2500 > mile.txt


#############################################################################
#              stuff for stratified sampling
#done.txt : ga.dic
#	cat ga.dic | tr -d "!" | tr "[:upper:]" "[:lower:]" | sort -u > done.txt

NLC :
	nlcorpas | tokenize | sort | keepok -n | egrep -v '.{35}' | egrep -v '^[Tt]he$$' | egrep -v "'" | egrep -v -e '-' | egrep '^([aiáéíó]$$|..)' | tr "[:upper:]" "[:lower:]" | LC_ALL=C egrep -v '[a-záéíóú0-9 ]' | sort -u > NLC

# used to use patgen to do this; build the "ga.pat" ruleset and then
# run "NLC" through it: 
# (echo "2"; echo "1"; echo "y") | patgen NLC ga.pat /dev/null ga.tra
# then change "." to "!" as usual
ga-nlc.dic : NLC ga.dic
	bash ./nlcdic > ga-nlc.dic

ga-nlc.pat : ga-nlc.dic ga.tra
	patgen ga-nlc.dic /dev/null ga-nlc.pat ga.tra  < inps
	mv pattmp.? ga-nlc.log

testnlc : ga-nlc.pat
	(echo "2"; echo "1"; echo "y") | patgen ga.dic ga-nlc.pat /dev/null ga.tra
	mv pattmp.? testnlc.log

bugs-nlc.txt : ga-nlc.pat
	egrep '[.!]' ga-nlc.log | tr -d '.!*' > bugs-nlc.txt

#############################################################################
#              stuff for bootstrapping (working on todo.raw)
#                         


# used to test current pattern set on "todo" with the following 
# (basically using patgen vs. TeX itself!)
todo.5 : todo.raw ga.tra ga.pat
	cat todo.raw | tr -d "#" | sed 's/\/.*//' | egrep -v '[A-ZÁÉÍÓÚ]' | sed 's/^\(.\)|/\1/' | sed 's/|\(.\)$$/\1/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > todo.dic
	(echo "2"; echo "1"; echo "y") | patgen todo.dic ga.pat /dev/null ga.tra
	rm -f todo.dic
	cat pattmp.5 | egrep -v '!' | egrep -v '\.[^aeiouáéíóú]+\.' | egrep -v '[aeiouáéíóú][^aeiouáéíóú.*]+[aeiouáéíóú]' | sort -u > todo.5
	rm -f pattmp.?

# same as above, but use ispell to expand affix flags
#  Not useful for bootstrapping though
todofull.5 : todo.raw ga.tra ga.pat
	cat todo.raw | egrep -v '^[^/]*[A-Z]' | tr -d "#" | ispell -dgaeilgehyph -e3 | tr " " "\n" | egrep -v '\/' | sort -u | tr "|" "!" | egrep -v -e '-' | egrep -v "'" > todo.dic
	(echo "2"; echo "1"; echo "y") | patgen todo.dic ga.pat /dev/null ga.tra
	rm -f todo.dic
	mv -f pattmp.? todofull.5

# hyphenates todo list, using TeX not patgen
todo.tex : todo.raw todotemplate.tex
	(echo '\showhyphens{'; cat todo.raw | tr -d "#|" | sed 's/\/.*//'; echo '}') > todo.temp
	sed '/HERE/r todo.temp' todotemplate.tex > todo.tex
	rm -f todo.temp

# shows remaining long strings; work on em manually
longs.txt : todo.raw
	cat todo.raw | tr "|" "\n" | tr "#" "\n" | sed 's/\/.*//' | sort | uniq -c | egrep '[aeiouáéíóúAEIOUÁÉÍÓÚ][^aeiouáéíóúAEIOUÁÉÍÓÚ]+[aeiouáéíóúAEIOUÁÉÍÓÚ]' | sort -r -n > longs.txt

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

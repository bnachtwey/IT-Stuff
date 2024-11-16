# "IT-Stuff" -- just collecting various information on IT related stuff
Either just to document and record for myself or maybe also to share with others ;-)


---
# OT Markdown remarks useful for all the notes made here
- [Markdown documentation] t.b.d.
- [A discussion on special comments](https://github.com/orgs/community/discussions/16925)
- [An german article on _how to use and md basics_](https://www.heise.de/hintergrund/Wie-Sie-mit-Markdown-schnell-und-einfach-Texte-auszeichnen-7222418.html?seite=all), german, behind paywall
- ...


## printing markdown / converting to pdf
using `pandoc` with `wkhtmltopdf` allows to create pdf files:
```bash
apt-get -y install pandoc wkhtmltopdf
```
convert:
```bash
pandoc <your md file>  --from=gfm --pdf-engine=wkhtmltopdf --output <your outputfile>.pdf
```
# Another Alternative: *asciidoc*
- [Heise Article](https://www.heise.de/hintergrund/Documentation-as-Code-mit-Asciidoctor-4642013.html?seite=all)
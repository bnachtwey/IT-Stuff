# "IT-Stuff" -- just collecting various information on IT related stuff
Either just to document and record for myself or maybe also to share with others ;-)

---
# OT printing markdown / converting to pdf
using `pandoc` with `wkhtmltopdf` allows to create pdf files:
```bash
apt-get -y install pandoc wkhtmltopdf
```
convert:
```bash
pandoc <your md file>  --from=gfm --pdf-engine=wkhtmltopdf --output <your outputfile>.pdf
```

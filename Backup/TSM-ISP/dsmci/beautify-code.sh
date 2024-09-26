#! /bin/bash

echo "beautify all perl files:"
echo "1) use dos2uniy and remove silly linefeeds"
echo "2) replace tabs with 8 blanks"

for f in $(ls *.pl)
do
        dos2unix $f
        sed -i 's/\t/        /g' $f
done
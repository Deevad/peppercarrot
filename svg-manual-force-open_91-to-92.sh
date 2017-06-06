#!/bin/bash
# convert Inkscape 0.91 to 0.92.1 SVG translation format, with test and validations.
# Need full path of a SVG as input.

# Header
Off=$'\e[0m'
Red=$'\e[1;31m'
Green=$'\e[1;32m'
Blue=$'\e[1;34m'

export writeissuesvglist="/home/deevad/peppercarrot/refactor/0_write-issue.txt"

while IFS= read -r file
do
   export input=$file
   export svgpath=${input%/*}
   export svgfile=${input##*/}
   
   if [ -f "$file" ]; then
      echo "   => $file "
      if grep -q 'inkscape:version="0.92' "$file"; then
         echo "   Status: ${Green} [0.92] SVG. ${Off}"
      else
         echo "   Status: ${Red} [Old] SVG. ${Off}"
         echo "... Attempt to fix:"
         inkscape --convert-dpi-method=none --verb=ZoomPage --verb=LayerLockAll --verb=FileSave --verb=FileQuit "$file"
         echo "... Pass A."
         inkscape --convert-dpi-method=none --verb=ZoomPage --verb=LayerUnlockAll --verb=FileSave --verb=FileQuit "$file"
         echo "... Pass B."
         echo "... Done."
         if grep -q 'inkscape:version="0.92' "$file"; then
            echo "   Status: ${Green} SVG is fixed. ${Off}"
         else
            echo "   Status: ${Red} SVG still has issues... ${Off}"
         fi
      fi


   else
     echo " * Error: [SVG-READ-ISSUE] $file "
   fi
   
done < "$writeissuesvglist"
exit






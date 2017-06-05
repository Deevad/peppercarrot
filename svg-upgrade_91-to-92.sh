#!/bin/bash
# convert Inkscape 0.91 to 0.92.1 SVG translation format, with test and validations.
# Need full path of a SVG as input.

# Header
Off=$'\e[0m'
Red=$'\e[1;31m'
Green=$'\e[1;32m'
Blue=$'\e[1;34m'

export input=$1
export horodate=$(date +%Y-%m-%d_%Hh%M)
export svgpath=${input%/*}
export svgfile=${input##*/}
export logfile="/home/deevad/peppercarrot/convert-log-history.md"
export svgpathpretty="$(echo $svgpath | sed 's/\/home\/deevad\/peppercarrot\/webcomics\///g')"
export tmppath="/tmp/$horodate-SVGconvert"
export localrenderpath="$svgpath/../../low-res"
export lang=${svgpath: -2:2}
export jpgoldversion=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".jpg"

# Check the SVG input files to fill all our conditions:
# file must exist
if [ -f "$input" ]; then
    # file must be SVG
    if grep -q 'inkscape:version' "$input"; then
       # file must get linked to a previous render.
       if [ -f "$localrenderpath"/"$lang"_"$jpgoldversion" ]; then
          # file must be old SVG.
          if grep -q 'inkscape:version="0.92' "$input"; then
             # file is new SVG: display we browsed it and exit.
             echo "=> [0.92] $svgpathpretty/$svgfile"
             exit
          else
             # file is old SVG.
             # Display informations,log and continue.
             echo "[ $horodate ]" >> $logfile
             echo "${Green}=>${Off} $svgpathpretty/${Blue}$svgfile${Off}"
             echo "=> $svgpathpretty/$svgfile" >> $logfile
             inkscapeversion=$(grep 'inkscape:version' "$input")
             echo "   Type: ${Green}$inkscapeversion ${Off}"
             echo "   Type: $inkscapeversion" >> $logfile
             echo "   Previous render available: ${Green} yes. ${Off}"
             echo "   Previous render available: yes" >> $logfile
             echo "   Lang: ${Green}$lang ${Off}"
             echo "   Lang: $lang" >> $logfile 
          fi
       else
          echo "   Previous render available: ${Red} no. [error] ${Off}"
          echo "   Previous render available: no **[error]**" >> $logfile
          echo "$localrenderpath"/"$lang"_"$jpgoldversion"  
          echo "$localrenderpath"/"$lang"_"$jpgoldversion" >> $logfile
          exit
      fi

    else
      echo "${Red}Error: ${Off} input file is not a SVG. Exit."
      exit
    fi

else
  echo "${Red}Error: ${Off} No or bad input file found. Exit."
  exit
fi

# Start the job
# =============

svgworkfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_092.svg"
pngexport=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_092.png"
jpgexport=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_092.png"
pngcompare=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_compare.png"
gifcompare=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_compare.gif"

mkdir -p /tmp/$horodate-SVGconvert
cp "$svgpath"/"$svgfile" "$svgpath"/"$svgworkfile"

# Open, Save and close in Inkscape. 
# (Unfortunately, needs a click on Ignore button and GUI.)
inkscape --convert-dpi-method=none --verb=FileSave --verb=FileQuit "$svgpath"/"$svgworkfile"
# apply quick 0.92.1 fix already known:
sed -i 's/"0.92.1 unknown"/"0.92.1 renderfarm"/g' "$svgpath"/"$svgworkfile"
sed -i 's/53.089447/56.089447/g' "$svgpath"/"$svgworkfile"
# rebuild viewport size and zoom:
sed -i 's/<metadata/<sodipodi:namedview pagecolor="#ffffff" bordercolor="#666666" inkscape:pageopacity="0" inkscape:pageshadow="2" inkscape:window-width="1813" inkscape:window-height="955" id="namedview70" showgrid="false" inkscape:zoom="0.4" inkscape:cx="1284.4231" inkscape:cy="2618.6204" inkscape:current-layer="layer1" \/><metadata/g' "$svgpath"/"$svgworkfile"

_successactions()
{
# copy tmp SVG with real SVG
mv "$svgpath"/"$svgworkfile" "$svgpath"/"$svgfile"
# check if the file is valid 0.92
if grep -q 'inkscape:version="0.92' "$svgpath"/"$svgfile"; then
   echo "   ${Green}Convertion done.${Off}"
   echo "   Convertion done. $horodate" >> $logfile
else
   echo "   ${Red}[Error]${Off} Writing issue."
   echo "   **[Error]** Writing issue." >> $logfile
   exit  
fi
# spacing for log and console.
echo ""
echo "${Blue}---${Off}"
echo ""
echo "" >> $logfile
echo "---" >> $logfile
echo "" >> $logfile
exit
}

_checkandfix()
{
# Identify possible regressions
# =============================
# export SVG to PNG
inkscape -z "$svgpath"/"$svgworkfile" -e="$tmppath/$pngexport"
# crop if it's a page:
if echo "$tmppath"/"$pngexport" | grep -q 'P[0-9][0-9]' ; then
   convert "$tmppath"/"$pngexport" -colorspace sRGB -chop 0x70 "$tmppath"/"$pngexport"
fi
# resize to old-version size
convert "$tmppath"/"$pngexport" -resize 992x -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -background white -alpha remove -quality 92% "$tmppath"/"$jpgexport"
# Compare to old-version
composite "$localrenderpath"/"$lang"_"$jpgoldversion" "$tmppath"/"$jpgexport" -compose difference "$tmppath"/"$pngcompare"
convert "$tmppath"/"$pngcompare" -brightness-contrast 50x100 "$tmppath"/"$pngcompare"

# file "compare" is rendered
if [ -f "$tmppath"/"$pngcompare" ]; then
   echo "   Compare render: ${Green} done. ${Off}"
   echo "   Compare render: done" >> $logfile

   # Auto detect problematic pictures 
   # ================================
   # (thanks Mc for the method & CalimeroTeknik for simplification ). 
   # Setting: treshold: 200px colored
   autodetection=$(convert "$tmppath"/"$pngcompare" -format "%c" histogram:info: | awk '!/white|black/{ a = a + $1 }END{print (a > 200) ? "0" : "1"}')
   
   if [ $autodetection = 1 ]; then
      echo "   Auto detection: ${Green} Similar. ${Off}"
      echo "   Auto detection: Similar." >> $logfile
      _successactions
   else
      echo "   Auto detection: ${Red} Irregular rendering issue found. ${Off}"
      echo "   Auto detection: Irregular rendering issue found." >> $logfile
      # Request user feedback
      # =====================
      # Make compare easier to read:
      # composite "$tmppath"/"$jpgexport" "$tmppath"/"$pngcompare" -blend 7 -resize 680x "$tmppath"/"$pngcompare"
      convert -delay 50 "$localrenderpath"/"$lang"_"$jpgoldversion" "$tmppath"/"$jpgexport" -resize 680x -loop 0 "$tmppath"/"$gifcompare"
      # display and ask question
      xviewer "$tmppath"/"$gifcompare" & (sleep 0.6 && DISPLAY=:0 wmctrl -F -a "Question" -b add,above -e 0,1300,410,-1,-1) & (DISPLAY=:0 zenity --question --title="Question" --text="Is this OK?")
      # Interpret the feedback:
      if [ $? -eq 0 ] ; then 
         echo "   Convertion feedback: ${Green} success. ${Off}"
         echo "   Convertion feedback: success. $horodate" >> $logfile
         killall xviewer
         _successactions
      else
         echo "   Convertion feedback: ${Red} Failed. ${Off}"
         echo "   Convertion feedback: failed. $horodate" >> $logfile
         inkscape "$svgpath"/"$svgworkfile"
         echo "   Manual fix in Inkscape: Done."
         echo "   Manual fix in Inkscape: Done. $horodate" >> $logfile
         killall xviewer
         # loop checking the file.
         _checkandfix
      fi
   fi
          
else
   echo "   Compare render: ${Red} missing. [imagemagick render error] ${Off}"
   echo "   Compare render: missing **[imagemagick render error]**" >> $logfile
   exit
fi
}

_checkandfix

# cleanup:
rm -rf /tmp/$horodate-SVGconvert

exit






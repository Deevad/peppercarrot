#!/bin/bash
# check the health of a SVG and launch routine fixes

# Header
Off=$'\e[0m'
Red=$'\e[1;31m'
Green=$'\e[1;32m'
Blue=$'\e[1;34m'

export input=$1
export horodate=$(date +%Y-%m-%d_%Hh%M)
export svgpath=${input%/*}
export svgfile=${input##*/}
export logfile="/home/deevad/peppercarrot/""$horodate""_svg-sanifier_log.md"
export svgpathpretty="$(echo $svgpath | sed 's/\/home\/deevad\/peppercarrot\/webcomics\///g')"
export tmppath="/tmp/""$horodate""-SVGconvert"
export lang=${svgpath: -2:2}
export pngfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".png"

# Check the SVG input files to fill all our conditions:
# file must exist
if [ -f "$input" ]; then
    # file must be SVG
    if grep -q 'inkscape:version' "$input"; then
       # we have a SVG, fix permissions
       chmod 755 "$svgpath"/"$svgfile"
       chmod -x "$svgpath"/"$svgfile"
       # fix magic number of failed flowing-texts.
       sed -i 's/53.089447/56.089447/g' "$svgpath"/"$svgfile"
       # rebuild viewport size and zoom:
       # sed -i 's/<metadata/<sodipodi:namedview pagecolor="#ffffff" bordercolor="#666666" inkscape:pageopacity="0" inkscape:pageshadow="2" inkscape:window-width="1813" inkscape:window-height="955" id="namedview70" showgrid="false" inkscape:zoom="0.4" inkscape:cx="1284.4231" inkscape:cy="2618.6204" inkscape:current-layer="layer1" \/><metadata/g' "$svgpath"/"$svgworkfile"
       # Display informations,log and continue.
       echo "[ $horodate ]" >> $logfile
       echo "${Green}=>${Off} $svgpathpretty/${Blue}$svgfile${Off}"
       echo "=> $svgpathpretty/$svgfile" >> $logfile
       inkscapeversion=$(grep 'inkscape:version' "$input")
       echo "   Type: ${Green}$inkscapeversion ${Off}"
       echo "   Type: $inkscapeversion" >> $logfile
       echo "   Lang: ${Green}$lang ${Off}"
       echo "   Lang: $lang" >> $logfile 
       # spacing for log and console.
       echo ""
       echo "${Blue}---${Off}"
       echo ""
       echo "" >> $logfile
       echo "---" >> $logfile
       echo "" >> $logfile
       exit
    else
       echo "${Red}Error: ${Off} input file is not a SVG. Exit."
       exit
    fi
else
  echo "${Red}Error: ${Off} No or bad input file found. Exit."
  exit
fi
exit

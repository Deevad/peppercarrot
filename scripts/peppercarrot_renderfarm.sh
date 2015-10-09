#!/bin/bash

#: Title       : Pepper&Carrot Renderfarm
#: Author      : David REVOY < info@davidrevoy.com >, Mjtalkiewicz (aka Player_2)
#: License     : GPL

scriptversion="2.0"

# -------------------More informations ---------------
# a script to export,clean,backup Pepper&Carrot project folder
# Usage : launch this script in your project directory with all 
# your *.kra pages and lang/en or lang/fr with *.SVG folders
# Result : create and render all the files you need from the source GFX
# ( *.Kra ) and lang ( *.SVG) backup, netexport, cleaning, generating, etc...

# SETUP :
# Eg. a project with 2 pages, 1 cover and two lang (fr and en):
#
# [project folder]
#  * projectname_E01.kra = cover episode 1
#  * projectname_E01P01.kra = page 1
#  * projectname_E01P01.kra = page 2
#          -> [lang]
#                   -> [en] folder
#                       *   projectname_E01.svg
#                       *   projectname_E01P01.svg
#                       *   projectname_E01P02.svg
#                   -> [fr] folder
#                       *   projectname_E01.svg
#                       *   projectname_E01P01.svg
#                       *   projectname_E01P02.svg
#
# HOW TO GET AN EXAMPLE FOLDER :
# episode 7 is small, regular, and a good comic to do a first compile
# Grab the src-gfx ZIP ( 129MB ) here : 
# http://www.peppercarrot.com/en/static6/sources#%20Episode%2007%20:%20The%20Wish
# extract the *.kra files inside a folder
# then still in this folder git-clone the lang-pack in a new folder lang
# git clone https://github.com/Deevad/peppercarrot_ep07_translation.git lang
# then run the script to render your pages

# DEPENDENCIES :
# * Bash
# * Imagemagick
# * Krita (<2.9)
# * Inkscape
# * diff
# * parallel

# SPEC :
# lang project use iso-code two characters.
# Svg files have relative link to generated ../gfx_projectname_E01P01.png

# TODO :
# * [peppecarrot_manager.sh] 'cache' folder is too heavy a copy
#     Idea : maybe store file spec in a txt, then compare txt, eg :
#     ls -l Pepper-and-Carrot_by-David-Revoy_E06.kra > testtxt.txt

# Have fun!
# -----------------------------------------------------

# User preferences:
# Optional module to activate ( 1=yes, 0=no ):
export singlepage_generation=1
export cropping_pages=1
export zip_generation=0

# Low-res horyzontal width, default "992x".
export resizejpg="992x"

# Custom folders names:
export folder_backup="backup"
export folder_cache="cache"
export folder_lang="lang"
export folder_lowres="low-res"
export folder_singlepage="single-page"
export folder_hires="hi-res"
export folder_gfxonly="gfx-only"
export folder_wip="wip"
export folder_zip="zip"

# Utils
export projectname="${PWD##*/}"
export workingpath="${PWD}"
export isodate=$(date +%Y-%m-%d)
export version=$(date +%Y%m%d%H%M)
export versiondaily=$(date +%Y%m%d)
export Off=$'\e[0m'
export Purple=$'\e[1;35m'
export Blue=$'\e[1;34m'
export Green=$'\e[1;32m'
export Red=$'\e[1;31m'
export Yellow=$'\e[1;33m'
export White=$'\e[1;37m'
export BlueBG=$'\e[1;44m'
export RedBG=$'\e[1;41m'
export PurpleBG=$'\e[1;45m'
export Black=$'\e[1;30m'

# Memory token
export gfx_need_regen=0
export svg_need_commit=0

clear

_display_ui()
{
  echo ""
  echo " ${White}${BlueBG}                                                                          ${Off}"
  echo " ${White}${BlueBG}                       -= Pepper&Carrot Renferfarm =-                     ${Off}"
  echo " ${White}${BlueBG}                                                                          ${Off}"
  echo ""
  echo " * version: $scriptversion "
  echo " * projectname: $projectname "
  echo " * workingpath: $workingpath "
  echo ""
}

_setup()
{
  cd "$workingpath"
  
  # Setup : load special rules depending on folder name
  
  if echo "$projectname" | grep -q '_ep01'; then
    echo "${Yellow} [SETUP]${Green} Episode 1 mode${Off}"
    singlepage_generation=0
    cropping_pages=0
  
  elif echo "$projectname" | grep -q '_ep02'; then
    echo "${Yellow} [SETUP]${Green} Episode 2 mode${Off}"
    singlepage_generation=0
    cropping_pages=0
    
  elif echo "$projectname" | grep -q 'New'; then
    echo "${Yellow} [SETUP]${Green} New episode mode${Off}"
    singlepage_generation=1
    cropping_pages=1

  else 
    echo "${Yellow} [SETUP]${Green} Normal mode${Off}"
    singlepage_generation=1
    cropping_pages=1
    
  fi
  
  echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
}

_dir_creation()
{
  cd "$workingpath"
  
  if [ -d "$workingpath/$folder_cache" ]; then
    echo " * $folder_cache found" 
  else
    echo "${Green}* creating folder: $folder_cache ${Off}"
    mkdir -p "$workingpath"/"$folder_cache"
  fi

  if [ -d "$workingpath/$folder_lowres" ]; then
    echo " * $folder_lowres found" 
  else
    echo "${Green}* creating folder: $folder_lowres/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_lowres"/"$folder_gfxonly"
  fi

  if [ -d "$workingpath/$folder_hires" ]; then
    echo " * $folder_hires found" 
  else
    echo "${Green}* creating folder: $folder_hires/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_hires"/"$folder_gfxonly"
  fi

  if [ -d "$workingpath/$folder_backup" ]; then
    echo " * $folder_backup found" 
  else
    echo "${Green}* creating folder: $folder_backup ${Off}"
    mkdir -p "$workingpath"/"$folder_backup"
  fi
  
  if [ -d "$workingpath/$folder_wip" ]; then
    echo " * $folder_wip found" 
  else
    echo "${Green}* creating folder: $folder_wip ${Off}"
    mkdir -p "$workingpath"/"$folder_wip"
  fi
  
  if [ $singlepage_generation = 1 ]; then
    if [ -d "$workingpath/$folder_lowres/$folder_singlepage" ]; then
      echo " * $folder_singlepage found" 
    else
      echo "${Green}* creating folder: $folder_lowres/$folder_singlepage ${Off}"
      mkdir -p "$workingpath"/"$folder_lowres"/"$folder_singlepage"
    fi
  fi
  
  if [ -d "$workingpath/$folder_lang" ]; then
    echo " * $folder_lang found" 
  else
    echo "${Green}* creating folder: $folder_lang ${Off}"
    mkdir -p "$workingpath"/"$folder_lang"
  fi

}

_check_svg()
{
  
  # Check if Git is installed on the machine
  isgitinstalled=`type -t git | wc -l`
  
  if [ $isgitinstalled = 0 ]; then 
    echo "${Green} * Please install Git ${Off}"
  else
  
   echo " * Git found"
   
    # Position cursor inside the lang
    cd "$workingpath"/"$folder_lang"/
    
    # Check for .git folder
    if [ -d "$workingpath"/"$folder_lang"/.git ]; then
          
      # refresh repo to get remote informations
      git remote update
      
      # git tools
      gitlocal=$(git rev-parse @)
      gitremote=$(git rev-parse @{u})
      gitbase=$(git merge-base @ @{u})
      
      # start git update smart decisions
      if [ $gitlocal = $gitremote ]; then
        echo " * $folder_lang is up-to-date"
          
      elif [ $gitlocal = $gitbase ]; then
        echo "${Blue} * $folder_lang is outdated${Off}"
        echo "${Green} ==> [git] git pull ${Off}"
        git pull
                  
      elif [ $gitremote = $gitbase ]; then
        echo "${Purple} * $folder_lang contains commit non pushed${Off}"
          
      else
        echo "${Red} * $folder_lang error: diverging repositories${Off}"
      fi
        
    else
      echo " * $folder_lang is not a Git repository ${Off}"
    fi
  
  fi
  
  # Position cursor inside the lang
  cd "$workingpath"/"$folder_lang"/
  
  for langdir in */; do
  
    # Clean lang folder name, remove trailing / character
    langdir="${langdir%%?}"
    
    # Position cursor inside the current lang
    cd "$workingpath"/"$folder_lang"/"$langdir"/

    # New loop : we process the SVG of the current lang dir
    for svgfile in *.svg; do

      # Sanify test for SVG coming from Inkscape on Windows, writing problematic path:
      if grep -q 'xlink:href=".*.\\gfx_' "$svgfile"; then
        echo "${Green} ==> [fix] $svgfile ${Off}"
        echo "${Red}      (-)"
        grep 'xlink:href="' "$svgfile"
        echo "${Off}"
        
        # run sed twice in case of two images embed, rare but might happen
        sed -i 's/xlink:href=".*.\\gfx/xlink:href="..\/gfx/g' "$svgfile"
        sed -i 's/xlink:href=".*.\\gfx/xlink:href="..\/gfx/g' "$svgfile"
        
        echo "${Green}      (+)"
        grep 'xlink:href="' "$svgfile"
        echo "${Off}"
        
        # Update token to trigger a reminder at the end of script; SVG were auto-modified.
        export svg_need_commit=1
      fi

    done
  done
  
  echo ""
}

_update_gfx_gif_work()
{
  giffile=$1
  pngfile=$(echo $giffile|sed 's/\(.*\)\..\+/\1/')".png"

  # Compare if gif file changed
  if diff "$workingpath"/"$giffile" "$workingpath"/"$folder_cache"/"$giffile" &>/dev/null ; then
    echo " ==> [gif] $giffile] is up-to-date."
  else
    echo " ${Green}==> [gif] $giffile new or modified: rendered. ${Off}"

    # Update cache
    cp "$workingpath"/"$giffile" "$workingpath"/"$folder_cache"/"$giffile"
    cd "$workingpath"/"$folder_lang"/

    for langdir in */;
    do
      # Clean folder, remove trailing / character
      langdir="${langdir%%?}"

      # Spread the gfx gif as it is in all the pages (gifs have no translations)
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$langdir"_"$giffile"
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$folder_gfxonly"/gfx_"$giffile"
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$langdir"_"$giffile"
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$folder_gfxonly"/gfx_"$giffile"

      # Ensure to reset on folder_lang on the start of the loop
      cd "$workingpath"/"$folder_lang"/

      # Convert to PNG , for being in the singlepage loop (later) this version needs a padding top and botton.
      gifframe1="$workingpath"/"$folder_cache"/"$giffile"[0]
      convert $gifframe1 -bordercolor white -border 0x20 -colorspace sRGB "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

      # Copy lowres PNG gfx for lang proxy SVG
      convert $gifframe1 -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lang"/gfx_"$pngfile"
      
      # Create a dummy file token to indicate what lang where changed
      touch "$workingpath"/"$folder_cache"/"$langdir"/need_render
      
    done
  fi
}

_update_gfx_kra_work()
{
  krafile=$1
  cd "$workingpath"
  pngfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".png"
  jpgfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".jpg"
  svgfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".svg"
  jpgfileversionning=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')_$version".jpg"

  # Compare if kra file changed
  if diff "$workingpath"/"$krafile" "$workingpath"/"$folder_cache"/"$krafile" &>/dev/null ; then
    echo " ==> [kra] $krafile file is up-to-date."
  else
    echo "${Green} ==> [kra] $krafile is new or modified, rendered. ${Off}"

    # Duplicate *.kra to cache
    cp "$workingpath"/"$krafile" "$workingpath"/"$folder_cache"/"$krafile"

    # Generate PNG hi-res in cache
    krita --export "$workingpath"/"$folder_cache"/"$krafile" --export-filename "$workingpath"/"$folder_cache"/gfx_"$pngfile"

    # Check if we are not processing the cover/thumbnail, comparing with a mask pattern.
    if [ "$krafile" = *_E??.kra ]; then
      convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lowres"/"$jpgfile"
    fi

    # Update PNG hires gfx-only folder
    cp "$workingpath"/"$folder_cache"/gfx_"$pngfile" "$workingpath"/"$folder_hires"/"$folder_gfxonly"/gfx_"$pngfile"

    # Generate low-res *.png in lang
    convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lang"/gfx_"$pngfile"

    # Generate low-res gfx_file.jpg in low-res/gfx-only
    convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lowres"/"$folder_gfxonly"/gfx_"$jpgfile"

    # Copy a backup of kra
    cp "$workingpath"/"$folder_cache"/"$krafile" "$workingpath"/"$folder_backup"/"$version"_"$krafile"

    # Generate WIP jpg : full res, JPG, 92%, no lang
    convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_wip"/"$jpgfileversionning"

    # Update lang of selected changed file
    echo "${Green}     Rendering now linked translations: ${Off}"

    cd "$workingpath"/"$folder_lang"/

    for langdir in */; do
    
      # Clean folder, remove trailing / character
      langdir="${langdir%%?}"

      # Ensure to reset on folder_lang on the start of the loop
      cd "$workingpath"/"$folder_lang"/

      # Position cursor inside the current cache/lang
      cd "$workingpath"/"$folder_cache"/"$langdir"/
      
      # Create a dummy file token to indicate what lang where changed
      touch "$workingpath"/"$folder_cache"/"$langdir"/need_render

      # Verbose
      echo " ${Green}    ==> [$langdir] $svgfile rendered ${Off}"

      # Do we have a SVG file with same name as our KRA ?
      if [ -d "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" ]; then
        # Yes. Final hi-res PNG print with lang prefix
        inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
      else
        # No. Transmit the gfx-only version high res. Muted page exist.
        cp "$workingpath"/"$folder_cache"/gfx_"$pngfile" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"          
      fi

      # Final hi-res PNG print with lang prefix
      inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

      # Copy PNG full-res to proper hires folder
      cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" "$workingpath"/"$folder_hires"/"$langdir"_"$pngfile"

      # Generate WIP (Work-in-Progress) jpg : full res, JPG, 92%, no lang. For keeping track later of modification in WIP folder.
      convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_wip"/"$jpgfileversionning"

      # Crop our hi-res PNG pages for better online web layout
      if [ $cropping_pages = 1 ]; then
      
        # Rule to exclude cover from being cropped :
        if echo "$pngfile" | grep -q 'P[0-9][0-9]' ; then
          convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -colorspace sRGB -chop 0x70 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
        else
          echo "* Cover artwork = not crop."
        fi
        
      fi

      # Final low-res JPG for online with lang prefix, unsharp and correct quality, generated on cache
      convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"

      # Copy the final JPG to proper lowres folder
      cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$langdir"_"$jpgfile"

    done
  fi
}

_update_gfx()
{
  # Method to update change in graphical file
  # Trying to be smart and consume the less power, but more disk space.
  # Only file changed are reprocessed thanks to the folder cache

  echo "${Yellow} [GFX]${Off}"
  echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
  
  # Project should contain *.kra artworks anyway
  cd "$workingpath"
  export -f _update_gfx_kra_work
  ls -1 *.kra | parallel _update_gfx_kra_work "{}"
  
  # Project might contain *.gif animation
  cd "$workingpath"
  getamountofgif=`ls -1 *.gif | wc -l`
  if [ $getamountofgif != 0 ]; then 
    export -f _update_gfx_gif_work
    ls -1 *.gif | parallel _update_gfx_gif_work "{}"
  fi

}

_update_lang_work()
{
  cd "$workingpath"/"$folder_lang"/
  langdir=$1
  
  # Clean lang folder name, remove trailing / character
  langdir="${langdir%%?}"

  # Ensure to reset on folder_lang on the start of the loop
  cd "$workingpath"/"$folder_lang"/

  # Compare if langage folder changed compare to the version we cached in cache/lang/lang
  if diff -r "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir" &>/dev/null ; then
    echo " ==> [$langdir] folder is up-to-date."
  else
    echo "${Green} ==> [$langdir] is new or modified ${Off}"

    # Remove existing lang on cache, sanify folder
    if [ -d "$workingpath/$folder_cache/$langdir" ]; then
      rm -R "$workingpath"/"$folder_cache"/"$langdir"
    fi

    cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"
    cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"

    # Position cursor inside the current cache/lang
    cd "$workingpath"/"$folder_cache"/"$langdir"/

    # New loop : we process the SVG of the current lang dir
    for svgfile in *.svg; do
      pngfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".png"
      jpgfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".jpg"
      
      # Verbose for Inkscape feedback
      echo " ${Green}    [$langdir] $svgfile rendered ${Off}"

      # Final hi-res PNG print with lang prefix
      inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

      # Save PNG full page on hires
      cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" "$workingpath"/"$folder_hires"/"$langdir"_"$pngfile"

      # Crop our hi-res PNG pages for better online web layout
      if [ $cropping_pages = 1 ]; then
        if echo "$pngfile" | grep -q 'P[0-9][0-9]' ; then
          convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -colorspace sRGB -chop 0x70 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
        else
          echo "* Cover artwork = not crop."
        fi
      fi

      # Final low-res JPG with lang prefix
      convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"

      # Save JPG web page on lowres
      cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$langdir"_"$jpgfile"
      
      # Create a dummy file token to indicate what lang where changed
      touch "$workingpath"/"$folder_cache"/"$langdir"/need_render

    done
  fi
}


_update_lang()
{
  # Method to catch a change or addition in langage
  # Can be activated as a standalone class when comic
  # Gfx are stable and doesn't change a lot.
  
  echo ""
  echo "${Yellow} [LANG] ${Off}"
  echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

  export -f _update_lang_work
  cd "$workingpath"/"$folder_lang"/ && ls -1d */ | parallel _update_lang_work "{}"
}

_create_singlepage_work()
{
  cd "$workingpath"/"$folder_lang"/
  langdir=$1

  # Repositioning to the main folder
  cd "$workingpath"
    
  # Create the name, relative to the cover kra name.
  for krafile in *.kra; do
    if [ "$krafile" = *_E??.kra ]; then
      jpgfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')"XXL.jpg"
    fi
  done
  
  # Repositioning to the cache/lang folder
  cd "$workingpath"/"$folder_cache"/"$langdir"/
  
  for langdir in */; do

    # Clean folder, remove trailing / character
    langdir="${langdir%%?}"
        
    # if dummy file token exist in lang folder cached, we need to re-render then clean dummy.
    if [ -f "$workingpath"/"$folder_cache"/"$langdir"/need_render ]; then
      echo "${Green} ==> [$langdir] $langdir_$jpgfile rendered${Off}"
      
      # create the montage with imagemagick from all PNG found with a page pattern in cache folder.
      montage -mode concatenate -tile 1x *P??.png -colorspace sRGB -quality 92% -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"
      
      # copy the rendering in the final folder
      cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$folder_singlepage"/"$langdir"_"$jpgfile"
      
      # remove dummy file when job is done
      rm "$workingpath"/"$folder_cache"/"$langdir"/need_render
      
    else
      echo " ==> [$langdir] $langdir_$jpgfile is up-to-date."
    fi
    
  done
}
_create_singlepage()
{
  # Method to create a long strip
  # A vertical montage of all pages
    
  echo ""
  echo "${Yellow} [SINGLEPAGE]${Off}"
  echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
  
  export -f _create_singlepage_work
  cd "$workingpath"/"$folder_lang"/ && ls -1d */ | parallel _create_singlepage_work "{}"
}

_create_zip_collection()
{
  # Method to create pack of zips for the website, ready to upload.
  echo ""
  echo "${Yellow}[ZIP]${Off}"
  echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

  # Do we really need to repack if nothing changed ?
  if [ $gfx_need_regen = 1 ]; then
    # Generating folder:
    cd "$workingpath"
      
    if [ -d "$workingpath/$folder_zip" ]; then
      echo "* $folder_zip found" 
    else
      mkdir -p "$workingpath"/"$folder_zip"
      echo "${Green}* creating folder: $folder_zip ${Off}"
    fi
      
    # Find the project name, thanks vignette/cover filename.
    for krafile in *.kra; do
      if [ "$krafile" = *_E??.kra ]; then
        episodename=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')""
      fi
    done
    
    cd "$workingpath"
    
    # Verbose, job description
    echo " ${Yellow}[gfx] ${Off}"
    echo " ${Yellow}==> ${Blue}src-gfx_""$episodename""_$version.zip ${Green} archiving ${Off}"
    zip "$folder_zip"/src-gfx_"$episodename" *.kra *.gif

  else
    echo " ${Yellow}[Zip Packing]${Off} Not needed, up-to-date "
  fi
}

# Runtime counter: start
renderfarm_runtime_start=$(date +"%s")

# Execute
_display_ui
_setup
_dir_creation
_check_svg
_update_gfx
_update_lang

# Execute ( modular options, depends setup )
if [ $singlepage_generation = 1 ]; then
  _create_singlepage
fi
    
if [ $zip_generation = 1 ]; then
  _create_zip_collection
fi

# Runtime counter: end and math
renderfarm_runtime_end=$(date +"%s")
diff_runtime=$(($renderfarm_runtime_end-$renderfarm_runtime_start))

# End User Interface messages
echo ""
echo " * $projectname rendered in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Reminder in case of SVG auto-modified
if [ $svg_need_commit = 1 ]; then
  echo " * SVG with wrong path were found and autofixed."
fi

echo ""

# Notification for system when out-of-focus
notify-send "Pepper&Carrot Renderfarm" "$projectname rendered in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Task is executed inside a terminal
# This line prevent terminal windows to be closed
# Necessary to read log later
echo -n " Press [Enter] to exit"
read end

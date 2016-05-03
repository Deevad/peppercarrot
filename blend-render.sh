#!/bin/bash

#: Title       : Pepper&Carrot BLENDrender
#: Author      : David REVOY < info@davidrevoy.com >, Mjtalkiewicz (aka Player_2)
#: License     : GPL

scriptversion="0.1"

# Custom folders names:
export folder_backup="backup"
export folder_cache="cache"
export folder_lowres="low-res"
export folder_hires="hi-res"
export folder_wip="wip"
export folder_zip="zip"

# Utils
export projectname="${PWD##*/}"
export workingpath="${PWD}"
export isodate=$(date +%Y-%m-%d)
export version=$(date +%Y-%m-%d_%Hh%M)
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

# Windows title
printf "\033]0;%s\007\n" "*Render: $projectname"

clear

_display_ui()
{
  echo ""
  echo " ${White}${BlueBG}                                                                ${Off}"
  echo " ${White}${BlueBG}                       -= Blend Renferfarm =-                   ${Off}"
  echo " ${White}${BlueBG}                                                                ${Off}"
  echo ""
  echo " * version: $scriptversion "
  echo " * projectname: $projectname "
  echo " * workingpath: $workingpath "
  echo ""
}

_dir_creation()
{
  cd "$workingpath"
  
  if [ -d "$workingpath/$folder_cache" ]; then
    echo " * $folder_cache found" 
  else
    echo "${Green} * creating folder: $folder_cache ${Off}"
    mkdir -p "$workingpath"/"$folder_cache"
  fi

  if [ -d "$workingpath/$folder_lowres" ]; then
    echo " * $folder_lowres found" 
  else
    echo "${Green} * creating folder: $folder_lowres/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_lowres"
  fi

  if [ -d "$workingpath/$folder_hires" ]; then
    echo " * $folder_hires found" 
  else
    echo "${Green} * creating folder: $folder_hires/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_hires"
  fi

  if [ -d "$workingpath/$folder_backup" ]; then
    echo " * $folder_backup found" 
  else
    echo "${Green} * creating folder: $folder_backup ${Off}"
    mkdir -p "$workingpath"/"$folder_backup"
  fi
  
  if [ -d "$workingpath/$folder_wip" ]; then
    echo " * $folder_wip found" 
  else
    echo "${Green} * creating folder: $folder_wip ${Off}"
    mkdir -p "$workingpath"/"$folder_wip"
  fi
  
  if [ -d "$workingpath/$folder_zip" ]; then
    echo " * $folder_zip found" 
  else
    echo "${Green} * creating folder: $folder_zip ${Off}"
    mkdir -p "$workingpath"/"$folder_zip"
  fi
}

_update_blend_work()
{
  blendfile=$1
  cd "$workingpath"
  txtfile=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')".txt"
  pngfile=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')".png"
  renderfile=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')"#####.png"
  renderedfile=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')"00001.png"
  jpgfile=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')".jpg"
  zipfile=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')"_peppercarrot.zip"
  blend_tmpfolder=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')""
  jpgfileversionning=$(echo $blendfile|sed 's/\(.*\)\..\+/\1/')_$version".jpg"
  rendermefile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"-renderme.txt"

  # Read the checksum of *.blend file
  md5read="`md5sum $blendfile`"
  
  # Avoid grep to fail if no file found
  if [ -f "$workingpath"/"$folder_cache"/"$txtfile" ]; then
    true
  else
    touch "$workingpath"/"$folder_cache"/"$txtfile"
  fi
  
  # Compare if actual *.blend checksum is similar to the previous one recorded on txtfile
  if grep -q "$md5read" "$workingpath"/"$folder_cache"/"$txtfile"; then
    echo " ==> [blend] $blendfile file is up-to-date."
  else
    echo "${Green} ==> [blend] $blendfile is new or modified, rendered. ${Off}"

    # Update the cache with a new version
    md5sum "$blendfile" > "$workingpath"/"$folder_cache"/"$txtfile"
    
    # Render the PNG hi-res directly with Blender
    #
    # blender -b "$blendfile" -o "$workingpath"/"$folder_cache"/"$renderfile" --python "$workingpath"/arg.py -F PNG -f 1
    # content of arg.py
    # import bpy
    #   for scene in bpy.data.scenes:
    #   scene.render.resolution_x = 210
    #   scene.render.resolution_y = 210
    blender -b "$blendfile" -o "$workingpath"/"$folder_cache"/"$renderfile" -F PNG -f 1
    
    #Simplify name
    mv "$workingpath"/"$folder_cache"/"$renderedfile" "$workingpath"/"$folder_cache"/"$pngfile"
    
    # Hi-resolution
    convert "$workingpath"/"$folder_cache"/"$pngfile" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 95% "$workingpath"/"$folder_hires"/"$jpgfile"

    # Low-resolution
    convert "$workingpath"/"$folder_cache"/"$pngfile" -resize 1100x900 -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lowres"/"$jpgfile"

    # Update Backup
    cp "$workingpath"/"$blendfile" "$workingpath"/"$folder_backup"/"$version"_"$blendfile"
    
    # Update WIP
    convert "$workingpath"/"$folder_cache"/"$pngfile" -colorspace sRGB -background white -alpha remove -quality 95% "$workingpath"/"$folder_wip"/"$jpgfileversionning"
    
    # Update ZIP
    cd "$workingpath"
    zip "$folder_zip"/"$zipfile" "$blendfile"

  fi
}

_update_gfx()
{
  # Method to update change in graphical file
  # Trying to be smart and consume the less power, but more disk space.
  # Only file changed are reprocessed thanks to the folder cache

  echo "${Yellow} [GFX]${Off}"
  echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
  
  # Project should contain *.blend artworks anyway
  cd "$workingpath"
  export -f _update_blend_work
  ls -1 *.blend | parallel _update_blend_work "{}"
}

_clean_cache()
{
  cd "$workingpath"/"$folder_cache"/
  
  # clean up files
  rm -f "$workingpath"/"$folder_cache"/*.png
  
}

# Runtime counter: start
renderfarm_runtime_start=$(date +"%s")

# Execute
_display_ui
_dir_creation
_update_gfx
_clean_cache

# Runtime counter: end and math
renderfarm_runtime_end=$(date +"%s")
diff_runtime=$(($renderfarm_runtime_end-$renderfarm_runtime_start))

# End User Interface messages
echo ""
echo " * $projectname rendered in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."
echo ""

# Notification for system when out-of-focus
notify-send "blendRender" "$projectname rendered in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Windows title
printf "\033]0;%s\007\n" "Render: $projectname"

# Task is executed inside a terminal
# This line prevent terminal windows to be closed
# Necessary to read log later
echo -n " Press [Enter] to exit"
read end

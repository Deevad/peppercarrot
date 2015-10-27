#!/bin/bash

#: Title       : Pepper&Carrot Renderfarm
#: Author      : David REVOY < info@davidrevoy.com >, Mjtalkiewicz (aka Player_2)
#: License     : GPL

scriptversion="5.0"

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
  
  if echo "$projectname" | grep -q 'ep01'; then
    echo "${Yellow} [SETUP]${Green} Episode 1 mode${Off}"
    singlepage_generation=0
    cropping_pages=0
  
  elif echo "$projectname" | grep -q 'ep02'; then
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
    echo "${Green} * creating folder: $folder_cache ${Off}"
    mkdir -p "$workingpath"/"$folder_cache"
  fi

  if [ -d "$workingpath/$folder_lowres" ]; then
    echo " * $folder_lowres found" 
  else
    echo "${Green} * creating folder: $folder_lowres/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_lowres"/"$folder_gfxonly"
  fi

  if [ -d "$workingpath/$folder_hires" ]; then
    echo " * $folder_hires found" 
  else
    echo "${Green} * creating folder: $folder_hires/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_hires"/"$folder_gfxonly"
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
  
  if [ $singlepage_generation = 1 ]; then
    if [ -d "$workingpath/$folder_lowres/$folder_singlepage" ]; then
      echo " * $folder_singlepage found" 
    else
      echo "${Green} * creating folder: $folder_lowres/$folder_singlepage ${Off}"
      mkdir -p "$workingpath"/"$folder_lowres"/"$folder_singlepage"
    fi
  fi
  
  if [ -d "$workingpath/$folder_lang" ]; then
    echo " * $folder_lang found" 
  else
    echo "${Green} * creating folder: $folder_lang ${Off}"
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
        echo "${Green} ==> [fix] [$langdir] $svgfile ${Off}"
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

_update_gfx_kra_work()
{
  krafile=$1
  cd "$workingpath"
  txtfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".txt"
  pngfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".png"
  jpgfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".jpg"
  svgfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')".svg"
  jpgfileversionning=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')_$version".jpg"
  rendermefile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"-renderme.txt"

  # Read the checksum of *.kra file
  md5read="`md5sum $krafile`"
  
  # Avoid grep to fail if no file found
  if [ -f "$workingpath"/"$folder_cache"/"$txtfile" ]; then
    true
  else
    touch "$workingpath"/"$folder_cache"/"$txtfile"
  fi
  
  # Compare if actual *.kra checksum is similar to the previous one recorded on txtfile
  if grep -q "$md5read" "$workingpath"/"$folder_cache"/"$txtfile"; then
    echo " ==> [kra] $krafile file is up-to-date."
  else
    echo "${Green} ==> [kra] $krafile is new or modified, rendered. ${Off}"

    # Update the cache with a new version
    md5sum "$krafile" > "$workingpath"/"$folder_cache"/"$txtfile"
    
    # Generate PNG hi-res in cache
    krita --export "$workingpath"/"$krafile" --export-filename "$workingpath"/"$folder_cache"/gfx_"$pngfile"
    
    # test
    # unzip -j "$workingpath"/"$krafile" "mergedimage.png" -d "$workingpath"/"$folder_cache"
    # mv "$workingpath"/"$folder_cache"/"mergedimage.png" "$workingpath"/"$folder_cache"/gfx_"$pngfile"

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
    cp "$workingpath"/"$krafile" "$workingpath"/"$folder_backup"/"$version"_"$krafile"

    # Generate WIP jpg : full res, JPG, 92%, no lang
    convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_wip"/"$jpgfileversionning"

    cd "$workingpath"/"$folder_lang"/

    for langdir in */; do
    
      # Clean folder, remove trailing / character
      langdir="${langdir%%?}"
      
        # Create folder
        mkdir -p "$workingpath"/"$folder_cache"/"$langdir"
        
        # Position cursor inside the current folder
        cd "$workingpath"/"$folder_cache"/"$langdir"/
        
        # Create a dummy file token to indicate singlepage to render
        touch "$workingpath"/"$folder_cache"/"$langdir"/need_render.txt
        
        # Send a renderme token to let know update_lang_work he has rendering work to do
        touch "$workingpath"/"$folder_cache"/"$langdir"/"$rendermefile"
        
    done
  fi
}

_update_gfx_gif_work()
{
  giffile=$1
  pngfile=$(echo $giffile|sed 's/\(.*\)\..\+/\1/')".png"

  # Compare if gif file changed
  if diff "$workingpath"/"$giffile" "$workingpath"/"$folder_cache"/"$giffile" &>/dev/null ; then
    echo " ==> [gif] $giffile is up-to-date."
  else
    echo " ${Green}==> [gif] $giffile new or modified: rendered. ${Off}"

    # Update cache
    cp "$workingpath"/"$giffile" "$workingpath"/"$folder_cache"/"$giffile"
    
    # Ensure to reset on folder_lang on the start of the loop
    cd "$workingpath"/"$folder_lang"/

    for langdir in */;
    do
      # Clean folder, remove trailing / character
      langdir="${langdir%%?}"
      
      # Prevent missing lang folder at a first run
      mkdir -p "$workingpath"/"$folder_cache"/"$langdir"

      # Spread the Gif as it is in all the pages (gifs have no translations)
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$langdir"_"$giffile"
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$folder_gfxonly"/gfx_"$giffile"
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$langdir"_"$giffile"
      cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$folder_gfxonly"/gfx_"$giffile"

      # New strategy for static image to the Gif panel alternative ( for print, for single page )
      # Does we have an alternative PNG static file next to the Gif ?
      if [ -f "$workingpath"/"$pngfile" ]; then
        # Yes. We copy it.
        cp "$workingpath"/"$pngfile" "$workingpath"/"$folder_lang"/gfx_"$pngfile"
      else
        # No. alternative PNG files were found, we need to auto-generate one ( using the first frame of the gif-anim).
        gifframe1="$workingpath"/"$folder_cache"/"$giffile"[0]
        convert "$gifframe1" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lang"/gfx_"$pngfile"
      fi
      
      # Create a dummy file token to indicate what lang where changed
      touch "$workingpath"/"$folder_cache"/"$langdir"/need_render.txt
      
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
  getamountofgif=`ls -1 *.gif 2>/dev/null | wc -l`
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

    # Check if the target folder exist in case of a new lang
    if [ -d "$workingpath/$folder_cache/$langdir" ]; then
      true
    else
      mkdir -p "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"
      
      # If a new lang folder exist, we need to also copy it's *.gif to low-res
      cd "$workingpath"
      getamountofgif=`ls -1 *.gif 2>/dev/null | wc -l`
      if [ $getamountofgif != 0 ]; then 
        for giffile in *.gif; do
          cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$langdir"_"$giffile"
          cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$folder_gfxonly"/gfx_"$giffile"
          cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$langdir"_"$giffile"
          cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$folder_gfxonly"/gfx_"$giffile"
        done
      fi

    fi
    
    # Position cursor inside the current cache/lang
    cd "$workingpath"/"$folder_lang"/"$langdir"/

    # New loop : we process the SVG of the current lang dir
    for svgfile in *.svg; do
      pngfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".png"
      jpgfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".jpg"
      rendermefile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"-renderme.txt"
      
      # Compare if langage folder changed compare to the version we cached in cache/lang/lang
      if diff "$workingpath"/"$folder_lang"/"$langdir"/"$svgfile" "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" &>/dev/null ; then
       true
      else
        touch "$workingpath"/"$folder_cache"/"$langdir"/"$rendermefile"
      fi
      
      # Check if there is not a ready made renderme token ready
      if [ ! -f "$workingpath"/"$folder_cache"/"$langdir"/"$rendermefile" ]; then
        true
      else

        echo "${Green} ==> [$langdir] $svgfile is new or modified ${Off}"
        
        # Copy the fresh SVG in the cache, along the Hi-Res PNG gfx, for a hi-res rendering
        cp "$workingpath"/"$folder_lang"/"$langdir"/"$svgfile" "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile"

        # Final hi-res PNG print with lang prefix
        inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
        
        # Optimize PNG test : Note , -define png:compression-strategy=zs , -define png:compression-level=zl, -define png:compression-filter=fm
        convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -define png:compression-strategy=3  -define png:compression-level=9 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

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
        touch "$workingpath"/"$folder_cache"/"$langdir"/need_render.txt
        
        # Check if the target folder exist in case of a new lang
        if [ -d "$workingpath/$folder_cache/$langdir" ]; then
          true
        else
          mkdir -p "$workingpath"/"$folder_cache"/"$langdir"
        fi
        
      fi
    done
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
  
  # Clean folder, remove trailing / character
  langdir="${langdir%%?}"

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
      
  # if dummy file token exist in lang folder cached, we need to re-render then clean dummy.
  if [ -f "$workingpath"/"$folder_cache"/"$langdir"/need_render.txt ]; then
    echo "${Green} ==> [$langdir] $langdir_$jpgfile rendered${Off}"
    
    # If project get updated *.gif , copy before generating the single page, but as static PNG to be catched by the montage wild mask *.png loop
    cd "$workingpath"
    getamountofgif=`ls -1 *.gif 2>/dev/null | wc -l`
    if [ $getamountofgif != 0 ]; then 
      for giffile in *.gif; do
      pngfile=$(echo $giffile|sed 's/\(.*\)\..\+/\1/')".png"
      jpgfile=$(echo $giffile|sed 's/\(.*\)\..\+/\1/')".jpg"
      # New strategy for static image to the Gif panel alternative ( for print, for single page )
      # Does we have an alternative PNG static file next to the Gif ?
      if [ -f "$workingpath"/"$pngfile" ]; then
        # Yes. We copy it.
        cp "$workingpath"/"$pngfile" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
      else
        # No. alternative PNG files were found, we need to auto-generate one ( using the first frame of the gif-anim).
        gifframe1="$workingpath"/"$folder_cache"/"$giffile"[0]
        convert "$gifframe1" -bordercolor white -border 0x20 -colorspace sRGB "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
      fi
      convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -colorspace sRGB -quality 92% -resize "$resizejpg" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"
      done
    fi
    
    # Repositioning in the hi-res folder
    cd "$workingpath"/"$folder_hires"/
    
    # Get temporary all the PNG hi-res in cache for fusion
    cp "$langdir"*.png "$workingpath"/"$folder_cache"/"$langdir"/
    
    # Repositioning to the cache/lang folder
    cd "$workingpath"/"$folder_cache"/"$langdir"/
      
    # create the montage with imagemagick from all PNG found with a page pattern in cache folder.
    montage -mode concatenate -tile 1x *P??.png -colorspace sRGB -quality 92% -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"
    
    # copy the rendering in the final folder
    cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$folder_singlepage"/"$langdir"_"$jpgfile"
    
  else
    echo " ==> [$langdir] $langdir_$jpgfile is up-to-date."
  fi
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

_clean_cache()
{
  cd "$workingpath"/"$folder_cache"/

  for langdir in */; do

    # Clean folder, remove trailing / character
    langdir="${langdir%%?}"
    
    # Repositioning to the cache/lang folder
    cd "$workingpath"/"$folder_cache"/"$langdir"/
      
    # clean up
    rm -f "$workingpath"/"$folder_cache"/"$langdir"/*.png
    rm -f "$workingpath"/"$folder_cache"/"$langdir"/*.jpg
    rm -f "$workingpath"/"$folder_cache"/"$langdir"/*.txt
    
  done
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

_clean_cache

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

# Windows title
printf "\033]0;%s\007\n" "Render: $projectname"

# Task is executed inside a terminal
# This line prevent terminal windows to be closed
# Necessary to read log later
echo -n " Press [Enter] to exit"
read end

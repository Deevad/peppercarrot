#!/bin/bash

#: Title       : Pepper&Carrot Renderfarm
#: Author      : David REVOY < info@davidrevoy.com >
#: License     : GPL

scriptversion="1.0"

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
# Module to activate ( 1=yes, 0=no ):
export singlepage_generation=1
export cropping_pages=1
export zip_generation=0

# imagemagic, (eg. "992x", "865x", no percent )
export resizejpg="992x"

#custom folders names:
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
echo "   ${White}${BlueBG}            [ Pepper&Carrot Manager  ]              ${Off}"
echo "   ${White}${BlueBG}                 version $scriptversion                        ${Off}"
echo "   ${White}${BlueBG}                 by David Revoy                     ${Off}"
echo ""
echo " projectname: $projectname "
echo " workingpath: $workingpath "
echo ""
}

_setup()
{
    cd "$workingpath"
    
    # Setup : load special rules depending on folder name
    
    if echo "$projectname" | grep -q '_ep01';
    then
    echo "${Yellow} [SETUP]${Off} Episode 1 mode"
    singlepage_generation=0
    cropping_pages=0
    
    elif echo "$projectname" | grep -q '_ep02';
    then
    echo "${Yellow} [SETUP]${Off} Episode 2 mode"
    singlepage_generation=0
    cropping_pages=0
    
    elif echo "$projectname" | grep -q 'New';
    then
    echo "${Yellow} [SETUP]${Off} New episode mode"
    singlepage_generation=1
    cropping_pages=1

    else 
    echo "${Yellow} [SETUP]${Off} Normal mode"
    singlepage_generation=1
    cropping_pages=1
    fi
    
    echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"


}

_dir_creation()
{
    cd "$workingpath"
    
    if [ -d "$workingpath/$folder_cache" ]; then
    echo "* $folder_cache found" 
    else
    echo "${Green}* creating folder: $folder_cache ${Off}"
    mkdir -p "$workingpath"/"$folder_cache"
    fi

    if [ -d "$workingpath/$folder_lang" ]; then
    echo "* $folder_lang found" 
    else
    echo "${Green}* creating folder: $folder_lang ${Off}"
    mkdir -p "$workingpath"/"$folder_lang"
    fi

    if [ -d "$workingpath/$folder_lowres" ]; then
    echo "* $folder_lowres found" 
    else
    echo "${Green}* creating folder: $folder_lowres/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_lowres"/"$folder_gfxonly"
    fi

    if [ -d "$workingpath/$folder_hires" ]; then
    echo "* $folder_hires found" 
    else
    echo "${Green}* creating folder: $folder_hires/$folder_gfxonly ${Off}"
    mkdir -p "$workingpath"/"$folder_hires"/"$folder_gfxonly"
    fi

    if [ -d "$workingpath/$folder_backup" ]; then
    echo "* $folder_backup found" 
    else
    echo "${Green}* creating folder: $folder_backup ${Off}"
    mkdir -p "$workingpath"/"$folder_backup"
    fi
    
    if [ -d "$workingpath/$folder_wip" ]; then
    echo "* $folder_wip found" 
    else
    echo "${Green}* creating folder: $folder_wip ${Off}"
    mkdir -p "$workingpath"/"$folder_wip"
    fi
    
    echo ""
}

_update_gfx_gif_work()
{
    giffile=$1
    pngfile=$(echo $giffile|sed 's/\(.*\)\..\+/\1/')".png"

    # compare if gif file changed
    if diff "$workingpath"/"$giffile" "$workingpath"/"$folder_cache"/"$giffile" &>/dev/null ; then
    #no
        echo " ${Yellow}==> ${Blue}[$giffile]${Off} is up-to-date."

    else
    #yes
        echo " ${Yellow}==> ${Green}[$giffile] changed ==> Copying and regenerating flat PNG version ${Off}"

        #update token
        gfx_need_regen=1

        #update cache
        cp "$workingpath"/"$giffile" "$workingpath"/"$folder_cache"/"$giffile"

        cd "$workingpath"/"$folder_lang"/

        for langdir in */;
        do

            # clean folder, remove trailing / character
            langdir="${langdir%%?}"

            # Check if lang get update, or copy them
            if diff -r "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir" &>/dev/null ; then
            #no
                echo " ${Yellow}==> ${Blue}[$langdir]${Off} lang repo is up-to-date."

            else
            #yes
                echo " ${Yellow}==> ${Blue}[$langdir] new or changed ${Green} Regenerating ${Off}"

                #update lang on cache, where the png linked is hi-res
                if [ -d "$workingpath/$folder_cache/$langdir" ]; then
                    rm -R "$workingpath"/"$folder_cache"/"$langdir"
                else
                    echo "${Blue}==> ${Yellow} creating $langdir: ${Off}"
                fi

                cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"
                cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"
            fi

            # spread the gfx gif as it is in the pages
            cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$langdir"_"$giffile"
            cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_lowres"/"$folder_gfxonly"/gfx_"$giffile"
            cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$langdir"_"$giffile"
            cp "$workingpath"/"$folder_cache"/"$giffile"  "$workingpath"/"$folder_hires"/"$folder_gfxonly"/gfx_"$giffile"

            # ensure to reset on folder_lang on the start of the loop
            cd "$workingpath"/"$folder_lang"/

            # Convert to PNG , for being in the singlepage loop (later) this version needs a padding top and botton.
            gifframe1="$workingpath"/"$folder_cache"/"$giffile"[0]
            convert $gifframe1 -bordercolor white -border 0x20 -colorspace sRGB "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

            # copy lowres PNG gfx for lang proxy SVG
            convert $gifframe1 -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lang"/gfx_"$pngfile"
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

    # compare if kra file changed
    if diff "$workingpath"/"$krafile" "$workingpath"/"$folder_cache"/"$krafile" &>/dev/null ; then
    #no
        echo " ${Yellow}==> ${Blue} $krafile ${Off} is up-to-date."

    else
        #yes
        echo " ${Green}==> ${Blue} $krafile ${Green} changed ==> Regenerating with Krita ${Off}"

        #update token
        gfx_need_regen=1

        # duplicate *.kra to cache
        cp "$workingpath"/"$krafile" "$workingpath"/"$folder_cache"/"$krafile"

        # generate PNG hi-res in cache
        krita --export "$workingpath"/"$folder_cache"/"$krafile" --export-filename "$workingpath"/"$folder_cache"/gfx_"$pngfile"

        # check if we are not processing the cover/thumbnail, comparing with a mask pattern.
        if [ "$krafile" = *_E??.kra ]; then
            convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lowres"/"$jpgfile"
        fi

        # update PNG hires gfx-only folder
        cp "$workingpath"/"$folder_cache"/gfx_"$pngfile" "$workingpath"/"$folder_hires"/"$folder_gfxonly"/gfx_"$pngfile"

        # generate low-res *.png in lang
        convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lang"/gfx_"$pngfile"

        # generate low-res gfx_file.jpg in low-res/gfx-only
        convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% "$workingpath"/"$folder_lowres"/"$folder_gfxonly"/gfx_"$jpgfile"

        # copy a backup of kra
        cp "$workingpath"/"$folder_cache"/"$krafile" "$workingpath"/"$folder_backup"/"$version"_"$krafile"

        # generate WIP jpg : full res, JPG, 92%, no lang
        convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_wip"/"$jpgfileversionning"

        #update lang of selected changed file
        echo ""
        echo "${Blue} [ gfx_$pngfile ]${Yellow} Inspecting translation status  ${Off}"
        echo "${Yellow} =-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=${Off}"

        cd "$workingpath"/"$folder_lang"/

        for langdir in */;
        do
        # clean folder, remove trailing / character
        langdir="${langdir%%?}"

        # verbose, a langage was found
        echo " ${Yellow}[$langdir] ${Off}"

        # ensure to reset on folder_lang on the start of the loop
        cd "$workingpath"/"$folder_lang"/

        # compare if langage folder changed compare to the version we cached in cache/lang/lang
        if diff -r "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir" &>/dev/null ; then
        #no
            echo " ${Yellow}==> ${Blue}[$langdir] ${Off} folder is up-to-date."

        else
        #yes
            echo " ${Yellow}==> ${Blue}[$langdir] new or changed ${Green} Regenerating ${Off}"

            #update lang on cache, where the png linked is hi-res
            if [ -d "$workingpath/$folder_cache/$langdir" ]; then
                rm -R "$workingpath"/"$folder_cache"/"$langdir"
            else
                echo "${Blue}==> ${Yellow} creating $langdir: ${Off}"
            fi

            cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"
            cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"
        fi

        # position cursor inside the current cache/lang
        cd "$workingpath"/"$folder_cache"/"$langdir"/

        # verbose
        echo " ${Yellow}==> ${Green}[$langdir] $svgfile ==> Exporting ${Off}"

        # do we have a SVG file with same name as our KRA ?
        if [ -d "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" ]; then
        # Yes. Final hi-res PNG print with lang prefix
            inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
        else
        # No. transmit the gfx-only version high res. Maybe no translation needed ? ( muted page )
            cp "$workingpath"/"$folder_cache"/gfx_"$pngfile" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"          
        fi

        # Final hi-res PNG print with lang prefix
        inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

        # Save PNG full page on hires
        cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" "$workingpath"/"$folder_hires"/"$langdir"_"$pngfile"

        # generate WIP jpg : full res, JPG, 92%, no lang
        convert "$workingpath"/"$folder_cache"/gfx_"$pngfile" -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_wip"/"$jpgfileversionning"

        #crop our hi-res page for web
        if [ $cropping_pages = 1 ]; then

            # rule to exclude cover from being cropped :
            if echo "$pngfile" | grep -q 'P[0-9][0-9]' ; then
                echo "${Blue} -> ${Yellow} Cropping ${Off}"
                convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -colorspace sRGB -chop 0x70 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
            else
                echo "${Blue}[info] ${Off} cover artwork, doesn't need cropping."
            fi

        fi

        # Final low-res JPG with lang prefix
        convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"

        # Save JPG web page on lowres
        cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$langdir"_"$jpgfile"

        done
    fi
}

_update_gfx()
{
    # Method to update change in graphical file
    # trying to be smart and consume the less power, but more disk space.
    # ( only file changed are reprocessed thanks to a cache )

    # project might contain *.gif animation
    getamountofgif=`ls -1 *.gif 2&>/dev/null | wc -l`
    if [ $getamountofgif != 0 ]
    then 

    echo "${Yellow} [GFX]${Off} render *.gif"
    echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

    export -f _update_gfx_gif_work
    ls -1 *.gif | parallel _update_gfx_gif_work "{}"

    fi

    echo "${Yellow} [GFX]${Off} render *.kra"
    echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
    
    cd "$workingpath"
    
    export -f _update_gfx_kra_work
    ls -1 *.kra | parallel _update_gfx_kra_work "{}"
    
}

_update_lang_work()
{
    cd "$workingpath"/"$folder_lang"/
    langdir=$1
    # clean folder, remove trailing / character
    langdir="${langdir%%?}"

    # ensure to reset on folder_lang on the start of the loop
    cd "$workingpath"/"$folder_lang"/

    # compare if langage folder changed compare to the version we cached in cache/lang/lang
    if diff -r "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir" &>/dev/null ; then
        #no
        echo "${Yellow}[$langdir] ${Off} folder is up-to-date."

    else
        #yes
        echo "${Green}[$langdir] new or changed, regenerating ${Off}"

        #update token
        gfx_need_regen=1

        #update lang on cache, where the png linked is hi-res
        if [ -d "$workingpath/$folder_cache/$langdir" ]; then
            rm -R "$workingpath"/"$folder_cache"/"$langdir"
        else
            echo "${Blue}==> ${Yellow} creating $langdir: ${Off}"
        fi

        cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"
        cp -R "$workingpath"/"$folder_lang"/"$langdir" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"

        # position cursor inside the current cache/lang
        cd "$workingpath"/"$folder_cache"/"$langdir"/

        # New loop : we process the SVG of the current lang dir
        for svgfile in *.svg;
        do

            pngfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".png"
            jpgfile=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')".jpg"

            # verbose
            echo " ${Yellow}==> ${Green}[$langdir] ==> [$svgfile] ==> Inkscape export ${Off}"

            # sanify test for SVG coming from Inkscape on Windows, writing problematic path:
            if grep -q 'xlink:href=".*.\\gfx_' "$svgfile"; then
                echo " ${Blue}=> ${Yellow}[AUTO FIXING] $svgfile${Off}"
                echo "${Red} (-)"
                grep 'xlink:href="' "$svgfile"
                echo "${Off}"
                sed -i 's/xlink:href=".*.\\gfx/xlink:href="..\/gfx/g' $svgfile
                echo "${Green} (+)"
                grep 'xlink:href="' "$svgfile"
                echo "${Off}"
                #update token
                svg_need_commit=1
            fi

            # Final hi-res PNG print with lang prefix
            inkscape -z "$workingpath"/"$folder_cache"/"$langdir"/"$svgfile" -e="$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"

            # Save PNG full page on hires
            cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" "$workingpath"/"$folder_hires"/"$langdir"_"$pngfile"

            #crop our hi-res page for web
            if [ $cropping_pages = 1 ]; then
                if echo "$pngfile" | grep -q 'P[0-9][0-9]' ; then
                    echo "${Blue} -> ${Yellow} Cropping ${Off}"
                    convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -colorspace sRGB -chop 0x70 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile"
                else
                    echo "${Blue}[info] ${Off} cover artwork, doesn't need cropping."
                fi
            fi

            # Final low-res JPG with lang prefix
            convert "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$pngfile" -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -background white -alpha remove -quality 92% "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"

            # Save JPG web page on lowres
            cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$langdir"_"$jpgfile"

        done
    fi
}


_update_lang()
{
    # Method to catch a change or addition in langage
    # can be activated as a standalone class when comic
    # gfx are stable and doesn't change a lot.
    
    echo ""
    echo "${Yellow} [LANG] ${Off}"
    echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
    
    export -f _update_lang_work
    cd "$workingpath"/"$folder_lang"/ && ls -1d */ | parallel _update_lang_work "{}"

    
}

_create_singlepage_work()
{
    cd "$workingpath"/"$folder_lang"/
    langdir=$1
    # clean folder, remove trailing / character
    langdir="${langdir%%?}"

    # repositioning the main folder
    cd "$workingpath"

    for krafile in *.kra;
    do
        # check if the pattern of vignette is existing for copying the short name.
        if [ "$krafile" = *_E??.kra ]; then
            jpgfile=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')"XXL.jpg"
        fi
    done

    # repositioning the cache/lang folder
    cd "$workingpath"/"$folder_cache"/"$langdir"/

    # Final low-res singlepage with cache for speed:
    if diff "$workingpath"/"$folder_lowres"/"$folder_singlepage"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" &>/dev/null ; then
        #no
        echo "${Yellow}[$langdir] ${Off} ${Blue} $langdir_$jpgfile ${Off} is up-to-date."
    else
        #yes
        echo "${Yellow}[$langdir] ${Off} ${Blue} $langdir_$jpgfile ${Green} Regenerating ${Off}"

        montage -mode concatenate -tile 1x *P??.png -colorspace sRGB -quality 92% -resize "$resizejpg" -unsharp 0.48x0.48+0.50+0.012 "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile"

        cp "$workingpath"/"$folder_cache"/"$langdir"/"$langdir"_"$jpgfile" "$workingpath"/"$folder_lowres"/"$folder_singlepage"/"$langdir"_"$jpgfile"
    fi
}
_create_singlepage()
{
    # Method to create a long strip
    # for reshare, or single image viewer like deviantArt
      
    echo ""
    echo "${Yellow} [SINGLEPAGE]${Off}"
    echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
    
    # generating folder:
    cd "$workingpath"
    if [ -d "$workingpath/$folder_lowres/$folder_singlepage" ]; then
    echo "" 
    else
    mkdir -p "$workingpath"/"$folder_lowres"/"$folder_singlepage"
    echo "${Green}* creating folder: $folder_lowres/$folder_singlepage ${Off}"
    fi
    
    export -f _create_singlepage_work
    cd "$workingpath"/"$folder_lang"/ && ls -1d */ | parallel _create_singlepage_work "{}"

}

_create_zip_collection()
{
    # Method to create pack of zips for the website, ready to upload.
    echo ""
    echo "${Yellow}[ZIP]${Off}"
    echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

    # do we really need to repack if nothing changed ?
    if [ $gfx_need_regen = 1 ]; then
        # generating folder:
        cd "$workingpath"
        
        if [ -d "$workingpath/$folder_zip" ]; then
        echo "* $folder_zip found" 
        else
        mkdir -p "$workingpath"/"$folder_zip"
        echo "${Green}* creating folder: $folder_zip ${Off}"
        fi
        
        # find the project name, thanks vignette/cover filename.
        for krafile in *.kra;
        do
            if [ "$krafile" = *_E??.kra ]; then
                episodename=$(echo $krafile|sed 's/\(.*\)\..\+/\1/')""
            fi
        done
        

        
        cd "$workingpath"

        #pseudocode logique
        #zip *.gif and *.kra and readme.md in zip/src_gfx_nameoftheepisode_version154545.zip
        #zip -R lang in zip/src_lang_nameoftheepisode154545.zip

        # verbose, job description
        echo " ${Yellow}[gfx] ${Off}"
        echo " ${Yellow}==> ${Blue}src-gfx_""$episodename""_$version.zip ${Green} archiving ${Off}"
        zip "$folder_zip"/src-gfx_"$episodename" *.kra *.gif
        
        # verbose, job description
        # echo " ${Yellow}[lang] ${Off}"
        # echo " ${Yellow}==> ${Blue}lang folder ${Green} archiving ${Off}"
        # zip -r "$folder_zip"/src-lang_"$episodename" lang
        # echo " ${Yellow}[Zip Packing]${Off} Job done "

    else
    echo " ${Yellow}[Zip Packing]${Off} Not needed, up-to-date "
    fi
}

_display_ui
_setup
_dir_creation
_update_gfx
_update_lang

# modules
    if [ $singlepage_generation = 1 ]; then
        _create_singlepage
    fi
    
    if [ $zip_generation = 1 ]; then
        _create_zip_collection
    fi
    
echo ""
echo "   ${White}${BlueBG}       Task for $projectname done.        ${Off}"
echo ""

    if [ $svg_need_commit = 1 ]; then
        echo ""
        echo " ${Red}/!\ WARNING  /!\ ${Off}"
        echo " ${Yellow} Problematic SVG were found and autofixed.${Off}"
        echo ""
    fi

notify-send "Task for $projectname done" -t 5000
echo -n "Press [Enter] to exit"
read end

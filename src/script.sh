#!/bin/bash

playlistUrl="https://www.youtube.com/playlist?list=WL"
cookiesBrowser="vivaldi"
scriptFolder="$(pwd)"
downloadFolder="$scriptFolder/downloads"
archiveFile="$scriptFolder/archive.txt"
logFile="$scriptFolder/log.txt"
videoFile="$downloadFolder/%(title)s [%(id)s].%(ext)s"

if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
  echo "$(date +"%Y-%m-%d %H:%M:%S"): the script is running" >> "$logFile"; exit;
fi

if [ ! -d "$downloadFolder" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S"): creating downloads folder at $downloadFolder"
    mkdir -p "$downloadFolder"
fi

echo "$(date +"%Y-%m-%d %H:%M:%S"): retrieving playlist information..." >> "$logFile"
playlistInfo=$(yt-dlp --flat-playlist --print-json --cookies-from-browser "$cookiesBrowser" "$playlistUrl")
playlistVideos=($(echo "$playlistInfo" | jq -r '.id'))

echo "$(date +"%Y-%m-%d %H:%M:%S"): checking local files..." >> "$logFile"
for file in "$downloadFolder"/*; do
    if [[ -f "$file" ]]; then
        baseName=$(basename "$file")
        if [[ "$baseName" =~ \[([^\]]+)\] ]]; then
            id="${BASH_REMATCH[1]}"
            if [[ ! " ${playlistVideos[@]} " =~ " $id " ]]; then
                if [[ -f "$archiveFile" ]]; then
                    searchVideoId="youtube $id"
                    archiveContent=$(<"$archiveFile")
                    if grep -q "$searchVideoId" <<< "$archiveContent"; then
                        echo "$(date +"%Y-%m-%d %H:%M:%S"): removing id $id from archive file..." >> "$logFile"
                        grep -v "$searchVideoId" "$archiveFile" > "$archiveFile.tmp" && mv "$archiveFile.tmp" "$archiveFile"
                    fi
                fi
                echo "$(date +"%Y-%m-%d %H:%M:%S"): deleting file $file" >> "$logFile"
                rm -f "$file"
            fi
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S"): skipped: $baseName"
        fi
    fi
done

echo "$(date +"%Y-%m-%d %H:%M:%S"): downloading new videos..." >> "$logFile"

yt-dlp --force-write-archive --download-archive "$archiveFile" "$playlistUrl" --cookies-from-browser "$cookiesBrowser" -o "$videoFile"

echo "Done."
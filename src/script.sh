#!/bin/bash

playlistUrl="https://www.youtube.com/playlist?list=WL"
cookiesBrowser="vivaldi"
scriptFolder="$(pwd)"
downloadFolder="$scriptFolder/downloads"
archiveFile="$scriptFolder/archive.txt"
logFile="$scriptFolder/log.txt"
videoFile="$downloadFolder/%(title)s [%(id)s].%(ext)s"

log() {
    local level="$1"
    local message="$2"
    local debug_enabled="false"
    
    if [[ "$level" == "DBG" && "$debug_enabled" != "true" ]]; then
        return
    fi

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp][$level] $message"
    echo "[$timestamp][$level] $message" >> "$logFile"
}

if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
  log "WRN" "the script is currently running";
  exit;
fi

if [ ! -d "$downloadFolder" ]; then
    log "INF" "creating downloads folder at $downloadFolder"
    mkdir -p "$downloadFolder"
fi

log "INF" "retrieving playlist information..."

playlistInfo=$(yt-dlp --flat-playlist --print-json "$playlistUrl")
log "DBG" "playlistInfo: $playlistInfo"
playlistVideos=($(echo "$playlistInfo" | jq -r '.id'))

log "INF" "${#playlistVideos[@]} videos found."

if [ "${#playlistVideos[@]}" -eq 0 ]; then
    log "ERR" "No videos found in the playlist or failed to retrieve playlist information.";
    exit;
fi

log "INF" "checking local files..."
shopt -s dotglob  # includes hidden files 
for file in "$downloadFolder"/*; do
    log "DBG" "$file" 
    if [[ -f "$file" ]]; then
        baseName=$(basename "$file")
        log "DBG" "$baseName" 
        if [[ "$baseName" =~ \[([^\]]{11})\] ]]; then
            id="${BASH_REMATCH[1]}"
            log "DBG" "$id"
            if [[ ! " ${playlistVideos[@]} " =~ " $id " ]]; then
                if [[ -f "$archiveFile" ]]; then
                    searchVideoId="youtube $id"
                    archiveContent=$(<"$archiveFile")
                    if grep -q "$searchVideoId" <<< "$archiveContent"; then
                        log "INF" "removing id $id from archive file..."
                        grep -v "$searchVideoId" "$archiveFile" > "$archiveFile.tmp" && mv "$archiveFile.tmp" "$archiveFile"
                    fi
                fi
                log "WRN" "deleting file $file"
                rm -f "$file"
            fi
        else
            log "INF" "skipped: $baseName"
        fi
    fi
done
shopt -u dotglob  # exclude hidden files

log "INF" "downloading new videos..."
yt-dlp --force-write-archive --download-archive "$archiveFile" "$playlistUrl" -o "$videoFile"
log "INF" "done."
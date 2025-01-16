$playlistUrl = "https://www.youtube.com/playlist?list=WL"
$cookiesBrowser = "vivaldi"
$scriptFolder = "$PSScriptRoot"
$downloadFolder= "$scriptFolder\downloads"
$archiveFile = "$scriptFolder\archive.txt"
$logFile = "$scriptFolder\log.txt"
$videoFile = "$downloadFolder\%(title)s [%(id)s].%(ext)s"

if(!(test-path -PathType container $downloadFolder))
{
    New-Item -ItemType Directory -Path $downloadFolder
}

Write-Host "Retrieving playlist information..."
$playlistInfo = yt-dlp --flat-playlist --print-json --cookies-from-browser $cookiesBrowser $playlistUrl | ConvertFrom-Json

$playlistVideos = @()
foreach ($video in $playlistInfo) {
    $playlistVideos += $video.id
}

Write-Host "Checking local files..."
$localFiles = Get-ChildItem -Path $downloadFolder
foreach ($file in $localFiles) {

    $matches=[regex]::Matches($file.BaseName, '\[([^\]]+)\]')
    if($matches.Count -eq 0){
        Write-Host "Skipped: $($file.Name)"
        continue
    }
    $id = $matches[$matches.Count - 1].Groups[1].Value

    if ($playlistVideos -notcontains $id) {
        if (Test-Path $archiveFile) {
            $archiveContent = Get-Content $archiveFile
            $searchVideoId="youtube $id"
            if ($archiveContent -contains $searchVideoId) {
                Write-Host "Removing ID $id from archive.txt"
                $updatedContent = $archiveContent | Where-Object { $_ -ne $searchVideoId }
                $updatedContent | Set-Content -Path $archiveFile
            }
        }

        Write-Host "Deleting...: $($file.FullName)"
        Remove-Item -LiteralPath $file.FullName -Force
    }

    # Remove the ID from archive.txt
}

Write-Host "Downloading new videos..."
yt-dlp --force-write-archive --download-archive $archiveFile $playlistUrl --cookies-from-browser $cookiesBrowser -o $videoFile

exit
#Read-Host -Prompt "Press any key to exit!"
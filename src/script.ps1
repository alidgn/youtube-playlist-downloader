$playlistUrl = "https://www.youtube.com/playlist?list=WL"
$cookiesBrowser = "vivaldi"
$downloadFolder = "$PSScriptRoot"
$archiveFile = "$downloadFolder/archive.txt"
$videoFile = "$downloadFolder/%(title)s [%(id)s].%(ext)s"

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
        Write-Host "Deleting...: $($file.FullName)"
        Remove-Item -LiteralPath $file.FullName -Force
    }
}

Write-Host "Downloading new videos..."
yt-dlp --force-write-archive --download-archive $archiveFile $playlistUrl --cookies-from-browser $cookiesBrowser -o $videoFile

exit
#Read-Host -Prompt "Press any key to exit!"
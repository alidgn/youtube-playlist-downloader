# YouTube "Watch Later" Playlist Sync Script

This PowerShell script automates the process of managing and syncing your "Watch Later" YouTube playlist by:

- Downloading videos from the playlist.
- Deleting locally stored videos if they are no longer in the playlist.
- Keeping track of downloaded videos to avoid re-downloading.

## Features

1. **Playlist Information Retrieval**: Retrieves all video IDs in the "Watch Later" playlist.
2. **Local File Management**: Compares downloaded videos against the playlist and deletes files not present in the playlist.
3. **New Video Downloading**: Downloads new videos added to the playlist using `yt-dlp`.
4. **Cookies Management**: Uses cookies from the Vivaldi browser to handle YouTube authentication.

## Prerequisites

1. **PowerShell**: Ensure you have PowerShell installed on your system.
2. **yt-dlp**: Install `yt-dlp` for video downloading. [Download yt-dlp](https://github.com/yt-dlp/yt-dlp)
3. **Browser**: Ensure your youtube.com cookies are accessible from the browser.
4. **JSON Parsing**: Ensure PowerShell has the `ConvertFrom-Json` cmdlet available.

## Installation and Setup

1. Clone this repository.
2. Open PowerShell and navigate to the script’s directory.
3. Modify the following variables in the script as needed:
   - `$playlistUrl`: URL of the "Watch Later" playlist.
   - `$cookiesBrowser`: Browser to use for cookies (default: `vivaldi`).
   - `$downloadFolder`: Directory to store downloaded videos.

## How to Use

1. Open PowerShell and navigate to the script’s directory.
2. Run the script by executing:
   ```powershell
   .\script.ps1
   ```
3. The script will:
   - Fetch the playlist information.
   - Compare local files to the playlist.
   - Delete videos not in the playlist.
   - Download new videos from the playlist.

## Configuration Variables

- **`$playlistUrl`**: The URL of your "Watch Later" playlist.
- **`$cookiesBrowser`**: The browser to extract cookies from (default: `vivaldi`).
- **`$downloadFolder`**: Path to the folder where videos will be saved.
- **`$archiveFile`**: File used to track downloaded videos.
- **`$videoFile`**: Naming convention for downloaded videos.

## Notes

- Ensure you have the necessary permissions to delete files in the specified `$downloadFolder`.
- The script is configured to use `yt-dlp` and assumes it is installed and accessible in the system PATH.
- Use this script responsibly and ensure compliance with YouTube’s terms of service.

## Troubleshooting

1. **yt-dlp Command Not Found**: Ensure `yt-dlp` is installed and added to your system PATH.
2. **Permission Denied**: Run PowerShell as an administrator if you encounter permission issues.
3. **Cookies Not Found**: Verify that cookies are accessible from the specified browser.

Enjoy syncing your YouTube "Watch Later" playlist effortlessly!
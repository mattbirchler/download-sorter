# download-sorter

An AppleScript that organizes your Downloads folder by sorting files into date-based folders.

## What it does

- Moves files into `YYYY-MM` folders based on their "date added" metadata
- Leaves files from the current month in place
- Within each month folder, sorts media into subfolders:
  - `Images/` - jpg, png, gif, heic, svg, etc.
  - `Videos/` - mp4, mov, avi, mkv, etc.
  - `Music/` - mp3, wav, flac, m4a, etc.
- Other files and folders stay in the main month folder

## Usage

Run `SortDownloads.scpt` from Script Editor or via `osascript`:

```bash
osascript SortDownloads.scpt
```

You can also set it up as a Folder Action or schedule it with launchd/cron.

# FILE ORGANIZER

> Smart • Safe • Automatic File Management

A lightweight Windows utility that automatically organizes files into category folders based on their file extensions.

## Features

- Automatic file categorization
- Preview / Dry Run mode
- Duplicate filename protection
- Never overwrites an existing destination file
- Non-recursive scanning
- Does not move the organizer itself
- No third-party software required
- No internet connection required
- Windows 10 / Windows 11 compatible
- Professional console interface

## Categories

Documents, Spreadsheets, Presentations, PDFs, Text, Images, Videos, Music, Applications, Disk Images, Archives, Shortcuts, Fonts, Subtitles, Web Files, and Other.

## Usage

1. Copy `Hasif_File_Organizer.bat` into the folder you want to organize.
2. Run the BAT file.
3. Choose **Preview Files** first.
4. If the preview is correct, choose **Organize Files** and confirm with `Y`.

The script only processes files directly inside the folder containing the BAT file. Existing subfolders are not scanned.

## Safety

- Files are never deleted.
- Existing files are never overwritten.
- Duplicate names are renamed as `file (1).ext`, `file (2).ext`, etc.
- `.exe` files are moved, not executed.
- No network access or file upload is performed.

## Technical Notes

The BAT file creates a temporary PowerShell script at runtime to perform reliable local file operations, then removes that temporary script. This keeps the distribution as a single BAT file while improving handling of Windows paths and duplicate names.

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell

No Python or third-party packages are required.

## Customization

Extension mappings are defined in the `:CREATE_PS` section of the BAT file. Add entries such as:

```powershell
'.epub'='Documents'
```

## Author

**Hasif Khan**

Copyright © 2026 Hasif Khan. All Rights Reserved.

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE).

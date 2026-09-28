@echo off
REM ============================================================
REM FILE ORGANIZER
REM Smart • Safe • Automatic File Management
REM
REM Version : 1.0.0
REM Author  : Hasif Khan
REM Year    : 2026
REM
REM Copyright © 2026 Hasif Khan.
REM All Rights Reserved.
REM
REM This software is provided for personal and authorized use.
REM Redistribution or modification should retain the original
REM copyright and author attribution.
REM ============================================================
REM
REM ARCHITECTURE (why PowerShell is used inside this BAT file)
REM ------------------------------------------------------------
REM Plain Batch cannot reliably handle Unicode file names, names
REM containing ! % & ^ [ ] characters, collision-free renaming
REM such as "report (1).docx", or an accurate progress bar.
REM
REM This file is therefore a thin BAT launcher plus an embedded
REM PowerShell engine stored at the bottom of THIS SAME FILE
REM (after the line that starts with "#" and "@@PAYLOAD@@").
REM
REM   * Only ONE file is needed - no .ps1 file is created.
REM   * Nothing is downloaded, installed or sent anywhere.
REM   * Windows PowerShell 5.1 ships with Windows 10 / 11.
REM   * No administrator rights are required.
REM ============================================================

setlocal EnableExtensions DisableDelayedExpansion
title FILE ORGANIZER

REM ============================================================
REM EXTENSION CONFIGURATION
REM ============================================================
REM Format : set "HFO_CAT_NN=Folder Name|.ext1 .ext2 .ext3"
REM
REM   NN            Two-digit number. Controls display order.
REM   Folder Name   Folder created inside the organized folder.
REM   Extensions    Separated by spaces, each starting with a dot.
REM                 Case does not matter.
REM
REM To add an extension : append it to the matching line.
REM To add a category   : copy any line, give it a NEW number
REM                       (e.g. 17) and edit the name/extensions.
REM Files that match nothing are moved to the folder "Other".
REM ============================================================
set "HFO_CAT_01=Documents|.doc .docx .odt .rtf"
set "HFO_CAT_02=Spreadsheets|.xls .xlsx .xlsm .csv .ods"
set "HFO_CAT_03=Presentations|.ppt .pptx .pps .ppsx .odp"
set "HFO_CAT_04=PDFs|.pdf"
set "HFO_CAT_05=Text|.txt .log .md .ini .cfg"
set "HFO_CAT_06=Images|.jpg .jpeg .png .gif .bmp .webp .svg .tif .tiff .ico .heic"
set "HFO_CAT_07=Videos|.mp4 .mkv .avi .mov .wmv .flv .webm .m4v .3gp"
set "HFO_CAT_08=Music|.mp3 .wav .flac .aac .m4a .ogg .wma"
set "HFO_CAT_09=Applications|.exe .msi .appx .msix"
set "HFO_CAT_10=Disk Images|.iso .img .vhd .vhdx"
set "HFO_CAT_11=Archives|.zip .rar .7z .tar .gz .bz2"
set "HFO_CAT_12=Shortcuts|.lnk .url"
set "HFO_CAT_13=Fonts|.ttf .otf .woff .woff2"
set "HFO_CAT_14=Subtitles|.srt .ass .ssa .vtt"
set "HFO_CAT_15=Web Files|.html .htm .css .js .json .xml"
REM ============================================================
REM END OF EXTENSION CONFIGURATION
REM ============================================================

REM --- Automatic folder detection: the folder holding this BAT file
set "HFO_TARGET=%~dp0"
set "HFO_SELF=%~f0"

REM --- Make sure Windows PowerShell is available
where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo.
    echo   [ERROR] Windows PowerShell was not found on this computer.
    echo           HASIF FILE ORGANIZER requires Windows 10 or Windows 11.
    echo.
    pause
    exit /b 1
)

REM --- Start the embedded engine (reads the payload section of this file)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:HFO_SELF,[Text.Encoding]::UTF8);$m='#'+'@@PAYLOAD@@';$i=$s.LastIndexOf($m);if($i -lt 0){Write-Host 'Embedded engine not found. The file may be damaged.';exit 1};Invoke-Expression ($s.Substring($i))"

endlocal
exit /b 0

#@@PAYLOAD@@
# ====================================================================
#  FILE ORGANIZER - EMBEDDED ENGINE (PowerShell)
#  Everything below this line is never read by cmd.exe.
#  This section is ASCII-only on purpose: special characters (box
#  lines, bullets, arrows) are created from character codes, so the
#  program displays correctly no matter how the file was saved.
# ====================================================================

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

$OldEncoding = $null
try { $OldEncoding = [Console]::OutputEncoding; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { $Host.UI.RawUI.WindowTitle = 'HASIF FILE ORGANIZER' } catch {}

# --------------------------------------------------------------------
#  APPLICATION IDENTITY
# --------------------------------------------------------------------
$AppName    = 'FILE ORGANIZER'
$AppVersion = '1.0.0'
$AppAuthor  = 'Hasif Khan'
$AppYear    = '2026'

# Display glyphs (built from code points)
$Bullet   = [string][char]0x2022
$Copy     = [string][char]0x00A9
$Arrow    = [string][char]0x2192
$chTL     = [string][char]0x2554
$chTR     = [string][char]0x2557
$chBL     = [string][char]0x255A
$chBR     = [string][char]0x255D
$chH      = [string][char]0x2550
$chV      = [string][char]0x2551
$chML     = [string][char]0x2560
$chMR     = [string][char]0x2563
$chLine   = [string][char]0x2500
$chFull   = [string][char]0x2588
$chEmpty  = [string][char]0x2591

$Tagline       = "Smart $Bullet Safe $Bullet Automatic File Management"
$CopyrightLine = "$Copy $AppYear $AppAuthor. All Rights Reserved."
$BoxW          = 62          # inner width of every box

# --------------------------------------------------------------------
#  TARGET FOLDER  (set by the BAT launcher from %~dp0)
# --------------------------------------------------------------------
$Target = $env:HFO_TARGET
try { $Target = (Get-Item -LiteralPath $env:HFO_TARGET -ErrorAction Stop).FullName } catch {}
if ($Target.Length -gt 3) { $Target = $Target.TrimEnd('\') }
$SelfPath = $env:HFO_SELF

# --------------------------------------------------------------------
#  LOAD CATEGORY / EXTENSION CONFIGURATION (from the BAT section)
# --------------------------------------------------------------------
$OtherName  = 'Other'
$Categories = [ordered]@{}
$ExtMap     = @{}

Get-ChildItem Env: | Where-Object { $_.Name -like 'HFO_CAT_*' } | Sort-Object Name | ForEach-Object {
    $parts = $_.Value -split '\|', 2
    if ($parts.Count -lt 2) { return }
    $catName = $parts[0].Trim()
    if (-not $catName) { return }
    $list = @()
    foreach ($e in ($parts[1] -split '\s+')) {
        if (-not $e) { continue }
        $e = $e.ToLowerInvariant()
        if (-not $e.StartsWith('.')) { $e = '.' + $e }
        $list += $e
        if (-not $ExtMap.ContainsKey($e)) { $ExtMap[$e] = $catName }
    }
    $Categories[$catName] = $list
}
$CategoryOrder = @($Categories.Keys)
$AllFolders    = @($CategoryOrder) + $OtherName

# --------------------------------------------------------------------
#  UI HELPERS
# --------------------------------------------------------------------
$PageSize = 16
try { $PageSize = [Math]::Max(8, $Host.UI.RawUI.WindowSize.Height - 12) } catch {}
$script:PageLines = 0

function Say {
    param([string]$Text = '', [string]$Color = 'Gray')
    Write-Host $Text -ForegroundColor $Color
}

function Write-BoxTop    { Write-Host ($chTL + ($chH * $BoxW) + $chTR) -ForegroundColor DarkCyan }
function Write-BoxBottom { Write-Host ($chBL + ($chH * $BoxW) + $chBR) -ForegroundColor DarkCyan }
function Write-BoxSep    { Write-Host ($chML + ($chH * $BoxW) + $chMR) -ForegroundColor DarkCyan }

function Write-BoxRow {
    param([string]$Text = '', [string]$Align = 'Center', [string]$Color = 'White')
    if ($Text.Length -gt ($BoxW - 4)) { $Text = $Text.Substring(0, $BoxW - 4) }
    if ($Align -eq 'Center') { $left = [int][Math]::Floor(($BoxW - $Text.Length) / 2) } else { $left = 3 }
    $right = $BoxW - $Text.Length - $left
    if ($right -lt 0) { $right = 0 }
    Write-Host $chV -NoNewline -ForegroundColor DarkCyan
    Write-Host ((' ' * $left) + $Text + (' ' * $right)) -NoNewline -ForegroundColor $Color
    Write-Host $chV -ForegroundColor DarkCyan
}

function Write-BoxTitle {
    param([string]$Title)
    Write-BoxTop
    Write-BoxRow $Title 'Center' 'White'
    Write-BoxBottom
}

function Write-Separator {
    Write-Host ('  ' + ($chLine * 60)) -ForegroundColor DarkGray
}

function Limit-Text {
    # Shortens long names so they cannot break the layout (keeps the extension visible)
    param([string]$Text, [int]$Max)
    if ($Text.Length -le $Max) { return $Text }
    if ($Max -le 6) { return $Text.Substring(0, $Max) }
    $ext = [IO.Path]::GetExtension($Text)
    if ($ext.Length -gt 0 -and $ext.Length -lt 8 -and ($Max - $ext.Length - 3) -ge 6) {
        return $Text.Substring(0, $Max - $ext.Length - 3) + '...' + $ext
    }
    return $Text.Substring(0, $Max - 3) + '...'
}

function Read-Key {
    try { $Host.UI.RawUI.FlushInputBuffer() } catch {}
    try {
        $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        return [string]$k.Character
    } catch {
        return [string](Read-Host)
    }
}

function Wait-AnyKey {
    param([string]$Prompt = '  Press any key to return...')
    Write-Host ''
    Write-Host $Prompt -ForegroundColor Gray
    $null = Read-Key
}

function Reset-Pager { $script:PageLines = 0 }

function Test-Pager {
    # Returns $true to keep listing, $false if the user pressed Q
    $script:PageLines++
    if ($script:PageLines -lt $PageSize) { return $true }
    $script:PageLines = 0
    Write-Host '  -- Press any key for more, or Q to stop --' -NoNewline -ForegroundColor DarkGray
    $k = Read-Key
    Write-Host ("`r" + (' ' * 60) + "`r") -NoNewline
    return ($k -notmatch '^[qQ]$')
}

# --------------------------------------------------------------------
#  CORE LOGIC
# --------------------------------------------------------------------

# Equivalent of :GET_CATEGORY
function Get-Category {
    param([string]$FileName)
    $ext = [IO.Path]::GetExtension($FileName).ToLowerInvariant()
    if ($ext -and $ExtMap.ContainsKey($ext)) { return $ExtMap[$ext] }
    return $OtherName
}

# Builds the list of files directly inside the target folder.
# Not recursive. Directories, hidden and system files are ignored.
function Get-FilePlan {
    $plan = New-Object 'System.Collections.Generic.List[object]'
    $files = @(Get-ChildItem -LiteralPath $Target -File -ErrorAction SilentlyContinue | Sort-Object Name)
    foreach ($f in $files) {
        $isSelf = ($f.FullName -ieq $SelfPath)
        $cat    = ''
        $reason = ''
        if ($isSelf) { $reason = 'Organizer script' } else { $cat = Get-Category $f.Name }
        $plan.Add([pscustomobject]@{
            Name     = $f.Name
            FullName = $f.FullName
            Category = $cat
            Skip     = $isSelf
            Reason   = $reason
        })
    }
    return ,$plan
}

# Finds a destination name that does not exist yet: name.ext, name (1).ext, name (2).ext ...
function Get-SafeDestination {
    param([string]$Directory, [string]$Name)
    $dest = Join-Path $Directory $Name
    if (-not (Test-Path -LiteralPath $dest)) { return $dest }
    $base = [IO.Path]::GetFileNameWithoutExtension($Name)
    $ext  = [IO.Path]::GetExtension($Name)
    $i = 1
    do {
        $dest = Join-Path $Directory ("$base ($i)$ext")
        $i++
    } while (Test-Path -LiteralPath $dest)
    return $dest
}

# Equivalent of :SAFE_MOVE - never overwrites, never throws to the caller.
# [IO.File]::Move refuses to replace an existing file, which is a second safety net.
function Move-FileSafe {
    param([string]$Source, [string]$Category)
    try {
        $destDir = Join-Path $Target $Category
        if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
            if (Test-Path -LiteralPath $destDir) {
                throw "A file named '$Category' already exists, so the folder cannot be created."
            }
            $null = [IO.Directory]::CreateDirectory($destDir)
        }
        $name = [IO.Path]::GetFileName($Source)
        $dest = Get-SafeDestination $destDir $name
        [IO.File]::Move($Source, $dest)
        return [pscustomobject]@{ Ok = $true; NewName = [IO.Path]::GetFileName($dest); Reason = '' }
    } catch {
        $ex = $_.Exception
        if ($ex.InnerException) { $ex = $ex.InnerException }
        $msg = ($ex.Message -replace '\s+', ' ').Trim()
        return [pscustomobject]@{ Ok = $false; NewName = ''; Reason = $msg }
    }
}

# --------------------------------------------------------------------
#  SCREENS
# --------------------------------------------------------------------

function Show-Startup {
    Write-BoxTop
    Write-BoxRow $AppName 'Center' 'White'
    Write-BoxRow $Tagline 'Center' 'Gray'
    Write-BoxBottom
    Say ''
    Say "  Version $AppVersion"
    Say "  $CopyrightLine"
    Say ''
    Say '  Scanning location:'
    Say ''
    Say "  $Target" 'White'
    Say ''
    Write-Host '  Status: ' -NoNewline
    Write-Host 'READY' -ForegroundColor Green
    Say ''
}

# Equivalent of :MAIN_MENU (display part)
function Show-MainMenu {
    Write-BoxTop
    Write-BoxRow 'MAIN MENU' 'Center' 'White'
    Write-BoxSep
    Write-BoxRow '' 'Left'
    Write-BoxRow '[1]  Preview Files' 'Left'
    Write-BoxRow '[2]  Organize Files' 'Left'
    Write-BoxRow '[3]  View Supported File Types' 'Left'
    Write-BoxRow '[4]  Configuration' 'Left'
    Write-BoxRow '[5]  About' 'Left'
    Write-BoxRow '[0]  Exit' 'Left'
    Write-BoxRow '' 'Left'
    Write-BoxBottom
    Say ''
}

# Equivalent of :PREVIEW - completely read-only
function Invoke-Preview {
    Clear-Host
    Write-BoxTitle 'PREVIEW MODE'
    Say ''
    $plan    = Get-FilePlan
    $movable = @($plan | Where-Object { -not $_.Skip })

    if ($movable.Count -eq 0) {
        Say '  There are no files to organize in this folder.' 'Yellow'
        Say ''
        Say '  No files have been modified.'
        Wait-AnyKey
        return
    }

    Say '  The following changes WOULD be made:'
    Say ''
    Reset-Pager
    foreach ($p in $plan) {
        Write-Host ('  ' + (Limit-Text $p.Name 36).PadRight(37)) -NoNewline -ForegroundColor White
        if ($p.Skip) {
            Write-Host "$Arrow Skipped ($($p.Reason))" -ForegroundColor Yellow
        } else {
            Write-Host "$Arrow $($p.Category)" -ForegroundColor Cyan
        }
        if (-not (Test-Pager)) { Say '  (listing stopped)' 'DarkGray'; break }
    }

    $skipCount = $plan.Count - $movable.Count
    Say ''
    Say ("  Files that would be moved : {0}" -f $movable.Count)
    Say ("  Files that would be skipped: {0}" -f $skipCount)
    Say ''
    Say '  No files have been modified.' 'Green'
    Wait-AnyKey
}

function Write-Result {
    param([string]$Tag, [string]$Color, [string]$Name, [string]$Dest, [string]$Note = '')
    Write-Host ('  ' + ("[$Tag]").PadRight(9)) -NoNewline -ForegroundColor $Color
    Write-Host ((Limit-Text $Name 32).PadRight(33)) -NoNewline -ForegroundColor White
    Write-Host "$Arrow $Dest" -NoNewline -ForegroundColor Gray
    if ($Note) { Write-Host "  $Note" -NoNewline -ForegroundColor DarkGray }
    Write-Host ''
}

function Write-ErrorBlock {
    param([string]$Path, [string]$Reason)
    Say ''
    Say '  [ERROR]' 'Red'
    Say ''
    Say '  Unable to move:'
    Say ''
    Say "    $Path" 'White'
    Say ''
    Say '  Reason:'
    Say "  $Reason"
    Say ''
    Say '  The application will continue processing remaining files.'
    Say ''
}

function Clear-ProgressLine {
    Write-Host ("`r" + (' ' * 72) + "`r") -NoNewline
}

function Write-ProgressBar {
    param([int]$Done, [int]$Total)
    if ($Total -lt 1) { $Total = 1 }
    $pct    = [int][Math]::Floor(100 * $Done / $Total)
    $filled = [int][Math]::Floor(20 * $Done / $Total)
    $bar    = ($chFull * $filled) + ($chEmpty * (20 - $filled))
    Write-Host ("`r  Progress: [$bar] $pct%") -NoNewline -ForegroundColor Cyan
}

# Equivalent of :SUMMARY
function Show-Summary {
    param([int]$Scanned, [int]$Moved, [int]$Skipped, [int]$Errors, $PerCat)
    Write-BoxTitle 'ORGANIZATION COMPLETE'
    Say ''
    Say "  Target Folder : $Target" 'White'
    Say ''
    Say ("  Files Scanned : {0}" -f $Scanned)
    Say ("  Files Moved   : {0}" -f $Moved)
    Say ("  Files Skipped : {0}" -f $Skipped)
    Say ("  Errors        : {0}" -f $Errors)
    Say ''
    Say '  Files Moved By Category:'
    $any = $false
    foreach ($c in $AllFolders) {
        if ($PerCat.ContainsKey($c) -and $PerCat[$c] -gt 0) {
            Say ("    {0,-15} : {1}" -f $c, $PerCat[$c])
            $any = $true
        }
    }
    if (-not $any) { Say '    (none)' 'DarkGray' }
    Say ''
    Write-Host '  Status: ' -NoNewline
    if ($Errors -eq 0) { Write-Host 'COMPLETED' -ForegroundColor Green }
    else               { Write-Host 'COMPLETED WITH ERRORS' -ForegroundColor Yellow }
    Say ''
    Say "  Thank you for using $AppName."
    Say ''
    Say "  $CopyrightLine"
}

# Equivalent of :ORGANIZE
function Invoke-Organize {
    Clear-Host
    Write-BoxTitle 'ORGANIZATION MODE'
    Say ''

    $plan    = Get-FilePlan
    $movable = @($plan | Where-Object { -not $_.Skip })
    if ($movable.Count -eq 0) {
        Say '  There are no files to organize in this folder.' 'Yellow'
        Wait-AnyKey
        return
    }

    Say '  Target:'
    Say "  $Target" 'White'
    Say ''
    Say ("  {0} file(s) will be moved into category folders." -f $movable.Count)
    Say '  Nothing is deleted or overwritten. Subfolders are not touched.'
    Say ''
    Write-Host '  Continue? [Y/N]: ' -NoNewline -ForegroundColor Yellow
    $answer = (Read-Host).Trim()
    if ($answer -notmatch '^[yY]$') {
        Say ''
        Say '  Cancelled. No files have been modified.' 'Green'
        Wait-AnyKey
        return
    }

    Clear-Host
    Say ''
    Say '  ORGANIZING FILES' 'White'
    Write-Separator
    Say ''

    $total   = $plan.Count
    $done    = 0
    $moved   = 0
    $skipped = 0
    $errors  = 0
    $perCat  = @{}

    foreach ($p in $plan) {
        $done++
        Clear-ProgressLine
        if ($p.Skip) {
            $skipped++
            Write-Result 'SKIP' 'Yellow' $p.Name $p.Reason
        } else {
            $r = Move-FileSafe $p.FullName $p.Category
            if ($r.Ok) {
                $moved++
                $perCat[$p.Category] = 1 + [int]$perCat[$p.Category]
                $note = ''
                if ($r.NewName -ne $p.Name) { $note = 'saved as ' + (Limit-Text $r.NewName 24) }
                Write-Result 'OK' 'Green' $p.Name $p.Category $note
            } else {
                $errors++
                Write-Result 'ERROR' 'Red' $p.Name 'Could not move'
                Write-ErrorBlock $p.FullName $r.Reason
            }
        }
        Write-ProgressBar $done $total
    }
    Write-Host ''
    Say ''
    Write-Separator
    Say ''

    Show-Summary $total $moved $skipped $errors $perCat
    Wait-AnyKey '  Press any key to return to the main menu...'
}

# Shared by menu option [3] and Configuration option [2]
function Show-SupportedTypes {
    Clear-Host
    Write-BoxTitle 'SUPPORTED FILE TYPES'
    Say ''
    Reset-Pager
    $stop = $false
    foreach ($cat in $CategoryOrder) {
        $lines = @()
        $cur   = ''
        foreach ($e in $Categories[$cat]) {
            if ($cur -and (($cur.Length + $e.Length + 1) -gt 44)) { $lines += $cur; $cur = $e }
            else { $cur = ($cur + ' ' + $e).Trim() }
        }
        if ($cur) { $lines += $cur }
        $first = $true
        foreach ($ln in $lines) {
            $label = ''
            if ($first) { $label = $cat }
            Write-Host ('  ' + $label.PadRight(16)) -NoNewline -ForegroundColor Cyan
            Write-Host $ln -ForegroundColor Gray
            $first = $false
            if (-not (Test-Pager)) { $stop = $true; break }
        }
        if ($stop) { break }
    }
    Say ''
    Say "  Any other extension is placed in the folder: $OtherName" 'White'
    Wait-AnyKey
}

function Show-Categories {
    Clear-Host
    Write-BoxTitle 'FILE CATEGORIES'
    Say ''
    Say ('  ' + 'Category'.PadRight(16) + 'Extensions'.PadRight(12) + 'Folder') 'Cyan'
    Write-Separator
    foreach ($c in $CategoryOrder) {
        $dir   = Join-Path $Target $c
        $state = 'created when needed'
        if (Test-Path -LiteralPath $dir -PathType Container) { $state = 'exists' }
        Say ('  ' + $c.PadRight(16) + ([string]@($Categories[$c]).Count).PadRight(12) + $state)
    }
    $dir   = Join-Path $Target $OtherName
    $state = 'created when needed'
    if (Test-Path -LiteralPath $dir -PathType Container) { $state = 'exists' }
    Say ('  ' + $OtherName.PadRight(16) + 'all others'.PadRight(12) + $state)
    Wait-AnyKey
}

function Show-PreviewStatus {
    Clear-Host
    Write-BoxTitle 'PREVIEW MODE STATUS'
    Say ''
    Write-Host '  Preview Mode    : ' -NoNewline
    Write-Host 'AVAILABLE' -ForegroundColor Green
    Say '  Behaviour       : Read-only. Never moves or changes anything.'
    Say '  Organize Mode   : Always asks for confirmation (Y/N) first.'
    Say '  Duplicates      : Renamed automatically - never overwritten.'
    Say '  Scan depth      : Top-level files only (subfolders ignored).'
    Say '  Ignored items   : Folders, hidden files, system files, this script.'
    Say ''
    Say '  Target folder:'
    Say "  $Target" 'White'
    Wait-AnyKey
}

# Equivalent of :SHOW_CONFIG
function Show-Config {
    while ($true) {
        Clear-Host
        Write-BoxTitle 'CONFIGURATION'
        Say ''
        Say '  [1] View File Categories'
        Say '  [2] View Supported Extensions'
        Say '  [3] Preview Mode Status'
        Say '  [0] Back'
        Say ''
        $c = (Read-Host '  Select an option').Trim()
        switch ($c) {
            '1' { Show-Categories }
            '2' { Show-SupportedTypes }
            '3' { Show-PreviewStatus }
            '0' { return }
            default {
                Say ''
                Say '  [!] Invalid selection. Please enter 1, 2, 3 or 0.' 'Yellow'
                Start-Sleep -Milliseconds 1500
            }
        }
    }
}

# Equivalent of :SHOW_ABOUT
function Show-About {
    Clear-Host
    Write-BoxTitle 'ABOUT'
    Say ''
    Say "  $AppName" 'White'
    Say ''
    Say "  $Tagline"
    Say ''
    Say "  Version : $AppVersion"
    Say "  Author  : $AppAuthor"
    Say "  Year    : $AppYear"
    Say ''
    Say '  A lightweight Windows utility designed to help users'
    Say '  organize files automatically based on file type.'
    Say ''
    Say '  Features:'
    Say "    $Bullet Automatic file categorization"
    Say "    $Bullet Preview / Dry Run mode"
    Say "    $Bullet Duplicate protection"
    Say "    $Bullet Safe file movement"
    Say "    $Bullet No third-party software required"
    Say "    $Bullet No internet connection required"
    Say ''
    Say "  Copyright $Copy $AppYear $AppAuthor."
    Say '  All Rights Reserved.'
    Wait-AnyKey
}

# Runs a screen and keeps the program alive if anything unexpected happens
function Invoke-Guarded {
    param([scriptblock]$Action)
    try { & $Action }
    catch {
        Say ''
        Say "  [ERROR] An unexpected problem occurred: $($_.Exception.Message)" 'Red'
        Say '  The application will return to the main menu.'
        Wait-AnyKey
    }
}

# --------------------------------------------------------------------
#  MAIN LOOP
# --------------------------------------------------------------------
try {
    if ($Categories.Count -eq 0) {
        Say ''
        Say '  [ERROR] No categories are configured.' 'Red'
        Say '  Check the EXTENSION CONFIGURATION section of the BAT file.'
        Wait-AnyKey '  Press any key to exit...'
    } else {
        $running = $true
        while ($running) {
            Clear-Host
            Show-Startup
            Show-MainMenu
            $choice = (Read-Host '  Select an option').Trim()
            switch ($choice) {
                '1' { Invoke-Guarded { Invoke-Preview } }
                '2' { Invoke-Guarded { Invoke-Organize } }
                '3' { Invoke-Guarded { Show-SupportedTypes } }
                '4' { Invoke-Guarded { Show-Config } }
                '5' { Invoke-Guarded { Show-About } }
                '0' { $running = $false }
                default {
                    Say ''
                    Say '  [!] Invalid selection. Please enter a number from 0 to 5.' 'Yellow'
                    Start-Sleep -Milliseconds 1800
                }
            }
        }
        Clear-Host
        Say ''
        Say "  Thank you for using $AppName." 'White'
        Say "  $CopyrightLine"
        Say ''
        Start-Sleep -Milliseconds 1200
    }
}
finally {
    if ($OldEncoding) { try { [Console]::OutputEncoding = $OldEncoding } catch {} }
}

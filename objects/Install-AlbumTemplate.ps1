<#
.SYNOPSIS
    Installs a Create_0.gml template into GameMaker object folders.

.DESCRIPTION
    Run from inside your project's "objects" folder. Copies the template into
    every object subfolder except the excluded ones.

    DRY RUN BY DEFAULT. Nothing is written until you pass -Apply. Read the
    table it prints and extend -Exclude until only album objects remain.

    CLOSE GAMEMAKER FIRST. It caches resources in memory and will write them
    back over anything changed underneath it.

.PARAMETER Template
    Path to the template file. Default: .\Create_0.template.gml

.PARAMETER Exclude
    Object folder names to skip.

.PARAMETER Apply
    Actually write. Without this, it only reports.

.PARAMETER AddMissingEvents
    Also insert a Create event into the .yy of objects that lack one. Off by
    default because it edits project metadata.

.EXAMPLE
    .\Install-AlbumTemplate.ps1
    Dry run. Shows what would change.

.EXAMPLE
    .\Install-AlbumTemplate.ps1 -Exclude obj_Player,obj_Wall,obj_Camera -Apply
    Writes, backing up everything it touches first.
#>

[CmdletBinding()]
param(
    [string]   $Template = ".\Create_0.template.gml",

    [string[]] $Exclude = @(
        "obj_Player",
        "obj_AlbumQR",
        "obj_AlbumDetails",
        "obj_AlbumReview",
        "obj_QRCache"
    ),

    [switch]   $Apply,
    [switch]   $AddMissingEvents,
    [string]   $BackupRoot
)

$ErrorActionPreference = "Stop"

# GameMaker's .yy parser dislikes a byte-order mark, and Windows PowerShell's
# -Encoding UTF8 adds one. Write through .NET with BOM suppressed instead.
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-TextFile([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $Template)) {
    Write-Host "Template not found: $Template" -ForegroundColor Red
    Write-Host "Pass -Template with the path to your Create_0.gml." -ForegroundColor Red
    exit 1
}

$templateText = Get-Content -LiteralPath $Template -Raw
$here         = (Get-Location).Path

if ((Split-Path $here -Leaf) -ne "objects") {
    Write-Host "Warning: current folder is '$(Split-Path $here -Leaf)', not 'objects'." -ForegroundColor Yellow
    Write-Host "Run this from inside your project's objects folder." -ForegroundColor Yellow
    Write-Host ""
}

# Backups go OUTSIDE objects/. A stray folder inside it looks like a broken
# object resource and clutters the asset browser.
if (-not $BackupRoot) {
    $stamp      = Get-Date -Format "yyyyMMdd-HHmmss"
    $BackupRoot = Join-Path (Split-Path $here -Parent) "_template_backup_$stamp"
}

# Create event is eventType 0, eventNum 0.
$createEventPattern = '"eventNum":\s*0\s*,\s*"eventType":\s*0\b'
$createEventEntry   = '    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},'

# ---------------------------------------------------------------------------
# Scan
# ---------------------------------------------------------------------------

$plan = @()

foreach ($dir in (Get-ChildItem -Directory | Sort-Object Name)) {

    $name = $dir.Name

    if ($Exclude -contains $name) {
        $plan += [pscustomobject]@{ Object = $name; Action = "skip"; Reason = "excluded" }
        continue
    }

    $yyPath  = Join-Path $dir.FullName "$name.yy"
    $gmlPath = Join-Path $dir.FullName "Create_0.gml"

    if (-not (Test-Path -LiteralPath $yyPath)) {
        $plan += [pscustomobject]@{ Object = $name; Action = "skip"; Reason = "no .yy, not an object" }
        continue
    }

    $yyText    = Get-Content -LiteralPath $yyPath -Raw
    $hasCreate = $yyText -match $createEventPattern
    $hasGml    = Test-Path -LiteralPath $gmlPath

    if (-not $hasCreate) {
        if ($AddMissingEvents) {
            $plan += [pscustomobject]@{ Object = $name; Action = "write + add event"; Reason = "no Create event in .yy" }
        } else {
            $plan += [pscustomobject]@{ Object = $name; Action = "skip"; Reason = "no Create event (use -AddMissingEvents)" }
        }
        continue
    }

    $reason = if ($hasGml) { "OVERWRITES existing" } else { "new file" }
    $plan += [pscustomobject]@{ Object = $name; Action = "write"; Reason = $reason }
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

$plan | Format-Table -AutoSize

$all     = @($plan)
$toWrite = @($plan | Where-Object { $_.Action -like "write*" })

Write-Host ""
Write-Host "$($toWrite.Count) object(s) would be modified, $($all.Count - $toWrite.Count) skipped."

if (-not $Apply) {
    Write-Host ""
    Write-Host "DRY RUN - nothing written." -ForegroundColor Cyan
    Write-Host "Check the list above. Anything that isn't an album object should go" -ForegroundColor Cyan
    Write-Host "into -Exclude. Re-run with -Apply when the list looks right." -ForegroundColor Cyan
    exit 0
}

if ($toWrite.Count -eq 0) {
    Write-Host "Nothing to do."
    exit 0
}

# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------

Write-Host ""
$answer = Read-Host "Overwrite Create_0.gml in $($toWrite.Count) object(s)? Type YES to continue"
if ($answer -cne "YES") {
    Write-Host "Aborted."
    exit 0
}

New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
Write-Host "Backing up to $BackupRoot"
Write-Host ""

$written = 0

foreach ($item in $toWrite) {

    $name    = $item.Object
    $dirPath = Join-Path $here $name
    $yyPath  = Join-Path $dirPath "$name.yy"
    $gmlPath = Join-Path $dirPath "Create_0.gml"

    $backupDir = Join-Path $BackupRoot $name
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    if (Test-Path -LiteralPath $gmlPath) {
        Copy-Item -LiteralPath $gmlPath -Destination (Join-Path $backupDir "Create_0.gml") -Force
    }

    if ($item.Action -eq "write + add event") {

        Copy-Item -LiteralPath $yyPath -Destination (Join-Path $backupDir "$name.yy") -Force

        $yyText = Get-Content -LiteralPath $yyPath -Raw
        $m      = [regex]::Match($yyText, '"eventList"\s*:\s*\[')

        if (-not $m.Success) {
            Write-Host "  $name : no eventList found, skipped" -ForegroundColor Yellow
            continue
        }

        # String.Insert, not Regex.Replace. The entry contains "$GMEvent",
        # and .NET would try to read $G as a capture group reference.
        $yyText = $yyText.Insert($m.Index + $m.Length, "`r`n" + $createEventEntry)

        Write-TextFile $yyPath $yyText
    }

    Write-TextFile $gmlPath $templateText
    Write-Host "  $name"
    $written++
}

Write-Host ""
Write-Host "Wrote $written file(s). Backups in $BackupRoot" -ForegroundColor Green
Write-Host ""
Write-Host "Next: open each object and fill in its own albumTitle, albumText and" -ForegroundColor Yellow
Write-Host "albumURL. They all currently hold the Atrocity Exhibition text and a" -ForegroundColor Yellow
Write-Host "placeholder URL, so every QR would point at the same album." -ForegroundColor Yellow

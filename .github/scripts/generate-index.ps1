<#
  generate-index.ps1 - rebuilds index.json, the machine-readable catalog the
  Avro Keyboard in-app resource downloader fetches.
  -----------------------------------------------------------------------------
  SOURCE OF TRUTH = this repository's own folders. The script scans whatever
  files exist here right now, so adding a file (git or the GitHub web UI) and
  letting this run is all it takes for the app to show it.

  Usage:
    ./.github/scripts/generate-index.ps1              # normal (CI + local)
    ./.github/scripts/generate-index.ps1 -Force       # rewrite even if unchanged
    ./.github/scripts/generate-index.ps1 -RepoRoot D:\path\to\checkout

  Rules:
    * Top-level directory = category (hidden, "licenses" and root files are
      ignored). The known folders keep their order and pretty titles;
      any new folder is appended alphabetically as a new category.
    * Extension -> type:  .avrolayout layout | .ttf/.otf font | .avroskin skin
                          .AvroEnco ansimapping | .pdf/.htm/.html doc
                          .dct/.db3 dict
      Every other extension inside a category folder is skipped (logged).
    * Description/version precedence per file, keyed by repo-relative path:
        1. <basename>.meta.json sidecar next to the file (keys present win)
        2. the existing index.json entry for the same path (smart merge -
           rescanning NEVER loses a hand-written description)
        3. the file's base name (English-only fallback)
    * Output: UTF-8 WITHOUT BOM, English only (no descriptionBn/titleBn).
    * No-op detection: if the rebuilt catalog (ignoring "generated") equals
      what is already on disk, the file is left completely untouched so the
      automation bot has nothing to commit.
#>

[CmdletBinding()]
param(
    # .github\scripts -> repository root
    [string]$RepoRoot,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
if (-not (Test-Path -LiteralPath $RepoRoot)) { throw "RepoRoot not found: $RepoRoot" }

$RepoName = 'raselrahmanrocky/Avro-Keyboard-Resource'
$Branch   = 'main'

$KnownOrder = @('AnsiMapping', 'KeyboardLayouts', 'Fonts', 'Skins', 'Docs', 'Dictionary', 'WordDatabase')
$SkipFolders = @('licenses')
$NiceTitles = @{
    'AnsiMapping'     = 'ANSI Mapping'
    'KeyboardLayouts' = 'Keyboard Layouts'
    'Fonts'           = 'Fonts'
    'Skins'           = 'Skins'
    'Docs'            = 'Docs'
    'Dictionary'      = 'Auto-Correct Dictionary'
    'WordDatabase'    = 'Word Database'
}

# Extension (lowercase, with dot) -> catalog "type" understood by the app's
# installer. Keep this whitelist in sync with uResourceInstaller.pas.
$TypeByExt = @{
    '.avrolayout' = 'layout'
    '.ttf'        = 'font'
    '.otf'        = 'font'
    '.avroskin'   = 'skin'
    '.avroenco'   = 'ansimapping'
    '.pdf'        = 'doc'
    '.htm'        = 'doc'
    '.html'       = 'doc'
    # type 'dict' installs straight into C:\ProgramData\Avro Keyboard\ + the
    # folder uAutoCorrect reads autodict.dct from and uDBase reads
    # Database.db3 from - see uResourceInstaller.pas.
    '.dct'        = 'dict'
    '.db3'        = 'dict'
}

# ---------------------------------------------------------------------------
# Canonical JSON writer.
# ConvertTo-Json is NOT stable across PowerShell versions (Windows PowerShell
# 5.1 indents nested levels differently from the pwsh used by CI), and this
# repository is edited from both. Serializing with one printer keeps the file
# byte-identical no matter where it was generated, so the no-op detection
# above really is a no-op and the bot never commits pure formatting churn.
# ---------------------------------------------------------------------------
function ConvertTo-CanonicalJson {
    param($Value, [int]$Depth = 0)

    $pad  = '  ' * $Depth
    $pad2 = '  ' * ($Depth + 1)

    if ($null -eq $Value) { return 'null' }
    if ($Value -is [string]) { return ($Value | ConvertTo-Json -Compress) }
    if ($Value -is [bool])   { if ($Value) { return 'true' } else { return 'false' } }
    if ($Value -is [ValueType]) { return [string]$Value }

    # Dictionaries first: [ordered] hashtables are IEnumerable too, and
    # @($dict) yields the dictionary itself - recursing there never ends.
    if ($Value -is [System.Collections.IDictionary]) {
        $keys = @($Value.Keys)
        if ($keys.Count -eq 0) { return '{}' }
        $parts = foreach ($k in $keys) {
            $pad2 + '"' + [string]$k + '": ' + (ConvertTo-CanonicalJson $Value[$k] ($Depth + 1))
        }
        return "{`n" + ($parts -join ",`n") + "`n$pad}"
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @($Value)
        if ($items.Count -eq 0) { return '[]' }
        $parts = foreach ($it in $items) { $pad2 + (ConvertTo-CanonicalJson $it ($Depth + 1)) }
        return "[`n" + ($parts -join ",`n") + "`n$pad]"
    }

    $props = @($Value.PSObject.Properties)
    if ($props.Count -eq 0) { return '{}' }
    $parts = foreach ($p in $props) {
        $pad2 + '"' + [string]$p.Name + '": ' + (ConvertTo-CanonicalJson $p.Value ($Depth + 1))
    }
    return "{`n" + ($parts -join ",`n") + "`n$pad}"
}

# ---------------------------------------------------------------------------
# Load the current index for the smart merge (path -> existing entry).
# ---------------------------------------------------------------------------
$indexPath = Join-Path $RepoRoot 'index.json'
$oldRaw    = $null
$oldItems  = @{}
if (Test-Path -LiteralPath $indexPath) {
    try {
        $oldRaw = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($cat in $oldRaw.categories) {
            foreach ($it in $cat.items) {
                if ($it.file) { $oldItems[[string]$it.file] = $it }
            }
        }
    } catch {
        Write-Warning "Existing index.json is unreadable ($($_.Exception.Message)) - building from scratch."
        $oldRaw    = $null
        $oldItems  = @{}
    }
}

# ---------------------------------------------------------------------------
# Enumerate category folders: the known ones first, then unknown appended.
# ---------------------------------------------------------------------------
$allDirs = @(Get-ChildItem -LiteralPath $RepoRoot -Directory -Force |
    Where-Object { -not $_.Name.StartsWith('.') })
$orderedDirs = @()
foreach ($n in $KnownOrder) {
    $hit = $allDirs | Where-Object { $_.Name -eq $n }
    if ($hit) { $orderedDirs += @($hit)[0] }
}
$orderedDirs += @($allDirs |
    Where-Object { ($_.Name -notin $KnownOrder) -and ($_.Name -notin $SkipFolders) } |
    Sort-Object Name)

# ---------------------------------------------------------------------------
# Scan.
# ---------------------------------------------------------------------------
$categoryList = @()
foreach ($dir in $orderedDirs) {
    $allFiles = @(Get-ChildItem -LiteralPath $dir.FullName -File -Recurse -Force |
        Where-Object { -not $_.Name.StartsWith('.') })

    $fileList = [System.Collections.Generic.List[object]]::new()
    foreach ($f in $allFiles) {
        $ext = $f.Extension.ToLowerInvariant()
        if ($TypeByExt.ContainsKey($ext)) {
            $fileList.Add($f)
        } elseif ( ($f.Name -notlike '*.meta.json') -and ($f.DirectoryName -eq $dir.FullName) ) {
            # Log skipped candidates at the category's top level only - support
            # material in subfolders (images, ...) stays quiet.
            Write-Host ("  skip  {0}/{1} (extension not supported)" -f $dir.Name, $f.Name)
        }
    }

    # Ordinal-ignore-case sort on the repo-relative path: byte-stable output
    # on every OS/engine (culture-sensitive sorting differs between Windows
    # and the Linux CI runner, which would make the bot rewrite forever).
    $relOf = @{}
    foreach ($f in $fileList) {
        $rel = $f.FullName.Substring($dir.FullName.Length).TrimStart('\', '/')
        $relOf[[string]$f.FullName] = $dir.Name + '/' + ($rel -replace '\\', '/')
    }
    $fileList.Sort({ param($a, $b)
        [StringComparer]::OrdinalIgnoreCase.Compare($relOf[[string]$a.FullName], $relOf[[string]$b.FullName]) })

    $items = [System.Collections.Generic.List[object]]::new()
    foreach ($f in $fileList) {
        $relPath = $relOf[[string]$f.FullName]
        $type    = $TypeByExt[$f.Extension.ToLowerInvariant()]
        $base    = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)

        # Priority 1: sidecar <basename>.meta.json in the same folder.
        $desc = $null
        $ver  = $null
        $scPath = Join-Path $f.DirectoryName ($base + '.meta.json')
        $sc = $null
        if (Test-Path -LiteralPath $scPath) {
            try {
                $sc = Get-Content -LiteralPath $scPath -Raw -Encoding UTF8 | ConvertFrom-Json
            } catch {
                Write-Warning "Unreadable sidecar, ignored: $scPath ($($_.Exception.Message))"
            }
        }

        # Priority 2: existing index entry for the same path (smart merge).
        $oldEntry = $oldItems[$relPath]
        if ($null -ne $oldEntry) {
            if ($oldEntry.description) { $desc = [string]$oldEntry.description }
            if ($oldEntry.PSObject.Properties['version'] -and $oldEntry.version) {
                $ver = [string]$oldEntry.version
            }
        }

        # Sidecar wins for every key it actually provides.
        if ($null -ne $sc) {
            if ($sc.PSObject.Properties['description'] -and $sc.description) {
                $desc = [string]$sc.description
            }
            if ($sc.PSObject.Properties['version'] -and $sc.version) {
                $ver = [string]$sc.version
            }
        }

        # Priority 3: fallback to the file name.
        if ([string]::IsNullOrWhiteSpace($desc)) { $desc = $base }

        $item = [ordered]@{
            file        = $relPath
            name        = $base
            type        = $type
            description = $desc
            size        = $f.Length
            sha256      = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        }
        if ($ver) { $item.version = $ver }
        $items.Add([pscustomobject]$item)
    }

    if ($items.Count -eq 0) { continue }   # a folder without supported files is not a category

    $title = $dir.Name
    if ($NiceTitles.ContainsKey($dir.Name)) { $title = $NiceTitles[$dir.Name] }
    $catId = (($dir.Name -replace '[^0-9A-Za-z]', '')).ToLowerInvariant()

    $categoryList += [ordered]@{
        id    = $catId
        title = $title
        items = @($items)
    }
    Write-Host ("{0,-18} {1} file(s)" -f $dir.Name, $items.Count)
}

# ---------------------------------------------------------------------------
# Write index.json only when the catalog actually changed ("generated" is
# excluded from the comparison so a date rollover alone never causes a commit).
# ---------------------------------------------------------------------------
$core = [ordered]@{
    schema     = 1
    repo       = $RepoName
    branch     = $Branch
    categories = $categoryList
}
$newJson = ConvertTo-CanonicalJson $core

$oldJson = $null
if ($null -ne $oldRaw) {
    $oldCore = [ordered]@{
        schema     = $oldRaw.schema
        repo       = [string]$oldRaw.repo
        branch     = [string]$oldRaw.branch
        categories = $oldRaw.categories
    }
    $oldJson = ConvertTo-CanonicalJson $oldCore
}

if (-not $Force -and ($newJson -eq $oldJson)) {
    Write-Host "index.json unchanged - nothing to do."
    return
}

$total = 0
foreach ($c in $categoryList) { $total += $c.items.Count }
$index = [ordered]@{
    schema     = 1
    generated  = (Get-Date).ToString('yyyy-MM-dd')
    repo       = $RepoName
    branch     = $Branch
    categories = $categoryList
}
$json = ConvertTo-CanonicalJson $index

# A catalog that does not parse is worse than no update at all: the app reads
# this file with a strict JSON parser, so one writer bug takes the whole
# Download Resources window down with it - which is exactly how the object
# closers shipped broken once. Fail loudly here instead of committing it.
try {
    $null = $json | ConvertFrom-Json
} catch {
    throw "Refusing to write index.json - the canonical writer produced invalid JSON: $($_.Exception.Message)"
}

[System.IO.File]::WriteAllText($indexPath, $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "index.json updated: $indexPath ($total items, $($categoryList.Count) categories)"

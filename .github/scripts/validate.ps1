$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$specs = @(
    @{ Name = 'fv-ssh-unlock'; Architectures = @('64bit', 'arm64'); Execute = $true },
    @{ Name = 'audio-fade-fixer'; Architectures = @('64bit'); Execute = $false },
    @{ Name = 'takeout-helper-gphotos'; Architectures = @('64bit', 'arm64'); Execute = $true }
)
foreach ($spec in $specs) {
    $name = $spec.Name
    $manifest = Get-Content "bucket/$name.json" -Raw | ConvertFrom-Json
    $binaryName = "$name.exe"
    if ($name -eq 'audio-fade-fixer') {
        if ($manifest.shortcuts[0][0] -ne $binaryName) { throw 'Unexpected Audio Fade Fixer executable' }
        if (($manifest.notes -join ' ') -notmatch 'does not restore registry values') { throw 'Uninstall caveat is missing' }
    } elseif ($manifest.bin -ne $binaryName) {
        throw "Unexpected executable shim for $name"
    }
    $version = [System.Management.Automation.SemanticVersion]::Parse($manifest.version)
    $tempRoot = Join-Path $env:RUNNER_TEMP "$name-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    foreach ($arch in $spec.Architectures) {
        $entry = $manifest.architecture.$arch
        $prefix = "https://github.com/shoon/$name/releases/download/v$version/"
        if (-not $entry.url.StartsWith($prefix, [StringComparison]::Ordinal)) { throw 'Archive URL is outside the upstream release' }
        if ($entry.hash -notmatch '^[0-9a-fA-F]{64}$') { throw 'Invalid SHA256' }
        $archive = Join-Path $tempRoot "$arch.zip"
        Invoke-WebRequest -Uri $entry.url -OutFile $archive
        $actual = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -ne $entry.hash.ToLowerInvariant()) { throw "Checksum mismatch: $name/$arch" }
        $extract = Join-Path $tempRoot $arch
        Expand-Archive -Path $archive -DestinationPath $extract
        $binary = Join-Path $extract $binaryName
        if (-not (Test-Path $binary -PathType Leaf)) { throw "Archive is missing $binaryName" }
        if ($spec.Execute -and $arch -eq '64bit') {
            $output = & $binary --version
            if ($LASTEXITCODE -ne 0 -or $output -notmatch [regex]::Escape($manifest.version)) {
                throw "Incorrect executable version: $name"
            }
        }
    }
    Write-Host "Verified $name $version archives and applicable AMD64 version check."
}

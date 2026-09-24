$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$specs = @(
    @{ Name = 'audio-fade-fixer'; Arches = @{ '64bit' = 'x64' } },
    @{ Name = 'takeout-helper-gphotos'; Arches = @{ '64bit' = 'x64'; 'arm64' = 'arm64' } }
)
foreach ($spec in $specs) {
    $name = $spec.Name
    $release = Invoke-RestMethod -Headers @{ Accept = 'application/vnd.github+json' } -Uri "https://api.github.com/repos/shoon/$name/releases/latest"
    if ($release.draft -or $release.prerelease) { throw 'Expected stable published release' }
    $path = "bucket/$name.json"
    $manifest = Get-Content $path -Raw | ConvertFrom-Json
    $current = [System.Management.Automation.SemanticVersion]::Parse($manifest.version)
    $version = $release.tag_name.TrimStart('v')
    $latest = [System.Management.Automation.SemanticVersion]::Parse($version)
    if ($latest -le $current) { Write-Host "$name is current."; continue }
    if ($latest.PreReleaseLabel) { throw 'Cannot promote a preview release through the stable updater' }
    foreach ($arch in $spec.Arches.Keys) {
        $suffix = $spec.Arches[$arch]
        $filename = "$name-v$version-windows-$suffix.zip"
        $url = "https://github.com/shoon/$name/releases/download/v$version/$filename"
        $archive = Join-Path $env:RUNNER_TEMP $filename
        Invoke-WebRequest -Uri $url -OutFile $archive
        $manifest.architecture.$arch.url = $url
        $manifest.architecture.$arch.hash = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    $manifest.version = $version
    $manifest | ConvertTo-Json -Depth 20 | Set-Content -Path $path -Encoding utf8
}
# Only stage data. Validation and the repository-scoped PR action handle the rest.
# No token, commit, branch write, or main push occurs in this script.

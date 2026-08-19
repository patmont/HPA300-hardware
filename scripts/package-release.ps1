[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9A-Za-z][0-9A-Za-z._-]*$')]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$fabricationDir = Join-Path $repoRoot 'manufacturing/Fabrication'
$assemblyDir = Join-Path $repoRoot 'manufacturing/Assembly'
$outputDir = Join-Path $repoRoot 'dist'

$fabricationNames = @(
    'HPA300-B_Cu.gbl'
    'HPA300-B_Mask.gbs'
    'HPA300-B_Paste.gbp'
    'HPA300-B_Silkscreen.gbo'
    'HPA300-Edge_Cuts.gm1'
    'HPA300-F_Cu.gtl'
    'HPA300-F_Mask.gts'
    'HPA300-F_Paste.gtp'
    'HPA300-F_Silkscreen.gto'
    'HPA300-NPTH.drl'
    'HPA300-PTH.drl'
)

$fabricationFiles = foreach ($name in $fabricationNames) {
    $path = Join-Path $fabricationDir $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing fabrication artifact: $path"
    }
    Get-Item -LiteralPath $path
}

$schematicSource = Join-Path $repoRoot 'HPA300.pdf'
$bomSource = Join-Path $assemblyDir 'HPA300-bom.csv'
$noticeSource = Join-Path $repoRoot 'NOTICE.md'
foreach ($path in @($schematicSource, $bomSource, $noticeSource)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing release artifact: $path"
    }
}

[System.IO.Directory]::CreateDirectory($outputDir) | Out-Null

$gerberArchive = Join-Path $outputDir "HPA300-$Version-gerbers.zip"
$schematicOutput = Join-Path $outputDir "HPA300-$Version-schematic.pdf"
$bomOutput = Join-Path $outputDir "HPA300-$Version-bom.csv"
$noticeOutput = Join-Path $outputDir "HPA300-$Version-NOTICE.txt"
$checksumOutput = Join-Path $outputDir 'SHA256SUMS.txt'

Compress-Archive -LiteralPath $fabricationFiles.FullName `
    -DestinationPath $gerberArchive -CompressionLevel Optimal -Force
Copy-Item -LiteralPath $schematicSource -Destination $schematicOutput -Force
Copy-Item -LiteralPath $bomSource -Destination $bomOutput -Force
Copy-Item -LiteralPath $noticeSource -Destination $noticeOutput -Force

$releaseFiles = @($gerberArchive, $schematicOutput, $bomOutput, $noticeOutput)
$checksumLines = foreach ($path in $releaseFiles) {
    $file = Get-Item -LiteralPath $path
    $hash = Get-FileHash -LiteralPath $path -Algorithm SHA256
    "{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $file.Name
}
[System.IO.File]::WriteAllLines($checksumOutput, $checksumLines,
    [System.Text.UTF8Encoding]::new($false))

Write-Output "Release artifacts written to $outputDir"
Get-Item -LiteralPath @(
    $gerberArchive,
    $schematicOutput,
    $bomOutput,
    $noticeOutput,
    $checksumOutput
) |
    Select-Object Name, Length

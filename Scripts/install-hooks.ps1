# One-time setup: point this clone's core.hooksPath at the tracked .githooks directory.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
git -C $root config core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) { throw 'git config failed' }
Write-Host 'install-hooks: core.hooksPath set to .githooks'

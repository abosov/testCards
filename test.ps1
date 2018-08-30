Clear-Host

$LASTEXITCODE = 0
Invoke-Expression ".\cards.ps1 -test"

if ($LASTEXITCODE -ne 0){
    Write-Host "Error: $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "------END TEST! (test.ps1)"

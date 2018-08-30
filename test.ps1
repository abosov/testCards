$error1 = $(Invoke-Expression ".\cards.ps1 -test")

try {
    Invoke-Expression ".\cards.ps1 -test"
} catch {
   exit 123 # error handling go here, $_ contains the error record
}

Write-Host "11111: $?"

if ($error1 -eq $true){
    Write-Host "Error: $error1"
    exit $error1
}

Write-Host "------END TEST! (test.ps1)"

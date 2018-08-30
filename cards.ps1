# examples:
# ./cards.ps1 -shuffle
# ./cards.ps1 -players 2 -cardsForPlayer 3 
# ./cards.ps1 -getCardsFromFiles player1.txt,player2.txt
#


param (
    [switch] $test,
    [switch] $shuffle,
    [int] $players,
    [int] $cardsForPlayer,
    [String[]] $getCardsFromFiles
)

$cardsFile = "cards.txt"

Clear-Host

if ($test -eq $true){
    Write-Host "This is TEST! failed (cards.ps1)"
    exit 1
}

if([IO.File]::Exists(".\$cardsFile")){
    $cardArray = [IO.File]::ReadAllLines(".\$cardsFile")
} else {
    Write-Host "No card file"
    exit
}

$countCards = $cardArray.Count

if ($shuffle -eq $true){

    for ($i = 0; $i -lt $countCards; $i++){    
        $current = $cardArray[$i]
        $changedCard = $(Get-Random -Maximum $countCards)
        $cardArray[$i] = $cardArray[$changedCard]
        $cardArray[$changedCard] = $current
    }

}


if (($players * $cardsForPlayer) -gt $countCards) {
    Write-Host "Not enough cards"
} elseif ($players -ne 0 -and $cardsForPlayer -ne 0){
    $LastCard = $countCards - 1
    for ($player = 1; $player -le $players; $player++){
        
        $playerArray = @()
        for ($card = 1; $card -le $cardsForPlayer; $card++){
            $playerArray += $cardArray[$($LastCard)]
            $LastCard--     
            $cardArray = $cardArray[0..($cardArray.Count-2)]
        }
        $playerArray | Out-File -filePath ".\player$player.txt"
    }
}


if ($getCardsFromFiles -ne $false){
    foreach ($playerFile in $getCardsFromFiles){
        if([IO.File]::Exists(".\$playerFile")){
            $fileContent = [IO.File]::ReadAllLines(".\$playerFile")
            $cardArray += $fileContent
            Remove-Item -Path ".\$playerFile"
        } else {
            Write-Host "No such file - $playerFile"
        }
    }
}

$cardArray | Out-File -filePath ".\cards.txt"

Write-Host "Finished"


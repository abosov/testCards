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
$localPath = Get-Location

Clear-Host

# user-test
if ($test -eq $true){
    Write-Host "This is TEST! (cards.ps1)"
    exit #1 # for checking test
}

# read cards-file
if([IO.File]::Exists("$localPath\$cardsFile")){
    $cardArray = [IO.File]::ReadAllLines("$localPath\$cardsFile")
} else {
    Write-Host "No card file"
    exit 2
}

$countCards = $cardArray.Count

# shuffle
if ($shuffle -eq $true){

    for ($i = 0; $i -lt $countCards; $i++){    
        $current = $cardArray[$i]
        $changedCard = $(Get-Random -Maximum $countCards)
        $cardArray[$i] = $cardArray[$changedCard]
        $cardArray[$changedCard] = $current
    }
    Write-Host "Shuffled"
}

# hand over the cards
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
        $playerArray | Out-File -filePath "$localPath\player$player.txt"
    }

    if ($players * $cardsForPlayer -eq $countCards){
        $cardArray = @()
    }

    Write-Host "Dealt $players players $cardsForPlayer cards for each"
}


# collect cards
if ($getCardsFromFiles -ne $false){
    foreach ($playerFile in $getCardsFromFiles){
        if([IO.File]::Exists("$localPath\$playerFile")){
            $fileContent = [IO.File]::ReadAllLines("$localPath\$playerFile")
            $cardArray += $fileContent
            Remove-Item -Path "$localPath\$playerFile"
            Write-Host "Cards collected from file $localPath\$playerFile"
        } else {
            Write-Host "No such file - $playerFile"
        }
    }
}

$cardArray | Out-File -filePath "$localPath\cards.txt"

Write-Host "Finished"
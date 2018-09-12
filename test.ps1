Clear-Host
$localPath = Get-Location
$cardsFile = "cards.txt"
$cardsPS1 = "cards.ps1"

$LASTEXITCODE = 0

function restoreCardsFile {
    if ([IO.File]::Exists("$localPath/_cards.txt")){
        Copy-Item "$localPath/_cards.txt" -Destination "$localPath/$cardsFile" -Force
        Write-Host "Restore $cardsFile"
    } else {
        Write-Host "Error (test.ps1): No file _cards.txt"
        exit 3
    }
}

function countLines {
    Param($file)
    
    if ([IO.File]::Exists("$localPath/$file")){
        ([IO.File]::ReadAllLines("$localPath/$file")).Count
    } else {
        Write-Host "Error (test.ps1): No file $file"
        # no exit for test cases
    }
}

function dealCards {
    Param($players, $cardsForPlayer)

    Invoke-Expression "$localPath/$cardsPS1 -players $players -cardsForPlayer $cardsForPlayer"

    if ($LASTEXITCODE -ne 50){
        checkCardNumber -players $players -comment "(players: $players, cardsForPlayer: $cardsForPlayer)"
    } else {
        Write-Host "Exeption in $cardsPS1"
        $LASTEXITCODE = 0
        # no exit for test cases
    }
}

function checkCardNumber {
    Param($players, $comment)

    $cardSumPlayers = 0
    if ($players -eq 0){
        $cardSumChanged = countLines -file cards.txt        
    } else {
        for ($player = 1; $player -le $players; $player++){
            if ([IO.File]::Exists("$localPath/player$player.txt")){
                $cur_lines = countLines -file player$player.txt
                Write-Host "player$player.txt - $cur_lines"
                $cardSumPlayers += $cur_lines
            } else {
                Write-Host "Error (test.ps1): no file $localPath/player$player.txt"
                exit 2
            }
        }
    }

    if ($cardSum -ne ($cardSumChanged + $cardSumPlayers)) {
        Write-Host "Error (test.ps1): Incorrect card number in $comment"
        exit 3
    } else {
        Write-Host "Cards in $comment : $cardSum = $($cardSumChanged + $cardSumPlayers)"
    }
}

function collectCards {
    Param($players)

    Write-Host "Collecting cards from $players players"

    if ($players -ne 0){
        $playerList = ""
        $cardSumChangedBefore = countLines -file cards.txt    

        for ($player = 1; $player -le $players; $player++){
            if ($player -eq $players) {$sep = ""} else {$sep = ","}
            $playerList += "player$player.txt$sep"
            $cur_lines = countLines -file player$player.txt
            $cardsCollected += $cur_lines
        }

        Invoke-Expression "$localPath/$cardsPS1 -getCardsFromFiles $playerList"

        $cardSumChangedAfter = countLines -file cards.txt    

        Write-Host "$cardsFile before: $cardSumChangedBefore; $cardsFile after: $cardSumChangedAfter"

        if (($cardSumChangedBefore + $cardsCollected) -ne $cardSumChangedAfter){
            Write-Host "Error (test.ps1): number of cards incorrected in Collection"
            exit 4
        }
    } else {
        Write-Host "Number of players must be more then 0!"
    }
}


Write-Host "Test started"

# backup cards.txt

if ([IO.File]::Exists("$localPath/$cardsFile")){
    Copy-Item "$localPath/$cardsFile" -Destination "$localPath/_cards.txt" -Force
    Write-Host "Backup $cardsFile"
} else {
    Write-Host "Error (test.ps1): No file $cardsFile"
    exit 2
}


Write-Host "`nUse case 1 : Shuffle"
$cardSum = countLines -file cards.txt

Invoke-Expression "$localPath/$cardsPS1 -shuffle"

checkCardNumber -players 0 -comment "shuffle"

Write-Host "`nUse case 2 : Deal 1"
dealCards -players 2 -cardsForPlayer 26
collectCards -players 2
restoreCardsFile

Write-Host "`nUse case 3 : Deal 2"
#dealCards -players 1 -cardsForPlayer 53 #depends on environment; test passed in Travis and Windows, but incorrect exception handling in Ubuntu
#restoreCardsFile

Write-Host "`nUse case 4 : Deal 3"
dealCards -players 1 -cardsForPlayer 52
restoreCardsFile

Write-Host "`nUse case 5 : Deal 4"
dealCards -players 52 -cardsForPlayer 1

Write-Host "`nUse case 6 : Collection 1"
collectCards -players 52

Write-Host "`nUse case 7 : Collection 2"
collectCards -players 1


if (!(($LASTEXITCODE -eq 0) -or ($LASTEXITCODE -eq 50))){
    Write-Host "Error code: $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "------END TEST! (test.ps1)"

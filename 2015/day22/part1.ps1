. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)


<#

Looks like another search of all possibe states... If running in a queue, can check all the current steps at the same time.

As per that video, look for steps where we can prune the tree to reduce possible search paths (where we would die, make 
no/negative progress, etc)

Can also explore caching the state, so that if we reach a known (or worse) state after spending more mana, we can also prune
#>

$Path = "$PSScriptRoot/input.txt"

class GameState {
    [int]$SpentMana = 0

    [int]$PlayerHealth = 50
    [int]$CurrentMana = 500

    [int]$Effect_ShieldTurnsRem = 0
    [int]$Effect_PoisonTurnsRem = 0
    [int]$Effect_RechargeTurnsRem = 0

    [int]$BossHealth
    [int]$BossDamage

    [Object]Clone(){
        return $this.MemberwiseClone()
      }
}

$GameState_Start = New-Object GameState
$GameState_Start.BossHealth, $GameState_Start.BossDamage = get-content $Path | %{ [int]($_ | Select-String "\d+").Matches.Value}







#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta


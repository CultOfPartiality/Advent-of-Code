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

enum Actions {
  Magic
  Drain
  Shield
  Poison
  Recharge
}

class GameState {
    [bool]$Valid = $true

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
    UseMana($manacost){
      $this.SpentMana += $manacost
      $this.CurrentMana -= $manacost
    }
    
    simulateEffects(){
      $this.Effect_ShieldTurnsRem -= ($this.Effect_ShieldTurnsRem -gt 0) ? 1 : 0
      
      if($this.Effect_PoisonTurnsRem -gt 0){
        $this.BossHealth -= 3
        $this.Effect_PoisonTurnsRem--
      }
    
      if($this.Effect_RechargeTurnsRem -gt 0){
        $this.CurrentMana+=101
        $this.Effect_RechargeTurnsRem--
      }
    }

    simulateTurn([Actions] $action){
      
      #Efects at the start of the Player's turn
      $this.simulateEffects()
      
      #Player action
      switch ($action) {
        ([Actions]::Magic)     {
          $this.UseMana(53)
          $this.BossHealth -= 4
        }
        ([Actions]::Drain)     {
          $this.UseMana(73)
          $this.BossHealth -= 2
          $this.PlayerHealth += 2
        }
        ([Actions]::Shield)    {
          if($this.Effect_ShieldTurnsRem -eq 0){
            $this.UseMana(113)
            $this.Effect_ShieldTurnsRem = 6
          }
          else {
            $this.Valid = $false
          }
        }
        ([Actions]::Poison)    {
          if($this.Effect_PoisonTurnsRem -eq 0){
            $this.UseMana(173)
            $this.Effect_PoisonTurnsRem=6
          }
          else {
            $this.Valid = $false
          }
        }
        ([Actions]::Recharge)  {
          if($this.Effect_RechargeTurnsRem -eq 0){
            $this.UseMana(229)
            $this.Effect_RechargeTurnsRem=5
          }
          else {
            $this.Valid = $false
          }
        }
      }
      
      #Efects at the start of the boss's turn
      $this.simulateEffects()
      
      #Boss action
      if($this.BossHealth -gt 0){
        $this.PlayerHealth -= ($this.Effect_ShieldTurnsRem -gt 0) ? [Math]::Max(1,$this.BossDamage-7) : $this.BossDamage
      }
      
      #Other Validity Checks
      $this.Valid =  $this.Valid -and ($this.CurrentMana -gt 0) -and ($this.PlayerHealth -gt 0)
    }
}


$GameState_Start = New-Object GameState


$GameState_Start.BossHealth, $GameState_Start.BossDamage = get-content $Path | %{ [int]($_ | Select-String "\d+").Matches.Value}

#Debug case
# $GameState_Start.PlayerHealth = 10
# $GameState_Start.CurrentMana = 250
# $GameState_Start.BossDamage = 8
# $GameState_Start.BossHealth = 13
# $GameState_Start.simulateTurn([Actions]::Poison)
# $GameState_Start
# $GameState_Start.simulateTurn([Actions]::Magic)
# $GameState_Start
# exit

# $GameState_Start.PlayerHealth = 10
# $GameState_Start.CurrentMana = 250
# $GameState_Start.BossDamage = 8
# $GameState_Start.BossHealth = 14
# $GameState_Start.simulateTurn([Actions]::Recharge)
# $GameState_Start.simulateTurn([Actions]::Shield)
# $GameState_Start.simulateTurn([Actions]::Drain)
# $GameState_Start.simulateTurn([Actions]::Poison)
# $GameState_Start.simulateTurn([Actions]::Magic)
# exit

$PossibleGames = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"
$PossibleGames.Enqueue($GameState_Start,$GameState_Start.BossHealth)

$LeastManaSpent = [int32]::MaxValue

while ($PossibleGames.Count) {
  $gamestate = $PossibleGames.Dequeue()
  [actions].GetEnumNames() | %{[Actions]$_} | %{
    $newGameState = $gamestate.Clone()
    $newGameState.simulateTurn($_)
    if($newGameState.Valid -and $newGameState.BossHealth -le 0){
      if($newGameState.SpentMana -lt $LeastManaSpent){
        $LeastManaSpent = $newGameState.SpentMana
        Write-Host "New best score: $LeastManaSpent"
      }
    }
    elseif( $newGameState.Valid -and $newGameState.SpentMana -lt $LeastManaSpent){
      $PossibleGames.Enqueue($newGameState.Clone(),$newGameState.BossHealth)
    }
    
  }
}



#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta


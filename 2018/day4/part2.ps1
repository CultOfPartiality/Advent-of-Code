. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Get data by line, sort into chronological order, then join
    $data = get-content $Path | sort 

    $guards = @{}
    $currentGuardID = $null
    $timeFellAsleep = $null

    # Guards only ever fall asleep/wake up between 00:00 and 00:59
    # Guards always wake up by 00:59
    foreach ($entry in $data) {
        if ($entry -match "begins") {
            $currentGuardID = [int][regex]::Match($entry, "#(\d*)").Groups[1].Value
            if (-not ($guards.ContainsKey($currentGuardID))) {
                $guards[$currentGuardID] = @()
            }
        }
        elseif ($entry -match "asleep") {
            $fellAsleepMinute = [int][regex]::Match($entry, ":(\d\d)\]").Groups[1].Value
        }
        elseif ($entry -match "wakes") {
            $wokeUpMinute = [int][regex]::Match($entry, ":(\d\d)\]").Groups[1].Value
            $asleepMinutes = $fellAsleepMinute..($wokeUpMinute - 1)
            $guards[$currentGuardID] += $asleepMinutes
        }
    }

    $guardData = foreach ($guardId in $guards.keys) {
        [PSCustomObject]@{
            id     = $guardId
            values = ( $guards[$guardId]  | group | sort Count -Descending )
        }
    }

    # Filter out guards that don't fall asleep
    # Then sort by each guards' max duplicate asleep minutes, and grab the best one
    $ourGuard = ($guardData | ?{$_.values} | Sort-Object { $_.values[0].Count } -Descending)[0]
    $ourMinute = $ourGuard.values[0].Name
    
    
    $ourGuard.id * $ourMinute
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 4455
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
#924 is too low

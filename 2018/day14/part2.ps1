. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"


function Solution {
    param ([string]$makethismany)

    $elf1 = 0
    $elf2 = 1
    $recipies = New-Object System.Collections.ArrayList
    $recipies.Capacity = 1000000
    [void]$recipies.Add(3)
    [void]$recipies.Add(7)
    $solString = $makethismany
    $solArray = $makethismany.ToCharArray() | % { [int][string]$_ }


    :outer while (1) {
        
        if ($recipies.Count + 2 -ge $recipies.capacity ) {
            $recipies.capacity *= 2
            write-host "Capacity doubled to $($recipies.capacity)" -ForegroundColor DarkMagenta
        }

        $newMacroRecipie = $recipies[$elf1] + $recipies[$elf2]
        if ($newMacroRecipie -ge 10) {
            [void]$recipies.Add(1)
            if (
                ($recipies[-1] -eq $solArray[-1]) -and
                ($recipies[-2] -eq $solArray[-2]) -and 
                ($recipies[-3] -eq $solArray[-3]) -and 
                ($recipies[-4] -eq $solArray[-4]) -and
                ($recipies.Count -ge $solArray.Count)
            ) {

                $check = $recipies.GetRange($recipies.Count - $solArray.Count, $solArray.Count) -join ""
                write-host "Round $($recipies.Count) checking $check" -ForegroundColor DarkCyan
                if ($check -eq $solString ) {
                    break outer
                }
            }
        }
        [void]$recipies.Add($newMacroRecipie % 10)
        if (
            ($recipies[-1] -eq $solArray[-1]) -and
            ($recipies[-2] -eq $solArray[-2]) -and 
            ($recipies[-3] -eq $solArray[-3]) -and 
            ($recipies[-4] -eq $solArray[-4]) -and
            ($recipies.Count -ge $solArray.Count)
        ) {

            $check = $recipies.GetRange($recipies.Count - $solArray.Count, $solArray.Count) -join ""
            write-host "Round $($recipies.Count) checking $check" -ForegroundColor DarkCyan
            if ($check -eq $solString ) {
                break outer
            }
        }
        $elf1 = ($elf1 + 1 + $recipies[$elf1]) % $recipies.Count
        $elf2 = ($elf2 + 1 + $recipies[$elf2]) % $recipies.Count

        # Debug
        if ( $recipies.Count % 100000 -eq 0 ) { write-host "$($recipies.Count) recipies generated" }
    }
    $recipies.Count - $solString.Length


}
Unit-Test  ${function:Solution} "51589" 9
Unit-Test  ${function:Solution} "01245" 5
Unit-Test  ${function:Solution} "92510" 18
Unit-Test  ${function:Solution} "59414" 2018
Unit-Test  ${function:Solution} "793031" 20253137

$measuredTime = measure-command { $result = Solution "864801" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta


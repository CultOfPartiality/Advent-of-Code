. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

function Solution {
    param ($Path)

    #The following line is for development
    #$Path = "$PSScriptRoot/testcases/test1.txt"

    $data = get-content $Path

    #defines
    $lowPulse = $false
    $highPulse = $true
    $on = $true
    $off = $false

    #Step 1 - Parse module information into hash
    $modules = @{}
    foreach ($moduleRaw in $data) {
        $parsing = ( $moduleRaw | select-string '(?<operation>[%&]?)(?<name>[a-z]*) -> ((?<destinations>[a-z]+)(, )?)+' ).Matches.Groups
        $name = $parsing.Where({ $_.Name -eq 'name' }).Value
        $operation = $parsing.Where({ $_.Name -eq 'operation' }).Value
        $destinatons = @($parsing.Where({ $_.Name -eq 'destinations' }).Captures.Value)

        if ($operation -eq "%") {
            #Flip-Flop
            $module = [PSCustomObject]@{
                Name         = $name
                Type         = "Flip-Flop"
                State        = $off
                Destinations = $destinatons      
            }
        }
        elseif ($operation -eq "&") {
            #Conjunction
            $module = [PSCustomObject]@{
                Name         = $name
                Type         = "Conjunction"
                State        = @{}
                Destinations = $destinatons      
            }
        }
        else {
            #Initial Broadcaster
            $module = [PSCustomObject]@{
                Name         = $name
                Type         = "Broadcaster"
                Destinations = $destinatons      
            }
        }
        $modules.Add($name, $module)
    }

    #Step 2 - Loop over all modules again, populating the Conjunctions State hash
    foreach ($module in $modules.Values) {
        foreach ($destination in $module.Destinations) {
            if ($modules[$destination].Type -eq "Conjunction") {
                $modules[$destination].State.Add($module.Name, $lowPulse)
            }
        }
    }

    #Step 3 - Propegate the pulses, earliest sent first. Count all pulses
    $pulseCount = @(0, 0)

    for ($i = 0; $i -lt 1000; $i++) {
        #Initial button press
        $pulseQueue.Enqueue([PSCustomObject]@{
                type     = $lowPulse
                sender   = 'button'
                receiver = 'broadcaster'
            })
    
        #write-host "button -low-> broadcaster"
        do {
            $pulse = $pulseQueue.Dequeue()
            $pulseCount[$pulse.type] += 1
            $module = $modules[$pulse.receiver]
            #write-host $pulse.sender " -" ($pulse.type?"high-> ":"low-> ") $pulse.receiver
            switch ($module.Type) {
                "Broadcaster" {
                    foreach ($dest in $module.Destinations) {
                        $pulseQueue.Enqueue([PSCustomObject]@{
                                type     = $lowPulse
                                sender   = 'broadcaster'
                                receiver = $dest
                            })
                    }
                }
                "Flip-Flop" {
                    #if pulse is of the low type, flip the Flip-Flop and send pulses of the type of the new state
                    if ($pulse.type -eq $lowPulse) {
                        foreach ($dest in $module.Destinations) {
                            $pulseQueue.Enqueue([PSCustomObject]@{
                                    type     = $module.State -eq $on ? $lowPulse : $highPulse
                                    sender   = $module.Name
                                    receiver = $dest
                                })
                        }
                        $module.State = -not $module.State
                    }
                }
                "Conjunction" {
                    $module.State[$pulse.sender] = $pulse.type
                    $sendType = (($module.State.Values -eq $lowPulse).Count -eq 0) ? $lowPulse : $highPulse
                    foreach ($dest in $module.Destinations) {
                        $pulseQueue.Enqueue([PSCustomObject]@{
                                type     = $sendType
                                sender   = $module.Name
                                receiver = $dest
                            })
                    }
                }
            }
        }until ($pulseQueue.Count -eq 0)
        #Write-Host "Cycle $i Complete"
    }

    #return product of pulse counts
    $pulseCount[$lowPulse] * $pulseCount[$highPulse]
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 32000000
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 11687500
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta


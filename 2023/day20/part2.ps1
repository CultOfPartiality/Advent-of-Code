. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"


#All four of the inputs to the conjugator that feeds rx are also conjugators
#So can do lowest common multiple for when all 4 send a high pulse



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

    #Step 3 - Propegate the pulses, earliest sent first. Count all button presses
    $buttonPresses = 0
    $rxPulses = 0
    $prevConjugatorReception = @{}
    while($rxPulses -ne 1){
        #Button press
        $buttonPresses++
        $rxPulses = 0
        $pulseQueue.Enqueue([PSCustomObject]@{
                type     = $lowPulse
                sender   = 'button'
                receiver = 'broadcaster'
            })
    
        #write-host "button -low-> broadcaster"
        do {
            $pulse = $pulseQueue.Dequeue()
            if($pulse.type -eq $lowPulse -and $pulse.receiver -eq'rx') { $rxPulses++}
            
            if($pulse.type -eq $highPulse -and $pulse.receiver -eq 'hp'){
                if(-not $prevConjugatorReception.ContainsKey($pulse.sender)){
                    $prevConjugatorReception.add($pulse.sender,@())
                }
                $prevConjugatorReception[$pulse.sender] += $buttonPresses
            }

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
        
        if($rxPulses -gt 0){
            Write-Host "$rxPulses low pulses to 'rx' received on button press $buttonPresses"
        }
        elseif($buttonPresses % 1000 -eq 0){
            Write-Host "$buttonPresses buttons presses completed so far..."
        }
        #stop when each prev conjugator has 2 entries
        if( $prevConjugatorReception.Count -eq 4 -and
            (($prevConjugatorReception.values | %{$_.count}) -lt 2).Count -eq 0){
                #each cycle has 
                break
            }
    }

    #return lowest common multiple
    $cycles = $prevConjugatorReception.Values | %{$_[1] - $_[0]}
    lcm (lcm (lcm $cycles[0] $cycles[1]) $cycles[2]) $cycles[3]
}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 32000000
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 11687500
$result = Solution "$PSScriptRoot\input.txt"
Write-Host "Part 2: $result" -ForegroundColor Magenta


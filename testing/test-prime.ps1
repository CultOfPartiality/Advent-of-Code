

$rounds = 50000
$jobs = 24

0..($jobs - 1) | % { [PSCustomObject]@{
        job = $_
        start = $rounds / $jobs * $_ + 1
        end   = $rounds / $jobs * ($_ + 1)
    } } | Foreach-Object -ThrottleLimit $jobs -Parallel {
    function Test-MillerRabinPrime {
        param ([bigint]$number )

        # some easy cases
        if ($number -eq 2) { Return $true }
        if ( ($number -lt 2) -or ($number.IsEven) ) { Return $false }
    
        # $number-1 = 2**s * d
        $d = $number - 1
        $s = 0
        while ($d % 2 -eq 0) {
            $d = $d / 2
            $s++
        }
        # write-host "$number-1 = 2^$s*$d"

        # For all numbers less than 1,122,004,669,633 the following set of witnesses are sufficient to determine primality
        $prime = $true
        foreach ($a in 2, 13, 23, 1662803) {
            #If we've reached the witness number, there's no need to test further.
            if ($a -ge $number) { break }
            if ([System.Numerics.BigInteger]::ModPow($a, $d, $number) -eq 1) { continue }
            $allNEtoneg1 = $true
            for ($r = 0; $r -lt $s; $r++) {
                $x = [System.Numerics.BigInteger]::ModPow($a, [System.Numerics.BigInteger]::Pow(2, $r) * $d, $number) #TODO can optimise by only squaring the result from last time
                if ( $x -eq ($number - 1)) {
                    $allNEtoneg1 = $false
                    break
                }
            }
            if ( $allNEtoneg1) {
                $prime = $false
                break
            }
        }
        return $prime
    }

    . "$PSScriptRoot/../UsefulStuff.ps1"

    #Validating primes agains naive test
    $PSItem.Start..$PSItem.End | % {
        if ((Test-MillerRabinPrime $_) -ne (isPrime($_))) {
            Write-Host "Mismatch for $_"
            exit
        }
    }
    write-host "Job $($PSItem.job) finished"
}

# (Measure-Command {
#     1..$rounds | % {
#         Test-MillerRabinPrime $_
#     }
# }).TotalSeconds

# (Measure-Command {
#     1..$rounds | % {
#         isPrime($_)
#     }
# }).TotalSeconds
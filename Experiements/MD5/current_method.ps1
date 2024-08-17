$text = "hello"
$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($text))).ToLower().Replace("-",""))

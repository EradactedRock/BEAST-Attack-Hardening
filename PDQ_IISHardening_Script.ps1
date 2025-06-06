$process = Start-Process -FilePath reg.exe -ArgumentList "import `"./Apply_IISCrypto_Strict.reg`"" -PassThru -Wait 
exit $process.ExitCode
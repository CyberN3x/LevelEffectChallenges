<#This script is inteded to run a hash check against Virus Total.
This will run through all files downloaded from a Pcap and will delete any files
that are not detected more then 10 of the major AV manucatures out on the market
This is for a general low hanging fruit check and should not be relied upon as the
only check that is run when doing analysis of a file-set

Notes: For Future Features
* Add logic so the user can name a directrory they would like the hash dump file created in
* Look at options to move/delete files not related to a VT entry

#>

$target = $null
while($target -eq $null){
  $target = Read-Host "Enter your Source Directory:"
  if(-not(test-path $target)){
    Write-Host "Invalid Directory Path, re-enter:"
    $target=$null
  }
  elseif(-not(Get-Item $target).psiscontainer){
    Write-Host "Target must be a directory, re-enter:"
    $target = $null  }
}

$NewFolder = "$target\Hash_Dump"
if (!(Test-Path $NewFolder)){
  New-Item -ItemType Directory -Path $NewFolder
  Write-Host "$NewFolder Created."
}
else{
  Write-Host "Writing file $target\Hash_Dump\Hash_Dump_$(Get-Date -f "yyyy-MM-dd-HHmmss").txt"
}

Get-ChildItem -Path $target | Foreach-Object {C:\Programdata\chocolatey\bin\sigcheck.exe -h -e -nobanner -vt $_.FullName} |
Out-String -Stream | Select-String -Pattern 'C:','MD5','SHA1','256','VT' | Tee-Object -FilePath $target\Hash_Dump\Hash_Dump_$(Get-Date -f "yyyy-MM-dd-HHmmss").txt

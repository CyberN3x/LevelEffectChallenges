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

$NewFolder = "C:\PS_AV\Hash_Dump_$(Get-Date -f "yyyy-MM-dd")"
$Target_Log = "C:\PS_AV\Hash_Dump_$(Get-Date -f "yyyy-MM-dd")\Hash_Dump_$(Get-Date -f "yyyy-MM-dd-HHmmss").txt"

if (!(Test-Path $NewFolder)){
  New-Item -ItemType Directory -Path $NewFolder
  Write-Host "$NewFolder Created."
}
else{
  Write-Host "Writing file to: $Target_Log"
}

$Quarantine = "C:\PS_AV\Quarantine"
if(!(Test-Path $Quarantine)){
    New-Item -ItemType Directory -Path $Quarantine
    Write-Host "C:\PS_AV\Quarantine"
}
else{
  Write-Host "Quarantine directory already create. Entires will be moved to $Quarantine"
}


Get-ChildItem -Path $target | Foreach-Object {C:\Programdata\chocolatey\bin\sigcheck.exe -h -e -nobanner -vt $_.FullName} |
Out-String -Stream | Select-String -Pattern 'C:','MD5','SHA1','256','VT' | Tee-Object -FilePath $Target_Log

$Sus_Files = @(Get-Content -Path $Target_Log | Select-String -Pattern 'c:')
foreach($element in $Sus_Files){
  if(!(Test-Path $element)){
    Move-Item -Path $element -Destination $Quarantine
    Write-Host "$element moved to $Quarantine"
  }
  else{
    Write-Host "Please check if $element exists in $target"
  }
}

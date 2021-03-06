import-module activedirectory
function get-localusers { 
        param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$strComputer) 
    begin {} 
    Process { 
        $adminlist ="" 
        $powerlist ="" 
        $computer = [ADSI]("WinNT://" + $strComputer + ",computer") 
        $AdminGroup = $computer.psbase.children.find("Administrators") 
        $powerGroup = $computer.psbase.children.find("Power Users") 
        $Adminmembers= $AdminGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
        $Powermembers= $PowerGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
        foreach ($admin in $Adminmembers) { $adminlist = $adminlist + $admin + "," } 
        foreach ($poweruser in $Powermembers) { $powerlist = $powerlist + $poweruser + "," } 
        $Computer = New-Object psobject 
        $computer | Add-Member noteproperty ComputerName $strComputer 
        $computer | Add-Member noteproperty Administrators $adminlist 
        $computer | Add-Member noteproperty PowerUsers $powerlist 
        Write-Output $computer 
 
 
        } 
end {} 
} 

$strFilter = "(objectCategory=computer)"
$Computers = Get-ADComputer -LdapFilter $strFilter | Select-Object -ExpandProperty Name

$Computers |  get-localusers | Export-Csv D:\Local_Admins.csv -NoTypeInformation

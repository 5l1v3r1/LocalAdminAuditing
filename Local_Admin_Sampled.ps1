import-module activedirectory
<# User Variables #>
$strContent     = "D:\sampled_computers.txt" # List of computer account names that included in sample. List contents must be seperated with new line
$strMainPath    = "D:\sampled_computers_local_admins.csv" # Path of main output file
$strGrPath      = "D:\sampled_computers_group_members.csv" # Path for group members CSV
$strADQueryPath = "D:\sampled_computers_localusers_ADQuery.csv" # Path for AD query of local admin users
<# User Variables #>

<# General Variables -Don't change #>
$Computers = Get-Content $strContent
$Properties = @('SamAccountName', 'DisplayName', 'Enabled', 'Company', 'physicalDeliveryOfficeName', 'title', 'manager', 'Created')
$adminlist    = @() 
$adminlist2   = @() 
$resultsarray = @()
<# General Variables -Don't change #>

foreach ($comp in $Computers) <# Iterating over sampled computer accounts for retrieving members of those computers' Administrators group #> {
        
        
        $computer     = [ADSI]("WinNT://" + $comp + ",computer") 
        $AdminGroup   = $computer.psbase.children.find("Administrators")
        $Adminmembers = $AdminGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
        foreach ($admin in $Adminmembers)  { $adminlist += $comp + "," + $admin
                                             $adminlist2 += $admin} 
        $objlist = $adminlist | Select-Object @{Name='Computers,Admins';Expression={$_}}
        $objlist | Export-Csv -Append -Notypeinformation -Encoding "Unicode" -Path $strMainPath
     
        }

<# Iterating over groups for retrieving members. In case there were groups as members of Administrators group#> 
$groups = $adminlist2 |  select -uniq # removing duplicate items from initial local admin list
foreach ($group in $groups) {
        $resultsarray += Get-ADGroupMember -Id $group -recursive -ErrorAction SilentlyContinue | Get-ADUser -Properties $Properties -ErrorAction SilentlyContinue | Select 'SamAccountName', 'DisplayName', 'Enabled', 'Company', 'physicalDeliveryOfficeName', 'title', 'manager', 'Created', @{Expression={$group};Label="Group Name"} 
        }
        $resultsarray | Export-csv -path $strGrPath -notypeinformation -Encoding {Unicode} -Delimiter ";" 

<# Iterating over admin list for retrieving AD properties of these users #>
$Admins = $adminlist2 |  select -uniq # removing duplicate items from initial local admin list
foreach ($adm in $Admins) 
        {
        Get-ADUser -Identity $adm -Properties $Properties -ErrorAction SilentlyContinue | Select 'SamAccountName', 'DisplayName', 'Enabled', 'Company', 'physicalDeliveryOfficeName', 'title', 'manager', 'Created' | Export-Csv -Notypeinformation -Encoding "Unicode" -Path $strADQueryPath -Append -Delimiter ";"
        }
        

#Convert Azure Group Members to Exchange Online Mailboxes
#Thomas Schewe
#0.4

#Var Fill Up
$AzureGr = Read-Host -Prompt 'Azure Goup'
$ExchangeGr = Read-Host -Prompt 'Exchange Mailbox'

#Azure login to gather Output
Connect-AzureAD

#Get Azure Group Members
$AzureGrMembers = @("")
$AzureGrMembers = Get-AzureADGroup -SearchString $AzureGr | Get-AzureADGroupMember | Select DisplayName
#for ($i=0; $i -lt $AzureGrMembers.length; $i++){
      #Write-Host $AzureGrMembers[$i]
#}

#Array Error = 0
echo "-------------------"
if ($AzureGrMembers.count -eq 0){
    Write-Host -ForegroundColor Yellow "Group $AzureGr not fount or empty. Exiting..."
    exit
}else{
     Write-Host -ForegroundColor Yellow "Group $AzureGr fount with" $AzureGrMembers.count "Members"
}


#Stream Edit to avoid error in MailboxPermissions and RecipientPermissions in Exchange
$AzureGrMembers = $AzureGrMembers -replace "@{DisplayName="
$AzureGrMembers = $AzureGrMembers -replace "}"
for ($i=0; $i -lt $AzureGrMembers.length; $i++){
      Write-Host $AzureGrMembers[$i]
}

#Do it or not?
$result = Read-Host -Prompt 'OK?(y/n)'
if ($result -eq "y"){
    Write-Host -ForegroundColor Yellow "Working..."
}
else{
    Write-Host -ForegroundColor Yellow "Exit by User"
}


#Exchange Input
Connect-ExchangeOnline

#Fill Exchange Group

echo "-------------------"
for ($i=0; $i -lt $AzureGrMembers.length; $i++){
    Write-Host $AzureGrMembers[$i]
    Add-MailboxPermission -Identity $ExchangeGr -User $AzureGrMembers[$i] -AccessRights FullAccess -InheritanceType All
    Add-RecipientPermission -Identity $ExchangeGr -Trustee $AzureGrMembers[$i] -AccessRights SendAs -Confirm:$false
}


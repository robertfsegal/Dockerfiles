$output = net users; 

if(-not ($output -match "jenkins")) 
{ 
    Write-Host 'user does not exist?' ; 
    net user jenkins /add /expire:never /passwordreq:no ; 
    net localgroup Administrators /add jenkins ; 
    wmic useraccount WHERE Name=jenkins set PasswordExpires=false; 
}
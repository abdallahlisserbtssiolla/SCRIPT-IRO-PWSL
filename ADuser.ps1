Import-Module ActiveDirectory

$CSVFile = "C:\Users\AdminDomainIRO.LATECH94\Desktop\AD.csv"

$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

$cheminOUUtilisateurs = "OU=Adhérents,OU=LATECH,DC=latech94,DC=local"

$ProfilPath = "\\DC-LATECH94\Données_Comptes$\%username%"  

foreach ($Utilisateur in $CSVData) {
    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurLogin = ($UtilisateurPrenom.Substring(0,1) + "." + $UtilisateurNom).ToLower()
    $UtilisateurEmail = "$UtilisateurLogin@latech94.local"
    $UtilisateurMotDePasse = "Azerty@latech94" 
    $UtilisateurFonction = $Utilisateur.Fonction

    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
        Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
    } else {
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@latech94.local" `
                    -EmailAddress $UtilisateurEmail `
                    -Title $UtilisateurFonction `
                    -Path $cheminOUUtilisateurs `
                    -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true `
                    -ProfilePath ($ProfilPath -replace "%username%", $UtilisateurLogin)

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
    
$Group1 = "Mardi1"
$Group2 = "Mardi2"
$Group3= "Jeudi1"
$Group4 = "Jeudi2"
$Group5="visiteurs"
if ($Utilisateur.Groupe -eq "Mardi1") {
        Add-ADGroupMember -Identity $Group1 -Members $UtilisateurLogin
    }
    elseif ($Utilisateur.Groupe -eq "Mardi2") {
        Add-ADGroupMember -Identity $Group2 -Members $UtilisateurLogin
    }
    elseif ($Utilisateur.Groupe -eq "Jeudi1") {
    Add-ADGroupMember -Identity $Group3 -Members $UtilisateurLogin
    }
    elseif ($Utilisateur.Groupe -eq "Jeudi2") {
    Add-ADGroupMember -Identity $Group4 -Members $UtilisateurLogin
    }
    elseif ($Utilisateur.Groupe -eq "visiteurs") {
    Add-ADGroupMember -Identity $Group5 -Members $UtilisateurLogin
    }
}

Import-Module ActiveDirectory

$UtilisateurNom = Read-Host "Entrez un nom de famille"
$UtilisateurPrenom = Read-Host "Entrez un prénom"
$UtilisateurGroupe = Read-Host "Entrez le groupe (Mardi1, Mardi2, Jeudi1, Jeudi2, visiteurs)"

$cheminOUUtilisateurs = "OU=Adhérents,OU=LATECH,DC=latech94,DC=local"
$ProfilPath = "\\DC-LATECH94\Données_Comptes$\%username%"
$UtilisateurLogin = ($UtilisateurPrenom.Substring(0,1) + "." + $UtilisateurNom).ToLower()
$UtilisateurEmail = "$UtilisateurLogin@latech94.local"
$UtilisateurMotDePasse = "Azerty@latech94"


if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
    Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
} else {
    # Créer l'utilisateur
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

    $Group1 = "Mardi1"
    $Group2 = "Mardi2"
    $Group3 = "Jeudi1"
    $Group4 = "Jeudi2"
    $Group5 = "visiteurs"

    switch ($UtilisateurGroupe) {
        "Mardi1" { Add-ADGroupMember -Identity $Group1 -Members $UtilisateurLogin }
        "Mardi2" { Add-ADGroupMember -Identity $Group2 -Members $UtilisateurLogin }
        "Jeudi1" { Add-ADGroupMember -Identity $Group3 -Members $UtilisateurLogin }
        "Jeudi2" { Add-ADGroupMember -Identity $Group4 -Members $UtilisateurLogin }
        "visiteurs" { Add-ADGroupMember -Identity $Group5 -Members $UtilisateurLogin }
        default { Write-Warning "Groupe inconnu: $UtilisateurGroupe" }
    }
}

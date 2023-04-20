$PrivilegedGroups = 'Domain Admins', 'Enterprise Admins', 'Schema Admins', 'Administrators'

$PrivilegedMembers = @()

foreach ($Group in $PrivilegedGroups) {
    try {
        $GroupMembers = Get-ADGroupMember -Identity $Group -Recursive -ErrorAction Stop
    } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Warning "El grupo '$Group' no se encontró en el Directorio Activo."
        continue
    } catch {
        Write-Warning "Se encontró un error inesperado para el grupo '$Group': $_"
        continue
    }

    foreach ($Member in $GroupMembers) {
        try {
            $UserInfo = Get-ADUser -Identity $Member -Properties PasswordNeverExpires, Enabled, PasswordLastSet -ErrorAction Stop
            
            if ($UserInfo.PasswordNeverExpires -eq $true -and $UserInfo.Enabled -eq $true) {
                $PrivilegedMembers += $UserInfo | Select-Object Name, SamAccountName, Enabled, PasswordNeverExpires, PasswordLastSet
            }
        } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "El usuario '$($Member.Name)' no se encontró en el Directorio Activo."
        } catch {
            Write-Warning "Se encontró un error inesperado para el usuario '$($Member.Name)': $_"
        }
    }
}

$UniquePrivilegedMembers = $PrivilegedMembers | Sort-Object -Unique -Property SamAccountName

# Exporta los resultados a un archivo CSV
$UniquePrivilegedMembers | Export-Csv -Path "PrivilegedMembers.csv" -NoTypeInformation -Encoding UTF8

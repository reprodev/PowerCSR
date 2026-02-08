######################################################################################
# PowerCSR V1.0 - Released 23/01/2024                                                #
#                                                                                    #
# Script Created by ReproDev:   https://https://github.com/reprodev/PowerCSR/        #
# Released Under MIT Licence                                                         # 
# Check out other projects :    https://github.com/reprodev/                         #
# Why not buy me a coffee? :    https://ko-fi.com/reprodev                           #
#                                                                                    #
######################################################################################

# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'PowerCSR V1.0'
$form.Size = New-Object System.Drawing.Size(650,700)  # Increased size for SAN field

# Function to add a label and textbox
function Add-InputField($form, $labelText, $position, $isPassword) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(15, $position)
    $label.Size = New-Object System.Drawing.Size(180, 40)  # Increased size
    $label.Text = $labelText
    $label.Font = New-Object System.Drawing.Font("Arial", 12)  # Increased font size for label
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(195, $position)
    $textBox.Size = New-Object System.Drawing.Size(395, 30)  # Increased size
    $textBox.Font = New-Object System.Drawing.Font("Arial", 12)  # Increased font size for input box
    if ($isPassword) { $textBox.UseSystemPasswordChar = $true }
    $form.Controls.Add($textBox)

    return $textBox
}

$commonName = Add-InputField $form 'Common Name (CN):' 30 $false
$organization = Add-InputField $form 'Organization (O):' 75 $false
$organizationalUnit = Add-InputField $form 'Organizational Unit (OU):' 120 $false
$country = Add-InputField $form 'Country (C):' 170 $false
$state = Add-InputField $form 'State (ST):' 215 $false
$locality = Add-InputField $form 'Locality (L):' 260 $false
# $email = Add-InputField $form 'Email (Email):' 305 $false

$sanLabel = New-Object System.Windows.Forms.Label
$sanLabel.Location = New-Object System.Drawing.Point(15, 305)
$sanLabel.Size = New-Object System.Drawing.Size(180, 40)
$sanLabel.Text = 'SAN (Optional):'
$sanLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$form.Controls.Add($sanLabel)

$sanTextBox = New-Object System.Windows.Forms.TextBox
$sanTextBox.Location = New-Object System.Drawing.Point(195, 305)
$sanTextBox.Size = New-Object System.Drawing.Size(395, 30)
$sanTextBox.Font = New-Object System.Drawing.Font("Arial", 12)
$sanTextBox.Text = ''
$form.Controls.Add($sanTextBox)

$sanHelpLabel = New-Object System.Windows.Forms.Label
$sanHelpLabel.Location = New-Object System.Drawing.Point(195, 335)
$sanHelpLabel.Size = New-Object System.Drawing.Size(395, 40)
$sanHelpLabel.Text = 'Format: DNS:example.com,DNS:www.example.com,IP:1.2.3.4'
$sanHelpLabel.Font = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Italic)
$sanHelpLabel.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($sanHelpLabel)

$password1 = Add-InputField $form 'Password:' 395 $true
$password2 = Add-InputField $form 'Confirm Password:' 440 $true

# Auto-Fill Function
function Auto-FillDomainInfo {
    try {
        # Get Windows geographic region country code from registry (only if country field is empty)
        if ([string]::IsNullOrWhiteSpace($country.Text)) {
            try {
                $geoKey = Get-ItemProperty -Path "HKCU:\Control Panel\International\Geo" -ErrorAction SilentlyContinue
                if ($geoKey -and $geoKey.Nation) {
                    # Get the GeoId and convert it using .NET
                    $geoId = $geoKey.Nation
                    $cultures = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::SpecificCultures)
                    foreach ($culture in $cultures) {
                        $region = New-Object System.Globalization.RegionInfo($culture.Name)
                        if ($region.GeoId -eq $geoId) {
                            $country.Text = $region.TwoLetterISORegionName
                            break
                        }
                    }
                }
            } catch {
                # Fallback to current region if registry lookup fails
                try {
                    $regionInfo = [System.Globalization.RegionInfo]::CurrentRegion
                    $country.Text = $regionInfo.TwoLetterISORegionName
                } catch {
                    # Silent fail for country
                }
            }
        }
        
        # Get domain information (only populate if fields are empty)
        $hostname = [System.Net.Dns]::GetHostName()
        $domainName = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
        
        if ($domainName) {
            $fqdn = "$hostname.$domainName"
            if ([string]::IsNullOrWhiteSpace($commonName.Text)) {
                $commonName.Text = $fqdn
            }
            
            # Build SAN entries
            if ([string]::IsNullOrWhiteSpace($sanTextBox.Text)) {
                $sanEntries = @()
                $sanEntries += "DNS:$fqdn"
                $sanEntries += "DNS:$hostname"
                if ($domainName) {
                    $sanEntries += "DNS:$domainName"
                }
                
                # Get local IP addresses (excluding loopback)
                $ipAddresses = [System.Net.Dns]::GetHostAddresses($hostname) | 
                    Where-Object { $_.AddressFamily -eq 'InterNetwork' -and $_.IPAddressToString -ne '127.0.0.1' }
                
                foreach ($ip in $ipAddresses) {
                    $sanEntries += "IP:$($ip.IPAddressToString)"
                }
                
                $sanTextBox.Text = $sanEntries -join ','
            }
        } else {
            if ([string]::IsNullOrWhiteSpace($commonName.Text)) {
                $commonName.Text = $hostname
            }
            if ([string]::IsNullOrWhiteSpace($sanTextBox.Text)) {
                $sanTextBox.Text = "DNS:$hostname"
            }
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error auto-filling: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# SAN Validation Function
function Validate-SAN {
    param([string]$sanInput)
    
    if ([string]::IsNullOrWhiteSpace($sanInput)) {
        return @{ Valid = $true; Message = '' }
    }
    
    $sanEntries = $sanInput -split ','
    $validPrefixes = @('DNS:', 'IP:', 'email:', 'URI:')
    
    foreach ($entry in $sanEntries) {
        $entry = $entry.Trim()
        if ([string]::IsNullOrWhiteSpace($entry)) {
            return @{ Valid = $false; Message = 'Empty SAN entry detected. Remove extra commas.' }
        }
        
        $hasValidPrefix = $false
        foreach ($prefix in $validPrefixes) {
            if ($entry.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                $hasValidPrefix = $true
                $value = $entry.Substring($prefix.Length)
                if ([string]::IsNullOrWhiteSpace($value)) {
                    return @{ Valid = $false; Message = "SAN entry '$entry' has no value after prefix." }
                }
                break
            }
        }
        
        if (-not $hasValidPrefix) {
            return @{ Valid = $false; Message = "Invalid SAN entry: '$entry'. Must start with DNS:, IP:, email:, or URI:" }
        }
    }
    
    return @{ Valid = $true; Message = '' }
}

# Create Auto-Fill button
$autoFillButton = New-Object System.Windows.Forms.Button
$autoFillButton.Location = New-Object System.Drawing.Point(50,595)
$autoFillButton.Size = New-Object System.Drawing.Size(150,30)  
$autoFillButton.Text = 'Auto-Fill'
$autoFillButton.Font = New-Object System.Drawing.Font("Arial", 12)

# Add click event for Auto-Fill
$autoFillButton.Add_Click({
    Auto-FillDomainInfo
})

$form.Controls.Add($autoFillButton)

# Create Generate CSR button 
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(225,595)
$button.Size = New-Object System.Drawing.Size(150,30)  
$button.Text = 'Generate CSR'
$button.Font = New-Object System.Drawing.Font("Arial", 12)  

# Add click event for CSR generation
$button.Add_Click({
    if ($password1.Text -ne $password2.Text) {
        [System.Windows.Forms.MessageBox]::Show('Passwords do not match', 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    # Validate SAN if provided
    $sanValidation = Validate-SAN -sanInput $sanTextBox.Text
    if (-not $sanValidation.Valid) {
        [System.Windows.Forms.MessageBox]::Show($sanValidation.Message, 'SAN Validation Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $subjectParts = @()
    if ($commonName.Text) { $subjectParts += "CN=$($commonName.Text)" }
    if ($organization.Text) { $subjectParts += "O=$($organization.Text)" }
    if ($organizationalUnit.Text) { $subjectParts += "OU=$($organizationalUnit.Text)" }
    if ($country.Text) { $subjectParts += "C=$($country.Text)" }
    if ($state.Text) { $subjectParts += "ST=$($state.Text)" }
    if ($locality.Text) { $subjectParts += "L=$($locality.Text)" }

    $subjectString = $subjectParts -join '/'

    # Constructing the OpenSSL command
    $cmd = "openssl req -new -newkey rsa:2048 -nodes -keyout mykey.key -out mycsr.csr " +
           "-passout pass:$($password1.Text) -subj '/$subjectString'"
    
    # Add SAN extension if provided
    if (-not [string]::IsNullOrWhiteSpace($sanTextBox.Text)) {
        $sanValue = $sanTextBox.Text.Trim()
        $cmd += " -addext 'subjectAltName=$sanValue'"
    }
    try {
        Invoke-Expression $cmd
        [System.Windows.Forms.MessageBox]::Show('CSR Generation Complete', 'Success', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($button)

#Show the form
$form.ShowDialog()

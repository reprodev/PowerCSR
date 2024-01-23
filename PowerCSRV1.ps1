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
$form.Text = 'CSR Generator'
$form.Size = New-Object System.Drawing.Size(650,630)  # Increased size

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

# Adding input fields with increased spacing
$commonName = Add-InputField $form 'Common Name (CN):' 30 $false
$organization = Add-InputField $form 'Organization (O):' 75 $false
$organizationalUnit = Add-InputField $form 'Organizational Unit (OU):' 120 $false
$country = Add-InputField $form 'Country (C):' 170 $false
$state = Add-InputField $form 'State (ST):' 215 $false
$locality = Add-InputField $form 'Locality (L):' 260 $false
# $email = Add-InputField $form 'Email (Email):' 305 $false
$password1 = Add-InputField $form 'Password:' 350 $true
$password2 = Add-InputField $form 'Confirm Password:' 395 $true

# Create a button with increased size
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(225,525)
$button.Size = New-Object System.Drawing.Size(150,30)  # Increased size
$button.Text = 'Generate CSR'
$button.Font = New-Object System.Drawing.Font("Arial", 12)  # Increased font size for button

# Add click event for CSR generation
$button.Add_Click({
    if ($password1.Text -ne $password2.Text) {
        [System.Windows.Forms.MessageBox]::Show('Passwords do not match', 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
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

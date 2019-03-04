Import-Module $PSScriptRoot\PCLT-Library.psm1 -Force
Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Core, WindowsFormsIntegration
$syncHash = [hashtable]::Synchronized(@{})
$syncHash.WorkingPath = $PSScriptRoot
$PCLTRegPath = "HKCU:\SOFTWARE\PCLT"

#Set SQL Search Defaults if not present
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value FirstSource))    { Set-CustomRegValue -Path $PCLTRegPath -Name FirstSource -Value "Active Directory" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SecondSource))   { Set-CustomRegValue -Path $PCLTRegPath -Name SecondSource -Value "N/A" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBServer))    { Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBServer -Value "SQLServer" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBName))      { Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBName -Value "Database" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBTable))     { Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBTable -Value "Table" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBColumn))    { Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBColumn -Value "ComputerName" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SQLQuery))       { Set-CustomRegValue -Path $PCLTRegPath -Name SQLQuery -Value "SELECT * FROM" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SCCMDBServer))   { Set-CustomRegValue -Path $PCLTRegPath -Name SCCMDBServer -Value "SCCM01" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value SCCMDBName))     { Set-CustomRegValue -Path $PCLTRegPath -Name SCCMDBName -Value "CM_CCM" }
if (!(Get-CustomRegValue -Path $PCLTRegPath -Value HideSettings))   { Set-CustomRegValue -Path $PCLTRegPath -Name HideSettings -Value "0" }

$syncHash.FirstSourceCollection = @("Active Directory","SQL","SCCM")
$syncHash.SecondSourceCollection = @("N/A","Active Directory","SQL","SCCM")

$syncHash.HamburgerBase64 = "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"
# Create a streaming image by streaming the base64 string to a bitmap streamsource
$syncHash.HamburgerIcon = New-Object System.Windows.Media.Imaging.BitmapImage
$syncHash.HamburgerIcon.BeginInit()
$syncHash.HamburgerIcon.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($syncHash.HamburgerBase64)
$syncHash.HamburgerIcon.EndInit()
$syncHash.HamburgerIcon.Freeze()

$syncHash.MinimiseBase64 = "AAABAAEAHBwAAAEAIADYDAAAFgAAACgAAAAcAAAAOAAAAAEAIAAAAAAAQAwAAMMOAADDDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAO8AAAAcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA7wAAABwAAAAAAAAAAAAAAAAAAAAAAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAAAAAAAAAAAAAAAAAAAAAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAAAAAAAAAAAAAAAAAAAAAAAcAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAADkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAADkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4AAAcMAAADDAAAAwwAAAMMAAADDgAABw////8P////D////w////8P////D////w////8P////D////w////8P////D////w////8P////D////w////8P////D////w////8P////D////w////8A=="
# Create a streaming image by streaming the base64 string to a bitmap streamsource
$syncHash.MinimiseIcon = New-Object System.Windows.Media.Imaging.BitmapImage
$syncHash.MinimiseIcon.BeginInit()
$syncHash.MinimiseIcon.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($syncHash.MinimiseBase64)
$syncHash.MinimiseIcon.EndInit()
$syncHash.MinimiseIcon.Freeze()

$syncHash.CloseBase64 = "AAABAAEAHBwAAAEAIADYDAAAFgAAACgAAAAcAAAAOAAAAAEAIAAAAAAAQAwAAMMOAADDDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAAADkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAAP8AAAD/AAAA0wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAA5AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAADTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAADkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA0wAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAADTAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADTAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADTAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAADTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA0wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAADTAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAADTAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA0wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAANMAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOQAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADTAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5AAAA/wAAAP8AAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMAAAD/AAAA/wAAAP8AAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADkAAAD/AAAA/wAAANMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0wAAAP8AAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOQAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAAOQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////8P////D8//Pw+H/h8PA/wPDgH4BwwA8AMMAGADDgAABw8AAA8PgAAfD8AAPw/gAH8P8AD/D/AA/w/gAH8PwAA/D4AAHw8AAA8OAAAHDABgAwwA8AMOAfgHDwP8Dw+H/h8Pz/8/D////w////8A=="
# Create a streaming image by streaming the base64 string to a bitmap streamsource
$syncHash.CloseIcon = New-Object System.Windows.Media.Imaging.BitmapImage
$syncHash.CloseIcon.BeginInit()
$syncHash.CloseIcon.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($syncHash.CloseBase64)
$syncHash.CloseIcon.EndInit()
$syncHash.CloseIcon.Freeze()

$formRunspace = [runspacefactory]::CreateRunspace()
$formRunspace.ApartmentState = "STA"
$formRunspace.ThreadOptions = "ReuseThread"         
$formRunspace.Open()
$formRunspace.SessionStateProxy.SetVariable("syncHash", $syncHash)
$psCmd = [PowerShell]::Create().AddScript( {   
    [xml]$xaml = (Get-Content ($syncHash.WorkingPath + "\PCLT.xaml"))
    $syncHash.SubmitPressed = $false
    $SyncHash.EndScript = $False
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window = [Windows.Markup.XamlReader]::Load( $reader )
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object { $syncHash.($_.Name) = $syncHash.Window.FindName($_.Name) }   ### This line grabs all the names and binds them as properties of $syncHash
 
    $syncHash.Window.Add_Closing( {
        $syncHash.EndScript = $true
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.Window.Close()
            }))
        })
    
    $syncHash.Close.add_click( {
        $syncHash.EndScript = $true
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.Window.Close()
            }))
        })
    
    $syncHash.Minimise.add_click( {
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.Window.WindowState = "Minimized"
            }))
        })
    
    ### Logic to do stuff in loop later on
    $syncHash.SignIn_Button.add_click({ $syncHash.SignInPressed = $true })
    $syncHash.Hamburger.add_click({ $syncHash.HamburgerPressed = $true })
    $syncHash.Settings_Save.add_click({ $syncHash.SettingsSavePressed = $true })

    ### Logic for events
    $syncHash.Search_TextBox.add_KeyDown({ if ($_.Key -eq "Enter") { $syncHash.SearchPressed = $true }})
    $syncHash.SignIn_PasswordPasswordBox.add_KeyDown({ if ($_.Key -eq "Enter") { $syncHash.SignInPressed = $true }})
    $syncHash.SignIn_UserNameTextBox.add_KeyDown({ if ($_.Key -eq "Enter") { $syncHash.SignInPressed = $true }})
    
    # Hamburger icon 
    $syncHash.HamburgerImage = New-Object System.Windows.Controls.Image
    $syncHash.HamburgerImage.Source = $syncHash.HamburgerIcon
    $syncHash.HamburgerImage.Stretch = 'Fill'
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Hamburger.BorderBruse = $syncHash.Window.Background
        $syncHash.Hamburger.Background = $syncHash.Window.Background
        $syncHash.Hamburger.Content = $syncHash.HamburgerImage
        }))
    
    # Close icon 
    $syncHash.CloseImage = New-Object System.Windows.Controls.Image
    $syncHash.CloseImage.Source = $syncHash.CloseIcon
    $syncHash.CloseImage.Stretch = 'Fill'
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Close.BorderBruse = $syncHash.Window.Background
        $syncHash.Close.Background = $syncHash.Window.Background
        $syncHash.Close.Content = $syncHash.CloseImage
        }))
    
    # Minimise icon 
    $syncHash.MinimiseImage = New-Object System.Windows.Controls.Image
    $syncHash.MinimiseImage.Source = $syncHash.MinimiseIcon
    $syncHash.MinimiseImage.Stretch = 'Fill'
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Minimise.BorderBruse = $syncHash.Window.Background
        $syncHash.Minimise.Background = $syncHash.Window.Background
        $syncHash.Minimise.Content = $syncHash.MinimiseImage
        }))

    # Settings First Source List Box  
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Settings_FirstSourceComboBox.ItemsSource = $syncHash.FirstSourceCollection
        }))

    # Settings Second Source List Box  
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Settings_SecondSourceComboBox.ItemsSource = $syncHash.SecondSourceCollection
        }))

    $appContext = New-Object System.Windows.Forms.ApplicationContext 
    [void][System.Windows.Forms.Application]::Run($appContext)
    $syncHash.Error = $Error
})
$psCmd.Runspace = $formRunspace
$Null = $psCmd.BeginInvoke()

do { start-sleep -MilliSeconds 100 } until ($syncHash.Window.IsVisible -eq $False)
$syncHash.SearchPressed = $false
$syncHash.SignInPressed = $false
$syncHash.ValidCredentials = $false        
$syncHash.HamburgerPressed = $false
$syncHash.SettingsSavePressed = $false

if ((Get-CustomRegValue -Path $PCLTRegPath -Value HideSettings) -eq "0")
{
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Hamburger.Visibility = "Visible"
        }))
}
$syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
    [System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($syncHash.window)
    $syncHash.window.Add_MouseLeftButtonDown({
        $_.Handled = $true
        $syncHash.window.DragMove()
        })
    $SyncHash.window.Show()
    $SyncHash.window.Activate()
    $syncHash.Search_TextBox.Focus() | out-null 
    
    }))

do
{
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.SearchTextBoxText = $syncHash.Search_TextBox.Text.Trim()
        }))        
        
    if ($syncHash.SignInPressed)
    {
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.SignIn_UserName =     $syncHash.SignIn_UserNameTextBox.Text
            $syncHash.SignIn_Password =     $syncHash.SignIn_PasswordPasswordBox.SecurePassword
            }))
        if (($null -ne $syncHash.SignIn_UserName) -and ($null -ne $syncHash.SignIn_Password))
        {
            if ($syncHash.SignIn_UserName -notmatch '\\') 
            { $syncHash.SignIn_UserName = (get-wmiobject -query "select * from win32_computersystem").Domain + "\" + $syncHash.SignIn_UserName }
            $SignInCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $syncHash.SignIn_UserName, $syncHash.SignIn_Password
            if (Test-Credential -Credential $SignInCredentials)
            {
                $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
                    $syncHash.SignIn_UserNameLabel.Visibility = "Hidden"
                    $syncHash.SignIn_PasswordLabel.Visibility = "Hidden"
                    $syncHash.SignIn_UserNameTextBox.Visibility = "Hidden"
                    $syncHash.SignIn_PasswordPasswordBox.Visibility = "Hidden"
                    $syncHash.SignIn_Button.Visibility = "Hidden"
                    }))
                $syncHash.ValidCredentials = $true
            }
        }
        $syncHash.SignInPressed = $false
    }
    
    if ($syncHash.HamburgerPressed)
    {
        if ($syncHash.ValidCredentials)
        {
            $syncHash.Settings_FirstSourceComboBoxValue =  (Get-CustomRegValue -Path $PCLTRegPath -Value FirstSource)
            $syncHash.Settings_SecondSourceComboBoxValue = (Get-CustomRegValue -Path $PCLTRegPath -Value SecondSource)
            $syncHash.Settings_SQLDBServer_TextBoxValue =  (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBServer)
            $syncHash.Settings_SQLDBName_TextBoxValue =    (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBName)
            $syncHash.Settings_SQLDBTable_TextBoxValue =   (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBTable)
            $syncHash.Settings_SQLDBColumn_TextBoxValue =  (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBColumn)
            $syncHash.Settings_SQLQueryTextBoxValue =      (Get-CustomRegValue -Path $PCLTRegPath -Value SQLQuery)
            $syncHash.Settings_SCCMDBServer_TextBoxValue = (Get-CustomRegValue -Path $PCLTRegPath -Value SCCMDBServer)
            $syncHash.Settings_SCCMDBName_TextBoxValue =   (Get-CustomRegValue -Path $PCLTRegPath -Value SCCMDBName)

            $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
                $syncHash.Settings_FirstSourceComboBox.SelectedItem =  $syncHash.Settings_FirstSourceComboBoxValue
                $syncHash.Settings_SecondSourceComboBox.SelectedItem = $syncHash.Settings_SecondSourceComboBoxValue
                $syncHash.Settings_SQLDBServer_TextBox.Text =          $syncHash.Settings_SQLDBServer_TextBoxValue
                $syncHash.Settings_SQLDBName_TextBox.Text =            $syncHash.Settings_SQLDBName_TextBoxValue
                $syncHash.Settings_SQLDBTable_TextBox.Text =           $syncHash.Settings_SQLDBTable_TextBoxValue
                $syncHash.Settings_SQLDBColumn_TextBox.Text =          $syncHash.Settings_SQLDBColumn_TextBoxValue
                $syncHash.Settings_SQLQueryTextBox.Text =              $syncHash.Settings_SQLQueryTextBoxValue
                $syncHash.Settings_SCCMDBServer_TextBox.Text =         $syncHash.Settings_SCCMDBServer_TextBoxValue
                $syncHash.Settings_SCCMDBName_TextBox.Text =           $syncHash.Settings_SCCMDBName_TextBoxValue
                $syncHash.Tab_Settings.Visibility = "Collapsed"
                $syncHash.Tab_Settings.IsSelected = "True"
                }))
        }
        $syncHash.HamburgerPressed = $false
    }
    
    if ($syncHash.SettingsSavePressed)
    {
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.Settings_FirstSourceComboBoxValue =  $syncHash.Settings_FirstSourceComboBox.SelectedItem
            $syncHash.Settings_SecondSourceComboBoxValue = $syncHash.Settings_SecondSourceComboBox.SelectedItem
            $syncHash.Settings_SQLDBServer_TextBoxValue =  $syncHash.Settings_SQLDBServer_TextBox.Text
            $syncHash.Settings_SQLDBName_TextBoxValue =    $syncHash.Settings_SQLDBName_TextBox.Text
            $syncHash.Settings_SQLDBTable_TextBoxValue =   $syncHash.Settings_SQLDBTable_TextBox.Text
            $syncHash.Settings_SQLDBColumn_TextBoxValue =  $syncHash.Settings_SQLDBColumn_TextBox.Text
            $syncHash.Settings_SQLQueryTextBoxValue =      $syncHash.Settings_SQLQueryTextBox.Text
            $syncHash.Settings_SCCMDBServer_TextBoxValue = $syncHash.Settings_SCCMDBServer_TextBox.Text
            $syncHash.Settings_SCCMDBName_TextBoxValue =   $syncHash.Settings_SCCMDBName_TextBox.Text
            $syncHash.Tab_Hidden.Visibility = "Collapsed"
            $syncHash.Tab_Settings.IsSelected = "False"
            $syncHash.Tab_Hidden.IsSelected = "True"
            }))

        Set-CustomRegValue -Path $PCLTRegPath -Name FirstSource -Value $syncHash.Settings_FirstSourceComboBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SecondSource -Value $syncHash.Settings_SecondSourceComboBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBServer -Value $syncHash.Settings_SQLDBServer_TextBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBName -Value $syncHash.Settings_SQLDBName_TextBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBTable -Value $syncHash.Settings_SQLDBTable_TextBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SQLDBColumn -Value $syncHash.Settings_SQLDBColumn_TextBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SQLQuery -Value $syncHash.Settings_SQLQueryTextBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SCCMDBServer -Value $syncHash.Settings_SCCMDBServer_TextBoxValue
        Set-CustomRegValue -Path $PCLTRegPath -Name SCCMDBName -Value $syncHash.Settings_SCCMDBName_TextBoxValue
        $syncHash.SettingsSavePressed = $false
    }

    if ($syncHash.SearchPressed)
    {
        if (($Null -ne $syncHash.SearchTextBoxText) -and ($syncHash.SearchTextBoxText.Length -lt 16))
        {
            $SQLDBServer =  (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBServer)
            $SQLDBName =    (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBName)
            $SQLDBTable =   (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBTable)
            $SQLDBColumn =  (Get-CustomRegValue -Path $PCLTRegPath -Value SQLDBColumn)
            $SQLQuery =     (Get-CustomRegValue -Path $PCLTRegPath -Value SQLQuery)
            Set-ObjectsToHidden -RegExMatch '^Main_Label'
            $HashTable = @{}
            $Query = $SQLQuery + " " + $SQLDBTable + " WHERE " + $SQLDBColumn + " LIKE '%" + $syncHash.SearchTextBoxText + "%'"
            $HashTable = (Get-MainLabelsAndContentFromSQL -query $Query -DBServer $SQLDBServer -DBName $SQLDBName)
            
            #Set Computer Name
            $PCNameQuery = "SELECT " + $SQLDBColumn + " FROM " + $SQLDBTable + " WHERE " + $SQLDBColumn + " LIKE '%" + $syncHash.SearchTextBoxText + "%'"
            $syncHash.FoundPC = (Read-FromSQL -DBServer $SQLDBServer -DBName $SQLDBName -Query $PCNameQuery).$SQLDBColumn
            $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
                $syncHash.("Main_Label01").Content = "Computer Name: "
                $syncHash.("Main_Label01Content").Content = $syncHash.FoundPC
                $syncHash.("Main_Label01").Visibility = "Visible"
                $syncHash.("Main_Label01Content").Visibility = "Visible"
                }))

            if ($HashTable.Count -gt 0)
            {
                $syncHash.Counter = 1
                foreach ($Entry in $HashTable.keys) 
                { 
                    $syncHash.Counter++
                    $Null = $syncHash.Label
                    $Null = $syncHash.Content
                    $syncHash.Label = $Entry + ": "
                    $syncHash.Content = $HashTable.$Entry
                    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
                        $syncHash.("Main_Label" + ("{0:D2}" -f $syncHash.Counter)).Content = $syncHash.Label
                        $syncHash.("Main_Label" + ("{0:D2}" -f $syncHash.Counter) + "Content").Content = $syncHash.Content
                        $syncHash.("Main_Label" + ("{0:D2}" -f $syncHash.Counter)).Visibility = "Visible"
                        $syncHash.("Main_Label" + ("{0:D2}" -f $syncHash.Counter) + "Content").Visibility = "Visible"
                        }))
                }
            }
            $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.Search_TextBox.Text = ""
            }))

            if (($HashTable.Count -gt 0) -and ($syncHash.ValidCredentials))
            {
                if (Get-PCStatus -ComputerName $syncHash.FoundPC)
                {
                    Write-Host "Trigger buttons"
                }   
            }
        }
        $syncHash.SearchPressed = $false
    }

    Start-Sleep -Milliseconds 100
}Until ($syncHash.EndScript)
Import-Module $PSScriptRoot\PCLT-Library.psm1 -Force
Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Core, WindowsFormsIntegration
$syncHash = [hashtable]::Synchronized(@{})
$syncHash.WorkingPath = $PSScriptRoot

$syncHash.HamburgerBase64 = "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"
# Create a streaming image by streaming the base64 string to a bitmap streamsource
$syncHash.HamburgerIcon = New-Object System.Windows.Media.Imaging.BitmapImage
$syncHash.HamburgerIcon.BeginInit()
$syncHash.HamburgerIcon.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($syncHash.HamburgerBase64)
$syncHash.HamburgerIcon.EndInit()
$syncHash.HamburgerIcon.Freeze()

$formRunspace = [runspacefactory]::CreateRunspace()
$formRunspace.ApartmentState = "STA"
$formRunspace.ThreadOptions = "ReuseThread"         
$formRunspace.Open()
$formRunspace.SessionStateProxy.SetVariable("syncHash", $syncHash)
$Data = (Get-Date)
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
    
    ### Logic to trigger buttons during DO loop later on
    $syncHash.Search_Button.add_click({ $syncHash.SearchPressed = $true })
    $syncHash.SignIn_Button.add_click({ $syncHash.SignInPressed = $true })
    
    
    # Hamburger icon 
    $syncHash.HamburgerImage = New-Object System.Windows.Controls.Image
    $syncHash.HamburgerImage.Source = $syncHash.HamburgerIcon
    $syncHash.HamburgerImage.Stretch = 'Fill'
    $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
        $syncHash.Hamburger.BorderBruse = $syncHash.Window.Background
        $syncHash.Hamburger.Background = $syncHash.Window.Background
        $syncHash.Hamburger.Content = $syncHash.HamburgerImage
        }))

    
    $appContext = New-Object System.Windows.Forms.ApplicationContext 
    [void][System.Windows.Forms.Application]::Run($appContext)
    $syncHash.Error = $Error
})
$psCmd.Runspace = $formRunspace
$data = $psCmd.BeginInvoke()

do { start-sleep -MilliSeconds 100 } until ($syncHash.Window.IsVisible -eq $False)
Set-ObjectsToHidden -RegExMatch '^Main_Button'
$syncHash.SearchPressed = $false
$syncHash.SignInPressed = $false
        
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
        $SignInCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $syncHash.SignIn_UserName, $syncHash.SignIn_Password
        Test-Credential -Credential $SignInCredentials
        $syncHash.SignInPressed = $false

    }
    
    if ($syncHash.SearchPressed)
    {
        Set-ObjectsToHidden -RegExMatch '^Main_Label'
        $HashTable = @{}
        $Query = "SELECT * FROM PCs WHERE PCName LIKE '%{0}%'" -f $syncHash.SearchTextBoxText 
        $HashTable = (Get-MainLabelsAndContentFromSQL -query $Query -DBServer "SURFACE\SQLExpress" -DBName PCInfo)
        $syncHash.Counter = 0
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
        $syncHash.Window.Dispatcher.invoke("Normal", [action][scriptblock]::create( {
            $syncHash.Search_TextBox.Text = ""
            }))
        $syncHash.SearchPressed = $false
    }

    Start-Sleep -Milliseconds 100
}Until ($syncHash.EndScript)
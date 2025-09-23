function Select-OSDWSWinPELanguage {
    <#
    .SYNOPSIS
        Selects languages for WinPE build.

    .DESCRIPTION
        This function displays available WinPE languages in an Out-GridView and returns the selected languages.
        The function provides all supported Windows ADK languages for WinPE builds.

    .INPUTS
        None.

        You cannot pipe input to this cmdlet.

    .OUTPUTS
        System.String[]

        This function returns the selected languages as a string array.

    .EXAMPLE
        Select-OSDWSWinPELanguage
        Will display all available languages and return the selected languages.

    .NOTES
        David Segura
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param ()
    #=================================================
    $Error.Clear()
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Start"
    #=================================================
    
    # Define supported languages with friendly names
    $LanguageOptions = @(
        [PSCustomObject]@{ Code = 'en-us'; Name = 'English (United States)'; Selected = $true }
        [PSCustomObject]@{ Code = 'ar-sa'; Name = 'Arabic (Saudi Arabia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'bg-bg'; Name = 'Bulgarian (Bulgaria)'; Selected = $false }
        [PSCustomObject]@{ Code = 'cs-cz'; Name = 'Czech (Czech Republic)'; Selected = $false }
        [PSCustomObject]@{ Code = 'da-dk'; Name = 'Danish (Denmark)'; Selected = $false }
        [PSCustomObject]@{ Code = 'de-de'; Name = 'German (Germany)'; Selected = $false }
        [PSCustomObject]@{ Code = 'el-gr'; Name = 'Greek (Greece)'; Selected = $false }
        [PSCustomObject]@{ Code = 'en-gb'; Name = 'English (United Kingdom)'; Selected = $false }
        [PSCustomObject]@{ Code = 'es-es'; Name = 'Spanish (Spain)'; Selected = $false }
        [PSCustomObject]@{ Code = 'es-mx'; Name = 'Spanish (Mexico)'; Selected = $false }
        [PSCustomObject]@{ Code = 'et-ee'; Name = 'Estonian (Estonia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'fi-fi'; Name = 'Finnish (Finland)'; Selected = $false }
        [PSCustomObject]@{ Code = 'fr-ca'; Name = 'French (Canada)'; Selected = $false }
        [PSCustomObject]@{ Code = 'fr-fr'; Name = 'French (France)'; Selected = $false }
        [PSCustomObject]@{ Code = 'he-il'; Name = 'Hebrew (Israel)'; Selected = $false }
        [PSCustomObject]@{ Code = 'hr-hr'; Name = 'Croatian (Croatia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'hu-hu'; Name = 'Hungarian (Hungary)'; Selected = $false }
        [PSCustomObject]@{ Code = 'it-it'; Name = 'Italian (Italy)'; Selected = $false }
        [PSCustomObject]@{ Code = 'ja-jp'; Name = 'Japanese (Japan)'; Selected = $false }
        [PSCustomObject]@{ Code = 'ko-kr'; Name = 'Korean (Korea)'; Selected = $false }
        [PSCustomObject]@{ Code = 'lt-lt'; Name = 'Lithuanian (Lithuania)'; Selected = $false }
        [PSCustomObject]@{ Code = 'lv-lv'; Name = 'Latvian (Latvia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'nb-no'; Name = 'Norwegian Bokmål (Norway)'; Selected = $false }
        [PSCustomObject]@{ Code = 'nl-nl'; Name = 'Dutch (Netherlands)'; Selected = $false }
        [PSCustomObject]@{ Code = 'pl-pl'; Name = 'Polish (Poland)'; Selected = $false }
        [PSCustomObject]@{ Code = 'pt-br'; Name = 'Portuguese (Brazil)'; Selected = $false }
        [PSCustomObject]@{ Code = 'pt-pt'; Name = 'Portuguese (Portugal)'; Selected = $false }
        [PSCustomObject]@{ Code = 'ro-ro'; Name = 'Romanian (Romania)'; Selected = $false }
        [PSCustomObject]@{ Code = 'ru-ru'; Name = 'Russian (Russia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'sk-sk'; Name = 'Slovak (Slovakia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'sl-si'; Name = 'Slovenian (Slovenia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'sr-latn-rs'; Name = 'Serbian Latin (Serbia)'; Selected = $false }
        [PSCustomObject]@{ Code = 'sv-se'; Name = 'Swedish (Sweden)'; Selected = $false }
        [PSCustomObject]@{ Code = 'th-th'; Name = 'Thai (Thailand)'; Selected = $false }
        [PSCustomObject]@{ Code = 'tr-tr'; Name = 'Turkish (Turkey)'; Selected = $false }
        [PSCustomObject]@{ Code = 'uk-ua'; Name = 'Ukrainian (Ukraine)'; Selected = $false }
        [PSCustomObject]@{ Code = 'zh-cn'; Name = 'Chinese Simplified (China)'; Selected = $false }
        [PSCustomObject]@{ Code = 'zh-tw'; Name = 'Chinese Traditional (Taiwan)'; Selected = $false }
    )

    Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Select languages to add to WinPE (Cancel to use default en-us)"
    $SelectedLanguages = $LanguageOptions | Out-GridView -Title 'Select languages to add to WinPE (Cancel to use default en-us)' -OutputMode Multiple

    if ($SelectedLanguages) {
        $result = $SelectedLanguages | Select-Object -ExpandProperty Code
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] Selected languages: $($result -join ', ')"
        return $result
    }
    else {
        Write-Host -ForegroundColor DarkGray "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] No languages selected, using default: en-us"
        return @('en-us')
    }

    #=================================================
    Write-Verbose "[$(Get-Date -format G)] [$($MyInvocation.MyCommand.Name)] End"
    #=================================================
}
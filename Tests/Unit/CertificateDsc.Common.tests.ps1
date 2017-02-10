$script:ModuleName = 'CertificateDsc.Common'

#region HEADER
# Unit Test Template Version: 1.1.0
[string] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
Import-Module (Join-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath $script:ModuleName)) -ChildPath "$script:ModuleName.psm1") -Force
#endregion HEADER

# Begin Testing
try
{
    InModuleScope $script:ModuleName {
        $DSCResourceName = 'CertificateCommon'
        $invalidThumbprint = 'Zebra'
        $validThumbprint = (
            [System.AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object {
                $_.BaseType.BaseType -eq [System.Security.Cryptography.HashAlgorithm] -and
                ($_.Name -cmatch 'Managed$' -or $_.Name -cmatch 'Provider$')
            } | Select-Object -First 1 | ForEach-Object {
                (New-Object $_).ComputeHash([String]::Empty) | ForEach-Object {
                    '{0:x2}' -f $_
                }
            }
        ) -join ''

        $testFile = 'test.pfx'

        $invalidPath = 'TestDrive:'
        $validPath = "TestDrive:\$testFile"

        Describe "$($script:ModuleName)\Test-CertificatePath" {

            $null | Set-Content -Path $validPath

            Context 'a single existing file by parameter' {
                $result = Test-CertificatePath -Path $validPath
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single missing file by parameter' {
                It 'should throw an exception' {
                    # directories are not valid
                    { Test-CertificatePath -Path $invalidPath } | Should Throw
                }
            }
            Context 'a single missing file by parameter with -Quiet' {
                $result = Test-CertificatePath -Path $invalidPath -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
            Context 'a single existing file by pipeline' {
                $result = $validPath | Test-CertificatePath
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single missing file by pipeline' {
                It 'should throw an exception' {
                    # directories are not valid
                    { $invalidPath | Test-CertificatePath } | Should Throw
                }
            }
            Context 'a single missing file by pipeline with -Quiet' {
                $result =  $invalidPath | Test-CertificatePath -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
        }

        Describe "$($script:ModuleName)\Test-Thumbprint" {

            Context 'a single valid thumbrpint by parameter' {
                $result = Test-Thumbprint -Thumbprint $validThumbprint
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single invalid thumbprint by parameter' {
                It 'should throw an exception' {
                    # directories are not valid
                    { Test-Thumbprint -Thumbprint $invalidThumbprint } | Should Throw
                }
            }
            Context 'a single invalid thumbprint by parameter with -Quiet' {
                $result = Test-Thumbprint $invalidThumbprint -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
            Context 'a single valid thumbprint by pipeline' {
                $result = $validThumbprint | Test-Thumbprint
                It 'should return true' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $true
                }
            }
            Context 'a single invalid thumborint by pipeline' {
                It 'should throw an exception' {
                    # directories are not valid
                    { $invalidThumbprint | Test-Thumbprint } | Should Throw
                }
            }
            Context 'a single invalid thumbprint by pipeline with -Quiet' {
                $result =  $invalidThumbprint | Test-Thumbprint -Quiet
                It 'should return false' {
                    ($result -is [bool]) | Should Be $true
                    $result | Should Be $false
                }
            }
        }

        Describe "$($script:ModuleName)\Find-Certificate" {

            Context 'a single valid thumbrpint by parameter' {
                It 'should exist' {

                }
            }
        }
    }
}
finally
{
    #region FOOTER
    #endregion
}

#!/usr/bin/env pwsh

using namespace System.IO

$ErrorActionPreference = "Stop"

Set-Variable ERROR_REQUIRE_FILE -Option Constant -Value -3
Set-Variable ERROR_ILLEGAL_PARAMETERS -Option Constant -Value -4
Set-Variable ERROR_REQUIRE_TARGET -Option Constant -Value -5

Function BuildSPINOR{
	$output = [FileStream]::new("spi.img", [FileMode]::Create, [FileAccess]::ReadWrite)

    Write-Host "Warning: GPT partitioning is currently unimplemented."

    $boot0 = [Directory]::GetFiles($PSScriptRoot, "boot0_spinor.bin");
	$input = [FileStream]::new($boot0[0], [FileMode]::Open, [FileAccess]::Read)
	$output.Seek(0, [SeekOrigin]::Begin)
	$input.CopyTo($output)
	$input.Close()

	$input = [FileStream]::new("$PSScriptRoot/boot_package.fex", [FileMode]::Open, [FileAccess]::Read)
	$output.Seek(512 * 128, [SeekOrigin]::Begin)
	$input.CopyTo($output)
	$input.Close()

	$input = [FileStream]::new("$PSScriptRoot/sys_partition_nor.bin", [FileMode]::Open, [FileAccess]::Read)
	$output.Seek(512 * 2016, [SeekOrigin]::Begin)
	$input.CopyTo($output)
	$input.Close()

	$output.SetLength(8MB)
	$output.Close()
    Write-Host "SPI U-Boot has been created as spi.img under the current directory."
}

$ret = 0
switch ($args[0]) {
    "BuildSPINOR" {
        $ret = BuildSPINOR
    }
    "" {
        Write-Host "An operation is required.

Supported operations:
        BuildSPINOR
"
        $ret = $ERROR_ILLEGAL_PARAMETERS
    }
    default {
        Write-Host "$_ is not a supported operation!"
        $ret = $ERROR_ILLEGAL_PARAMETERS
    }
}

if ($ret -ne 0) {
    exit $ret
}
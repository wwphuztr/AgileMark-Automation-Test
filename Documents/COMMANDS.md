# ========================================
# 🖱️ MOUSE COORDINATES TRACKER WITH SAVE
# ========================================
# Description: Real-time mouse position tracker for Windows
# Usage: Run in PowerShell, move mouse to see coordinates
#        Press SPACE to save current position
#        Press S to save all collected positions to file
# Exit: Press Ctrl+C to stop
# ========================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Input
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class KeyboardInfo {
        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int vKey);
    }
"@

$savedPositions = @()
$outputFile = "mouse_coordinates_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Mouse Coordinates Tracker" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Move your mouse to see coordinates" -ForegroundColor Green
Write-Host "Press SPACE to save current position" -ForegroundColor Magenta
Write-Host "Press S to save all to file" -ForegroundColor Magenta
Write-Host "Press Ctrl+C to exit`n" -ForegroundColor Red

while ($true) {
    # Get current cursor position
    $pos = [System.Windows.Forms.Cursor]::Position
    
    # Check for SPACE key press (VK_SPACE = 0x20)
    if ([KeyboardInfo]::GetAsyncKeyState(0x20) -band 0x8000) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $savedPositions += [PSCustomObject]@{
            X = $pos.X
            Y = $pos.Y
            Time = $timestamp
        }
        Write-Host "`n✅ Saved position #$($savedPositions.Count): X=$($pos.X), Y=$($pos.Y)" -ForegroundColor Green
        Start-Sleep -Milliseconds 300  # Debounce
    }
    
    # Check for S key press (VK_S = 0x53)
    if ([KeyboardInfo]::GetAsyncKeyState(0x53) -band 0x8000) {
        if ($savedPositions.Count -gt 0) {
            $content = "# Mouse Coordinates - Saved on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
            $content += "# Total positions: $($savedPositions.Count)`n`n"
            $content += "Time`t`tX`tY`n"
            $content += "=" * 40 + "`n"
            
            foreach ($item in $savedPositions) {
                $content += "$($item.Time)`t$($item.X)`t$($item.Y)`n"
            }
            
            $content | Out-File -FilePath $outputFile -Encoding UTF8
            Write-Host "`n💾 Saved $($savedPositions.Count) positions to: $outputFile" -ForegroundColor Cyan
            Start-Sleep -Milliseconds 500  # Debounce
        } else {
            Write-Host "`n⚠️ No positions to save!" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 500
        }
    }
    
    # Display coordinates and count
    Write-Host "`r📍 X: $($pos.X.ToString().PadLeft(4)) | Y: $($pos.Y.ToString().PadLeft(4)) | Saved: $($savedPositions.Count)" -NoNewline -ForegroundColor White
    
    # Update every 100ms
    Start-Sleep -Milliseconds 100
}

# ========================================
# 🖱️ MOUSE COORDINATES FOR AREA
# ========================================
# Description: Captures two diagonal corners and calculates screen region
# Usage: Run in PowerShell
#        1. Move mouse to FIRST corner (e.g., top-left) and press SPACE
#        2. Move mouse to SECOND corner (e.g., bottom-right) and press SPACE
#        3. Script automatically calculates X, Y, Width, Height
# Exit: Press Ctrl+C to stop
# ========================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class KeyboardInfo {
        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(int vKey);
    }
"@

$corners = @()
$outputFile = "screen_region_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Screen Region Calculator" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "1. Move to FIRST corner, press SPACE" -ForegroundColor Green
Write-Host "2. Move to SECOND corner, press SPACE" -ForegroundColor Green
Write-Host "3. Get X, Y, Width, Height values`n" -ForegroundColor Magenta

while ($true) {
    # Get current cursor position
    $pos = [System.Windows.Forms.Cursor]::Position
    
    # Check for SPACE key press (VK_SPACE = 0x20)
    if ([KeyboardInfo]::GetAsyncKeyState(0x20) -band 0x8000) {
        if ($corners.Count -lt 2) {
            $corners += [PSCustomObject]@{
                X = $pos.X
                Y = $pos.Y
            }
            
            if ($corners.Count -eq 1) {
                Write-Host "`n✅ First corner saved: X=$($pos.X), Y=$($pos.Y)" -ForegroundColor Green
                Write-Host "Now move to the OPPOSITE corner and press SPACE again`n" -ForegroundColor Yellow
            } elseif ($corners.Count -eq 2) {
                Write-Host "`n✅ Second corner saved: X=$($pos.X), Y=$($pos.Y)`n" -ForegroundColor Green
                
                # Calculate region parameters
                $x = [Math]::Min($corners[0].X, $corners[1].X)
                $y = [Math]::Min($corners[0].Y, $corners[1].Y)
                $width = [Math]::Abs($corners[1].X - $corners[0].X)
                $height = [Math]::Abs($corners[1].Y - $corners[0].Y)
                
                Write-Host "══════════════════════════════════════════════════" -ForegroundColor Cyan
                Write-Host "📐 SCREEN REGION PARAMETERS" -ForegroundColor Yellow
                Write-Host "══════════════════════════════════════════════════" -ForegroundColor Cyan
                Write-Host "X:      $x" -ForegroundColor White
                Write-Host "Y:      $y" -ForegroundColor White
                Write-Host "Width:  $width" -ForegroundColor White
                Write-Host "Height: $height" -ForegroundColor White
                Write-Host "══════════════════════════════════════════════════`n" -ForegroundColor Cyan
                
                # Robot Framework format
                Write-Host "📋 ROBOT FRAMEWORK SYNTAX:" -ForegroundColor Magenta
                Write-Host "Update Capture Screen Region    $x    $y    $width    $height    `${IMAGE_DIR}${/}screenShot.png`n" -ForegroundColor Green
                
                # Save to file
                $content = "# Screen Region - Calculated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
                $content += "`nCorner 1: X=$($corners[0].X), Y=$($corners[0].Y)`n"
                $content += "Corner 2: X=$($corners[1].X), Y=$($corners[1].Y)`n`n"
                $content += "=" * 50 + "`n"
                $content += "CALCULATED VALUES:`n"
                $content += "=" * 50 + "`n"
                $content += "X:      $x`n"
                $content += "Y:      $y`n"
                $content += "Width:  $width`n"
                $content += "Height: $height`n`n"
                $content += "ROBOT FRAMEWORK SYNTAX:`n"
                $content += "Update Capture Screen Region    $x    $y    $width    $height    `${IMAGE_DIR}${/}screenShot.png`n"
                
                $content | Out-File -FilePath $outputFile -Encoding UTF8
                Write-Host "💾 Saved to: $outputFile`n" -ForegroundColor Cyan
                
                # Reset for next calculation
                Write-Host "Press SPACE to start new calculation or Ctrl+C to exit`n" -ForegroundColor Yellow
                $corners = @()
            }
            
            Start-Sleep -Milliseconds 300  # Debounce
        }
    }
    
    # Display current coordinates and status
    $status = if ($corners.Count -eq 0) { "Waiting for 1st corner" } 
              elseif ($corners.Count -eq 1) { "Waiting for 2nd corner" }
              else { "Ready for new calculation" }
    
    Write-Host "`r📍 X: $($pos.X.ToString().PadLeft(4)) | Y: $($pos.Y.ToString().PadLeft(4)) | Status: $status" -NoNewline -ForegroundColor White
    
    # Update every 100ms
    Start-Sleep -Milliseconds 100
}
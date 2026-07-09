# ═══════════════════════════════════════════════════
# QiblaHub — Generator logo aplikasi (ikon launcher)
# Menggambar kompas kiblat emas di atas gradasi emerald
# Output: icon.png (legacy), icon_fg.png (adaptive FG),
#         icon_bg.png (adaptive BG) — semua 1024×1024
# ═══════════════════════════════════════════════════
Add-Type -AssemblyName System.Drawing

$dir = "f:\Joki\Aplikasi_AIK\qiblahub\assets\icon"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$emeraldDark   = [System.Drawing.ColorTranslator]::FromHtml('#0B7A44')
$emeraldBright = [System.Drawing.ColorTranslator]::FromHtml('#16A862')
$gold          = [System.Drawing.ColorTranslator]::FromHtml('#D4AF37')
$white         = [System.Drawing.Color]::White

function New-Canvas {
    $bmp = New-Object System.Drawing.Bitmap(1024, 1024)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.PixelOffsetMode = 'HighQuality'
    return $bmp, $g
}

# Gambar elemen kompas dengan koordinat relatif pusat (0,0), skala penuh
function Draw-Compass([System.Drawing.Graphics]$g) {
    # Cincin kompas emas
    $ringPen = New-Object System.Drawing.Pen($gold, 30)
    $g.DrawEllipse($ringPen, -320, -320, 640, 640)
    $ringPen.Dispose()

    # Titik arah mata angin (N E S W) — putih lembut
    $tickBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(210, 255, 255, 255))
    foreach ($ang in 0, 90, 180, 270) {
        $rad = $ang * [Math]::PI / 180
        $tx = [Math]::Sin($rad) * 258
        $ty = -[Math]::Cos($rad) * 258
        $g.FillEllipse($tickBrush, $tx - 16, $ty - 16, 32, 32)
    }
    $tickBrush.Dispose()

    # Jarum kompas (diamond) menunjuk arah kiblat (miring 45°)
    $state = $g.Save()
    $g.RotateTransform(45)
    $goldBrush = New-Object System.Drawing.SolidBrush($gold)
    $northPts = @(
        (New-Object System.Drawing.PointF(0, -252)),
        (New-Object System.Drawing.PointF(88, 0)),
        (New-Object System.Drawing.PointF(-88, 0))
    )
    $g.FillPolygon($goldBrush, $northPts)
    $goldBrush.Dispose()
    $whiteBrush = New-Object System.Drawing.SolidBrush($white)
    $southPts = @(
        (New-Object System.Drawing.PointF(0, 252)),
        (New-Object System.Drawing.PointF(88, 0)),
        (New-Object System.Drawing.PointF(-88, 0))
    )
    $g.FillPolygon($whiteBrush, $southPts)
    $whiteBrush.Dispose()
    $g.Restore($state)

    # Poros tengah
    $hubBrush = New-Object System.Drawing.SolidBrush($white)
    $g.FillEllipse($hubBrush, -46, -46, 92, 92)
    $hubBrush.Dispose()
    $hubPen = New-Object System.Drawing.Pen($gold, 14)
    $g.DrawEllipse($hubPen, -46, -46, 92, 92)
    $hubPen.Dispose()
}

function New-GradientBrush {
    New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point(1024, 1024)),
        $emeraldDark, $emeraldBright)
}

# ── 1. Ikon legacy: rounded-rect gradasi + kompas ──
$bmp, $g = New-Canvas
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = 230; $d = $r * 2
$path.AddArc(0, 0, $d, $d, 180, 90)
$path.AddArc(1024 - $d, 0, $d, $d, 270, 90)
$path.AddArc(1024 - $d, 1024 - $d, $d, $d, 0, 90)
$path.AddArc(0, 1024 - $d, $d, $d, 90, 90)
$path.CloseFigure()
$grad = New-GradientBrush
$g.FillPath($grad, $path)
$grad.Dispose()
# Kilau lembut kiri-atas
$g.SetClip($path)
$hl = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(22, 255, 255, 255))
$g.FillEllipse($hl, -260, -320, 1000, 820)
$hl.Dispose()
$g.ResetClip()
# Kompas di tengah
$g.TranslateTransform(512, 512)
Draw-Compass $g
$g.ResetTransform()
$bmp.Save("$dir\icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $path.Dispose()

# ── 2. Adaptive foreground: kompas di kanvas transparan (66% safe zone) ──
$bmp, $g = New-Canvas
$g.TranslateTransform(512, 512)
$g.ScaleTransform(0.60, 0.60)
Draw-Compass $g
$g.ResetTransform()
$bmp.Save("$dir\icon_fg.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# ── 3. Adaptive background: gradasi penuh ──
$bmp, $g = New-Canvas
$grad = New-GradientBrush
$g.FillRectangle($grad, 0, 0, 1024, 1024)
$grad.Dispose()
$bmp.Save("$dir\icon_bg.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

Write-Host "Logo dibuat di $dir"
Get-ChildItem $dir | Select-Object Name, Length

# Perbaikan: suntik ulang 9 gambar yang hilang (korban Document Recovery)
# ke Laporan_Kelompok2_QiblaHub_REVISI.docx tanpa menyentuh teks/suntingan.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$docx = Join-Path $dir 'Laporan_Kelompok2_QiblaHub_REVISI.docx'
$cadangan = Join-Path $dir 'Laporan_Kelompok2_QiblaHub_REVISI.backup-tanpa-gambar.docx'
Copy-Item $docx $cadangan -Force
Write-Host "Cadangan: $cadangan"

# Gambar sesuai urutan kemunculan di dokumen + lebar tampil (px, dari HTML)
$gambar = @(
    @{ file = 'gambar\logo_unismuh.png';    lebar = 170 },  # drawing 1 (sampul)
    @{ file = 'gambar\01_splash.png';       lebar = 300 },
    @{ file = 'gambar\02_beranda.png';      lebar = 250 },
    @{ file = 'gambar\03_jadwal_salat.png'; lebar = 280 },
    @{ file = 'gambar\04_arah_kiblat.png';  lebar = 280 },
    @{ file = 'gambar\05_daftar_masjid.png';lebar = 240 },
    @{ file = 'gambar\06_detail_masjid.png';lebar = 300 },
    @{ file = 'gambar\07_kalender.png';     lebar = 200 },
    @{ file = 'gambar\08_pengaturan.png';   lebar = 280 }
)

# Hitung ukuran EMU (1 px @96dpi = 9525 EMU) dengan rasio asli tiap PNG
foreach ($g in $gambar) {
    $path = Join-Path $dir $g.file
    $img = [System.Drawing.Image]::FromFile($path)
    $w = $img.Width; $h = $img.Height
    $img.Dispose()
    $g.cx = [long]($g.lebar * 9525)
    $g.cy = [long][Math]::Round($g.cx * $h / $w)
    Write-Host ("{0}: {1}x{2}px -> cx={3} cy={4}" -f $g.file, $w, $h, $g.cx, $g.cy)
}

function Edit-ZipEntry([IO.Compression.ZipArchive]$zip, [string]$name, [scriptblock]$transform) {
    $entry = $zip.GetEntry($name)
    $reader = New-Object IO.StreamReader($entry.Open(), [Text.Encoding]::UTF8)
    $xml = $reader.ReadToEnd()
    $reader.Close()
    $xml = & $transform $xml
    $entry.Delete()
    $entry = $zip.CreateEntry($name)
    $writer = New-Object IO.StreamWriter($entry.Open(), (New-Object Text.UTF8Encoding($false)))
    $writer.Write($xml)
    $writer.Close()
}

$zip = [IO.Compression.ZipFile]::Open($docx, 'Update')
try {
    # 1) Tanam file media image1..9.png
    for ($i = 0; $i -lt 9; $i++) {
        $nama = "word/media/image$($i + 1).png"
        $lama = $zip.GetEntry($nama)
        if ($lama) { $lama.Delete() }
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, (Join-Path $dir $gambar[$i].file), $nama) | Out-Null
    }
    Write-Host '[1/3] 9 file media ditanam'

    # 2) Tambah relationship rId101..rId108 utk image2..9 (rId5 = image1 sudah ada)
    Edit-ZipEntry $zip 'word/_rels/document.xml.rels' {
        param($x)
        $tambah = ''
        for ($i = 2; $i -le 9; $i++) {
            $rid = "rId$(99 + $i)"   # rId101..rId108
            if ($x -notmatch $rid) {
                $tambah += "<Relationship Id=`"$rid`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image`" Target=`"media/image$i.png`"/>"
            }
        }
        return $x.Replace('</Relationships>', "$tambah</Relationships>")
    }
    Write-Host '[2/3] relationships ditambah'

    # 3) document.xml: benahi ukuran logo + ganti 8 kotak Rectangle -> gambar
    Edit-ZipEntry $zip 'word/document.xml' {
        param($x)
        # 3a. Drawing 1 (logo, rId5): perbaiki extent yang rusak rasio
        $x = $x.Replace('cx="1773141" cy="2052245"',
            ('cx="{0}" cy="{1}"' -f $gambar[0].cx, $gambar[0].cy))

        # 3b. Ganti tiap kotak wordprocessingShape dgn pic sesungguhnya, berurutan
        $script:urut = 0
        $polaKotak = '(?s)<w:drawing><wp:inline [^>]*><wp:extent cx="1812897" cy="2989690"/>.*?</w:drawing>'
        $eval = {
            param($m)
            $script:urut++
            $g = $gambar[$script:urut]   # urut 1..8 -> image2..9
            $rid = "rId$(100 + $script:urut)"
            $id = 9000 + $script:urut
            $nm = [IO.Path]::GetFileName($g.file)
            return ('<w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">' +
                ('<wp:extent cx="{0}" cy="{1}"/>' -f $g.cx, $g.cy) +
                '<wp:effectExtent l="0" t="0" r="0" b="0"/>' +
                ('<wp:docPr id="{0}" name="{1}"/>' -f $id, $nm) +
                '<wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/></wp:cNvGraphicFramePr>' +
                '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">' +
                '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">' +
                ('<pic:nvPicPr><pic:cNvPr id="{0}" name="{1}"/><pic:cNvPicPr/></pic:nvPicPr>' -f $id, $nm) +
                ('<pic:blipFill><a:blip r:embed="{0}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>' -f $rid) +
                '<pic:spPr><a:xfrm><a:off x="0" y="0"/>' +
                ('<a:ext cx="{0}" cy="{1}"/>' -f $g.cx, $g.cy) +
                '</a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr>' +
                '</pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing>')
        }
        $x = [regex]::Replace($x, $polaKotak, $eval)
        Write-Host "  Kotak diganti gambar: $script:urut"
        return $x
    }
    Write-Host '[3/3] document.xml dibenahi'
}
finally {
    $zip.Dispose()
}
Write-Host 'SELESAI'

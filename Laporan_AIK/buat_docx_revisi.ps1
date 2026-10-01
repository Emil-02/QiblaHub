# ═══════════════════════════════════════════════════
# Konversi Laporan Kelompok 2 (REVISI): HTML → DOCX
# Resep sama dengan buat_docx.ps1 (teruji):
#   Fase 1 (Word COM) : HTML → docx polos + tanam gambar
#   Fase 2 (Open XML) : styles.xml & document.xml → format akademik
# Jalankan:
#   powershell -ExecutionPolicy Bypass -File Laporan_AIK\buat_docx_revisi.ps1
# ═══════════════════════════════════════════════════

param([switch]$LewatiKonversi)

$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $dir 'Laporan_Kelompok2_QiblaHub_REVISI.html'
$dst = Join-Path $dir 'Laporan_Kelompok2_QiblaHub_REVISI.docx'
# Nama tmp unik per run — nama tetap yang pernah force-kill membuat Word
# menahan prompt recovery tersembunyi utk path yang sama (hang di Open/SaveAs2)
$tmp = Join-Path $dir ('tmp_konversi_' + (Get-Date -Format 'HHmmss') + '.html')

if (-not $LewatiKonversi) {
Copy-Item $src $tmp -Force
$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $doc = $word.Documents.Open($tmp)
    Write-Host '[1/4] HTML terbuka di Word'
    foreach ($shape in @($doc.InlineShapes)) {
        if ($shape.LinkFormat) {
            $shape.LinkFormat.SavePictureWithDocument = $true
            $shape.LinkFormat.BreakLink()
        }
    }
    $doc.SaveAs2($dst, 16)   # 16 = wdFormatXMLDocument (.docx)
    $doc.Close($false)
    Write-Host '[2/4] docx polos tersimpan (gambar tertanam)'
}
finally {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}
} else { Write-Host '[1-2/4] Konversi dilewati; memformat docx yang ada' }

# ══ FASE 2: format akademik via Open XML ══
Add-Type -AssemblyName System.IO.Compression.FileSystem

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

$zip = [IO.Compression.ZipFile]::Open($dst, 'Update')
try {
    Edit-ZipEntry $zip 'word/styles.xml' {
        param($x)
        $x = $x.Replace(
            '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:rPr>',
            '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:rPr>')
        $x = $x.Replace(
            '<w:pPr><w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:kern w:val="36"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>',
            '<w:pPr><w:spacing w:before="0" w:after="240" w:line="360" w:lineRule="auto"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:kern w:val="36"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>')
        $x = $x.Replace(
            '<w:pPr><w:spacing w:before="360" w:after="100" w:afterAutospacing="1"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr>',
            '<w:pPr><w:keepNext/><w:spacing w:before="360" w:after="120" w:line="360" w:lineRule="auto"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>')
        $x = $x.Replace(
            '<w:pPr><w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr>',
            '<w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>')
        return $x
    }
    Write-Host '[3/4] styles.xml: TNR 12, spasi 1,5, heading dirapikan'

    Edit-ZipEntry $zip 'word/document.xml' {
        param($x)
        $x = $x.Replace(
            '<w:pgSz w:w="12240" w:h="15840"/>',
            '<w:pgSz w:w="11906" w:h="16838"/>')
        $x = $x.Replace(
            '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>',
            '<w:pgMar w:top="2268" w:right="1701" w:bottom="1701" w:left="2268" w:header="709" w:footer="709" w:gutter="0"/>')
        # Samakan header/footer dgn laporan asli bila sudah termargin 4-4-3-3
        $x = $x.Replace(
            'w:left="2268" w:header="720" w:footer="720"',
            'w:left="2268" w:header="709" w:footer="709"')
        # Sub-bab (Heading3) rata kiri murni: buang jc=both bawaan HTML
        $x = [regex]::Replace($x,
            '(<w:pStyle w:val="Heading3"/>)((?:(?!</w:pPr>).)*?)<w:jc w:val="both"/>',
            '$1$2')
        # Indentasi baris pertama paragraf badan 0,75 cm (firstLine=426),
        # meniru susunan laporan asli. Paragraf badan = pStyle NormalWeb yang
        # langsung diikuti jc=both (list punya numPr di antaranya → tak kena).
        # Hanya di LUAR tabel.
        $parts = [regex]::Split($x, '(?s)(<w:tbl>.*?</w:tbl>)')
        for ($i = 0; $i -lt $parts.Count; $i++) {
            if ($parts[$i] -notmatch '^<w:tbl>') {
                $parts[$i] = $parts[$i].Replace(
                    '<w:pPr><w:pStyle w:val="NormalWeb"/><w:jc w:val="both"/>',
                    '<w:pPr><w:pStyle w:val="NormalWeb"/><w:ind w:firstLine="426"/><w:jc w:val="both"/>')
            }
        }
        $x = -join $parts
        return $x
    }
    Write-Host '[4/4] A4; margin 4-4-3-3 cm; indentasi paragraf ala laporan asli'

    # ── webSettings.xml: NOLKAN margin div body bawaan impor HTML ──
    # Word menyalin margin CSS body ke <w:div> (bodyDiv) DAN margin ini
    # dijumlahkan dengan pgMar → margin dobel (teks menyempit). Margin
    # halaman cukup dari pgMar saja.
    Edit-ZipEntry $zip 'word/webSettings.xml' {
        param($x)
        $x = [regex]::Replace($x,
            '(<w:bodyDiv w:val="1"/>)<w:marLeft w:val="\d+"/><w:marRight w:val="\d+"/><w:marTop w:val="\d+"/><w:marBottom w:val="\d+"/>',
            '$1<w:marLeft w:val="0"/><w:marRight w:val="0"/><w:marTop w:val="0"/><w:marBottom w:val="0"/>')
        return $x
    }
    Write-Host '[5/5] webSettings.xml: margin div body dinolkan (anti margin dobel)'
}
finally {
    $zip.Dispose()
}

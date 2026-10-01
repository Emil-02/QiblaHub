# ═══════════════════════════════════════════════════
# Konversi Laporan PKM AIK: HTML → DOCX (format akademik)
# • Times New Roman 12pt, spasi 1,5
# • Margin: atas 4 cm, kiri 4 cm, bawah 3 cm, kanan 3 cm
# • Sub-bab memakai style Heading asli Word (Navigation Pane)
#
# Strategi:
#   Fase 1 (Word COM) : HTML → docx polos + tanam gambar (resep teruji)
#   Fase 2 (Open XML) : edit styles.xml & document.xml langsung —
#                       deterministik, tanpa layout engine Word
#
# Jalankan:
#   powershell -ExecutionPolicy Bypass -File Laporan_AIK\buat_docx.ps1
# Bila docx polos sudah ada (lewati Word COM — wajib bila Word sedang dibuka):
#   powershell -ExecutionPolicy Bypass -File Laporan_AIK\buat_docx.ps1 -LewatiKonversi
# ═══════════════════════════════════════════════════

param([switch]$LewatiKonversi)

$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $dir 'Laporan_PKM_AIK_QiblaHub.html'
$dst = Join-Path $dir 'Laporan_PKM_AIK_QiblaHub.docx'
$tmp = Join-Path $dir 'tmp_konversi_word.html'

# ══ FASE 1: HTML → docx polos (persis resep yang terbukti cepat) ══
# Catatan: fase ini bentrok bila ada Word lain terbuka — pastikan Word
# tertutup, atau pakai -LewatiKonversi bila docx polos sudah tersedia.
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
    # ── styles.xml: spasi 1,5 + justify di Normal; heading TNR hitam ──
    Edit-ZipEntry $zip 'word/styles.xml' {
        param($x)

        # Normal: TNR 12 (sudah), + spasi 1,5 (line 360 twip, auto) + justify
        $x = $x.Replace(
            '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:rPr>',
            '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:rPr>')

        # Heading 1 (judul sampul): 14pt, kapital, tengah, spasi 1,5
        $x = $x.Replace(
            '<w:pPr><w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:kern w:val="36"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>',
            '<w:pPr><w:spacing w:before="0" w:after="240" w:line="360" w:lineRule="auto"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:kern w:val="36"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>')

        # Heading 2 (bab A–J): 12pt tebal, kiri, spasi 1,5, jaga-dengan-berikutnya
        $x = $x.Replace(
            '<w:pPr><w:spacing w:before="360" w:after="100" w:afterAutospacing="1"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr>',
            '<w:pPr><w:keepNext/><w:spacing w:before="360" w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>')

        # Heading 3 (sub-bab): 12pt tebal, kiri, spasi 1,5
        $x = $x.Replace(
            '<w:pPr><w:spacing w:before="100" w:beforeAutospacing="1" w:after="100" w:afterAutospacing="1"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr>',
            '<w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>')

        return $x
    }
    Write-Host '[3/4] styles.xml: TNR 12, spasi 1,5, heading dirapikan'

    # ── document.xml: halaman A4 + margin (twip; 1 cm = 567) ──
    Edit-ZipEntry $zip 'word/document.xml' {
        param($x)
        # Ukuran halaman: Letter → A4 (21 × 29,7 cm)
        $x = $x.Replace(
            '<w:pgSz w:w="12240" w:h="15840"/>',
            '<w:pgSz w:w="11906" w:h="16838"/>')
        $x = $x.Replace(
            '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>',
            '<w:pgMar w:top="2268" w:right="1701" w:bottom="1701" w:left="2268" w:header="720" w:footer="720" w:gutter="0"/>')
        # Heading rata kiri murni: buang jc=both bawaan HTML pada Heading 2/3
        $x = [regex]::Replace($x,
            '(<w:pStyle w:val="Heading[23]"/>)((?:(?!</w:pPr>).)*?)<w:jc w:val="both"/>',
            '$1$2')
        return $x
    }
    Write-Host '[4/4] A4; margin atas 4, kiri 4, bawah 3, kanan 3 cm; heading rata kiri'
}
finally {
    $zip.Dispose()
}

Write-Host "Berhasil: $dst"

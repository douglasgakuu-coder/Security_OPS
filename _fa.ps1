$ErrorActionPreference = 'Stop'
$CDN = '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />'

# entity -> font-awesome solid class
$map = @{
  '9889'   = 'bolt'
  '128200' = 'chart-line'
  '128100' = 'user'
  '128274' = 'lock'
  '9881'   = 'gears'
  '128268' = 'plug'
  '128737' = 'shield-halved'
  '128220' = 'clock-rotate-left'
  '128190' = 'database'
  '128231' = 'envelope'
  '128462' = 'location-crosshairs'
  '128506' = 'map-location-dot'
  '9873'   = 'flag'
  '128197' = 'calendar-days'
  '9200'   = 'clock'
  '9878'   = 'scale-balanced'
  '128260' = 'arrows-rotate'
  '128680' = 'bullhorn'
  '129492' = 'user-tie'
  '128101' = 'users'
  '128221' = 'file-pen'
  '127881' = 'rocket'
  '127774' = 'sun'
  '127891' = 'graduation-cap'
  '128196' = 'file-lines'
  '128153' = 'hand-holding-heart'
  '127942' = 'trophy'
  '127961' = 'landmark'
  '128176' = 'coins'
  '129534' = 'file-invoice-dollar'
  '128181' = 'money-bill-transfer'
  '128182' = 'receipt'
  '129517' = 'calculator'
  '127963' = 'building-columns'
  '127909' = 'video'
  '128658' = 'life-ring'
  '128666' = 'truck-fast'
  '128172' = 'comments'
  '128273' = 'key'
  '128218' = 'book'
  '128293' = 'fire'
  '128193' = 'folder-open'
  '128201' = 'chart-simple'
  '127919' = 'bullseye'
  '128085' = 'shirt'
  '128230' = 'box'
  '128099' = 'shoe-prints'
  '128295' = 'screwdriver-wrench'
  '128717' = 'basket-shopping'
  '128202' = 'chart-column'
  '9989'   = 'square-check'
  '9986'   = 'stamp'
  '127968' = 'house'
  '127970' = 'building'
  '128110' = 'user-shield'
  '128374' = 'bell-concierge'
  '128249' = 'tv'
  '127914' = 'tickets'
  '128665' = 'car-side'
  '129504' = 'lightbulb'
  '128276' = 'bell'
  '9099'   = 'right-from-bracket'
  '127760' = 'globe'
  '128205' = 'location-dot'
  '128222' = 'phone'
  '9993'   = 'envelope'
  '127915' = 'circle-play'
}

$files = Get-ChildItem -Recurse -Filter *.html
$changed = 0
foreach ($f in $files) {
  $raw = Get-Content $f.FullName -Raw
  $orig = $raw

  # 1) inject Font Awesome CDN after the vigilora.css link (only once)
  if ($raw -notmatch 'font-awesome') {
    $raw = [regex]::Replace($raw, '(<link rel="stylesheet" href="[^"]*vigilora\.css" />)', "`$1`n$CDN", 1)
  }

  # 2) replace each known icon entity with an FA icon
  foreach ($k in $map.Keys) {
    $ent = "&#$k;"
    if ($raw.Contains($ent)) {
      $raw = $raw.Replace($ent, "<i class=""fa-solid $($map[$k])""></i>")
    }
  }

  if ($raw -ne $orig) { Set-Content -Path $f.FullName -Value $raw -NoNewline; $changed++ }
}
Write-Output "changed $changed files"

# report leftover numeric icon entities (excluding the harmless bullet)
$left = @()
foreach ($f in (Get-ChildItem -Recurse -Filter *.html)) {
  $html = Get-Content $f.FullName -Raw
  foreach ($m in [regex]::Matches($html, '&#(\d{4,6});')) {
    $code = [int]$m.Groups[1].Value
    if ($code -ne 9679) { $left += "$($f.Name): &$($m.Groups[1].Value);" }
  }
}
$left | Sort-Object -Unique | Select-Object -First 30
Write-Output "LEFTOVER ENTITY KINDS: $(($left | ForEach-Object { ($_ -split ': ')[1] } | Sort-Object -Unique).Count)"

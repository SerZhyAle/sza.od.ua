<#
ui-check.ps1 - rendered checks of the hub page and of the kit showcase against the unified UI contracts.

What it runs (BUTTONS 2.0, UI-SIZING 1.1, COLLAPSIBLE-GROUP 1.1, BOOLEAN-OPTION 2.0, ICON-RENDER 0.24, PAGE-STYLE, PAGE-CONTENT layout):
  - geometry  : target size against the stable profile, clipping, overflow, overlap, stretching, row heights,
                gaps, corner radius, glyph size, accessible names
  - contrast  : text and glyph against the actual face in normal, hover and pressed states (CDP forced pseudo states)
  - behaviour : keyboard order and focus ring, toggle-once, scroll-versus-tap, help-versus-toggle, dialog focus
                and Escape, menu focus return, repeated activation, state-word width reservation
  - captures  : one PNG per scenario

It drives a headless Chrome over the DevTools protocol from PowerShell 7 alone (no node, no python, no package).
External requests (web fonts, the AdSense loader) are blocked so a run is deterministic and offline: the captures
therefore show the system-font fallback, not Outfit / Plus Jakarta Sans. That is stated in every report.

Usage:  pwsh -NoProfile -File tools/ui-check.ps1 [-Target all|hub|showcase] [-Out <dir>] [-Showcase <file>] [-HubPage <file>] [-NoCapture]
Exit:   0 every check passed, 1 at least one check failed, 2 the browser could not be driven.
The showcase is the catalog's reference/showcase.html; keep a copy at docs/ui/showcase.html or pass -Showcase.
#>
[CmdletBinding()]
param(
  [ValidateSet('all', 'hub', 'showcase')][string]$Target = 'all',
  [string]$Out,
  [string]$Showcase,
  [string]$Chrome,
  [string]$HubPage,
  [switch]$NoCapture
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (-not $Out) { $Out = Join-Path $root ('docs/ui-evidence/' + (Get-Date -Format 'yyyy-MM-dd')) }
if (-not $Showcase) { $Showcase = Join-Path $root 'docs/ui/showcase.html' }
if (-not $Chrome) {
  $Chrome = @('C:\Program Files\Google\Chrome\Application\chrome.exe', 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe') | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $Chrome) { Write-Error 'No Chrome or Edge found; pass -Chrome.'; exit 2 }
New-Item -ItemType Directory -Force $Out | Out-Null

# ---------------------------------------------------------------- CDP plumbing
$script:ws = $null; $script:cid = 0
function Receive-Msg([int]$ms = 30000) {
  $ms2 = New-Object IO.MemoryStream; $buf = New-Object byte[] 65536
  $cts = New-Object Threading.CancellationTokenSource($ms)
  do { $seg = [ArraySegment[byte]]::new($buf); $r = $script:ws.ReceiveAsync($seg, $cts.Token).GetAwaiter().GetResult(); $ms2.Write($buf, 0, $r.Count) } until ($r.EndOfMessage)
  return [Text.Encoding]::UTF8.GetString($ms2.ToArray()) | ConvertFrom-Json -Depth 60
}
function Cdp([string]$method, [hashtable]$params = @{}, [int]$timeout = 30000) {
  $script:cid++; $my = $script:cid
  $json = @{ id = $my; method = $method; params = $params } | ConvertTo-Json -Depth 30 -Compress
  $bytes = [Text.Encoding]::UTF8.GetBytes($json)
  $script:ws.SendAsync([ArraySegment[byte]]::new($bytes), 'Text', $true, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
  while ($true) {
    $m = Receive-Msg $timeout
    if ($m.id -eq $my) { if ($m.error) { throw "CDP $method : $($m.error.message)" }; return $m.result }
  }
}
function Ev([string]$js) {
  $r = Cdp 'Runtime.evaluate' @{ expression = $js; returnByValue = $true; awaitPromise = $true }
  if ($r.exceptionDetails) { throw ("JS: " + $r.exceptionDetails.exception.description) }
  return $r.result.value
}
function Pause([int]$ms = 150) { Start-Sleep -Milliseconds $ms }
function Rect([string]$sel) {
  $js = "(function(){var e=document.querySelector('$sel');if(!e)return null;e.scrollIntoView({block:'center',behavior:'instant'});var r=e.getBoundingClientRect();return JSON.stringify({x:r.left+r.width/2,y:r.top+r.height/2,w:r.width,h:r.height,l:r.left,t:r.top})})()"
  $v = Ev $js; if (-not $v) { throw "no element $sel" }; return $v | ConvertFrom-Json
}
function Mouse([string]$type, [double]$x, [double]$y, [string]$btn = 'none') {
  Cdp 'Input.dispatchMouseEvent' @{ type = $type; x = $x; y = $y; button = $btn; buttons = $(if ($type -eq 'mousePressed') { 1 } else { 0 }); clickCount = $(if ($type -eq 'mouseMoved') { 0 } else { 1 }) } | Out-Null
}
function ClickAt([double]$x, [double]$y) { Mouse 'mouseMoved' $x $y; Mouse 'mousePressed' $x $y 'left'; Mouse 'mouseReleased' $x $y 'left'; Pause }
function Click([string]$sel, [double]$dx = 0, [double]$dy = 0) { $r = Rect $sel; ClickAt ($r.x + $dx) ($r.y + $dy) }
function Hover([string]$sel) { $r = Rect $sel; Mouse 'mouseMoved' $r.x $r.y; Pause 250 }
function Tap([double]$x, [double]$y) {
  Cdp 'Input.dispatchTouchEvent' @{ type = 'touchStart'; touchPoints = @(@{ x = $x; y = $y }) } | Out-Null
  Cdp 'Input.dispatchTouchEvent' @{ type = 'touchEnd'; touchPoints = @() } | Out-Null; Pause 250
}
function Key([string]$key, [string]$code, [int]$vk, [string]$text = '') {
  $d = @{ type = 'keyDown'; key = $key; code = $code; windowsVirtualKeyCode = $vk }
  if ($text) { $d.text = $text }
  Cdp 'Input.dispatchKeyEvent' $d | Out-Null
  Cdp 'Input.dispatchKeyEvent' @{ type = 'keyUp'; key = $key; code = $code; windowsVirtualKeyCode = $vk } | Out-Null; Pause 120
}
function KTab { Key 'Tab' 'Tab' 9 }
function KEnter { Key 'Enter' 'Enter' 13 "`r" }
function KSpace { Key ' ' 'Space' 32 ' ' }
function KEsc { Key 'Escape' 'Escape' 27 }

# ---------------------------------------------------------------- results
$script:Res = New-Object System.Collections.Generic.List[object]
$script:Caps = New-Object System.Collections.Generic.List[string]
function Check([string]$id, [string]$scn, [bool]$ok, [string]$detail = '') {
  $script:Res.Add([pscustomobject]@{ Id = $id; Scenario = $scn; Status = $(if ($ok) { 'PASS' } else { 'FAIL' }); Detail = $detail })
  if (-not $ok) { Write-Host "FAIL $id [$scn] $detail" -ForegroundColor Red }
}
function Info([string]$id, [string]$scn, [string]$detail) { $script:Res.Add([pscustomobject]@{ Id = $id; Scenario = $scn; Status = 'INFO'; Detail = $detail }) }

# ---------------------------------------------------------------- page scenarios
function Open-Page([string]$url, [int]$w, [int]$h, [bool]$touch, [string]$scheme = 'dark', [string]$forced = 'none') {
  Cdp 'Emulation.setDeviceMetricsOverride' @{ width = $w; height = $h; deviceScaleFactor = 1; mobile = $touch } | Out-Null
  Cdp 'Emulation.setTouchEmulationEnabled' @{ enabled = $touch; maxTouchPoints = 5 } | Out-Null
  Cdp 'Emulation.setEmulatedMedia' @{ features = @(@{ name = 'prefers-color-scheme'; value = $scheme }, @{ name = 'forced-colors'; value = $forced }) } | Out-Null
  Cdp 'Page.navigate' @{ url = $url } | Out-Null
  for ($i = 0; $i -lt 100; $i++) { Pause 100; try { if ((Ev 'document.readyState') -eq 'complete') { break } } catch { } }
  Ev "document.documentElement.style.scrollBehavior='auto';var s=document.createElement('style');s.textContent='*,*::before,*::after{transition:none!important;animation:none!important}';document.head.appendChild(s);document.fonts&&document.fonts.ready.then(function(){});true" | Out-Null
  Ev "window.__W=$w;true" | Out-Null
  Pause 200
}
function Capture([string]$name) {
  if ($NoCapture) { return }
  $h = [int](Ev 'Math.min(document.documentElement.scrollHeight,6000)'); $w = [int](Ev 'document.documentElement.clientWidth')
  $r = Cdp 'Page.captureScreenshot' @{ format = 'png'; captureBeyondViewport = $true; clip = @{ x = 0; y = 0; width = $w; height = $h; scale = 1 } } 60000
  $f = Join-Path $Out ($name + '.png'); [IO.File]::WriteAllBytes($f, [Convert]::FromBase64String($r.data)); $script:Caps.Add($name + '.png')
}

# ---------------------------------------------------------------- geometry
$jsGeometry = @'
(function(){
  document.querySelectorAll('.to-top').forEach(function(e){e.classList.add('show')});
  function px(v){var p=document.createElement('div');p.style.cssText='position:absolute;visibility:hidden;width:'+v+';height:'+v;document.body.appendChild(p);var w=p.getBoundingClientRect().width;p.remove();return w}
  var T=px('var(--ui-target)'),G=px('var(--ui-gap)'),GL=px('var(--ui-glyph)'),R=px('var(--ui-radius)');
  var viol=[],n=0;
  function vis(e){var r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.visibility!=='hidden'&&cs.display!=='none'}
  function nm(e){return (e.id?'#'+e.id:'')+'.'+(e.className&&e.className.baseVal===undefined?String(e.className).trim().replace(/\s+/g,'.'):'')+'['+(e.getAttribute('aria-label')||e.textContent||'').trim().slice(0,24)+']'}
  var els=[].slice.call(document.querySelectorAll('.btn,.theme-btn,.seg button,.copybox .copy,.to-top,.opt-help,.opt-boxwrap,details.sec>summary,.tools-grid a')).filter(vis);
  els.forEach(function(e){
    n++;var r=e.getBoundingClientRect(),w=r.width,h=r.height;
    if(w<T-.5||h<T-.5)viol.push('target '+nm(e)+' '+w.toFixed(1)+'x'+h.toFixed(1)+' < '+T);
    var isBtn=e.matches('.btn,.theme-btn,.seg button,.copy,.to-top,.opt-help');
    if(isBtn&&(e.scrollWidth>e.clientWidth+1||e.scrollHeight>e.clientHeight+1))viol.push('clip '+nm(e));
    if(r.right>(window.__W||innerWidth)+.5||r.left<-.5)viol.push('viewport '+nm(e)+' '+r.left.toFixed(0)+'..'+r.right.toFixed(0));
    if(e.matches('.btn,.theme-btn,.copybox .copy')){
      var pf=e.style.flex,pw=e.style.width;e.style.flex='none';e.style.width='max-content';var nat=e.getBoundingClientRect().width;e.style.flex=pf;e.style.width=pw;
      var par=e.parentElement,cs=getComputedStyle(par),inner=par.clientWidth-parseFloat(cs.paddingLeft)-parseFloat(cs.paddingRight);
      if(w>nat+1)viol.push('stretched '+nm(e)+' '+w.toFixed(1)+' > content '+nat.toFixed(1));
      if(w<nat-1&&nat<=inner+1)viol.push('caption wrapped before the button wrapped '+nm(e));
      var br=parseFloat(getComputedStyle(e).borderTopLeftRadius);if(e.matches('.btn,.theme-btn')&&Math.abs(br-R)>.6)viol.push('radius '+nm(e)+' '+br+' != '+R);
    }
    if(!(e.getAttribute('aria-label')||e.textContent.trim()||e.querySelector('input')))viol.push('no accessible name '+nm(e));
    e.querySelectorAll('.gi').forEach(function(g){var gw=g.getBoundingClientRect().width;if(Math.abs(gw-GL)>.6)viol.push('glyph '+nm(e)+' '+gw.toFixed(1)+' != '+GL)});
  });
  for(var i=0;i<els.length;i++)for(var j=i+1;j<els.length;j++){
    var a=els[i],b=els[j];if(a.contains(b)||b.contains(a))continue;if(a.matches('.to-top')||b.matches('.to-top'))continue;
    var oa=a.closest('.opt'),ob=b.closest('.opt');if(oa&&oa===ob)continue;
    var ra=a.getBoundingClientRect(),rb=b.getBoundingClientRect();
    var ox=Math.min(ra.right,rb.right)-Math.max(ra.left,rb.left),oy=Math.min(ra.bottom,rb.bottom)-Math.max(ra.top,rb.top);
    if(ox>1&&oy>1)viol.push('overlap '+nm(a)+' x '+nm(b));
  }
  var rowEls=els.filter(function(e){return e.matches('.btn,.theme-btn')});
  var parents=[];rowEls.forEach(function(e){if(parents.indexOf(e.parentElement)<0)parents.push(e.parentElement)});
  parents.forEach(function(p){
    var kids=rowEls.filter(function(e){return e.parentElement===p}).sort(function(a,b){return a.getBoundingClientRect().top-b.getBoundingClientRect().top||a.getBoundingClientRect().left-b.getBoundingClientRect().left});
    for(var i=0;i<kids.length;i++)for(var j=i+1;j<kids.length;j++){
      var ra=kids[i].getBoundingClientRect(),rb=kids[j].getBoundingClientRect();
      var oy=Math.min(ra.bottom,rb.bottom)-Math.max(ra.top,rb.top);
      if(oy>.5*Math.min(ra.height,rb.height)){
        if(Math.abs(ra.height-rb.height)>1)viol.push('row heights '+nm(kids[i])+' '+ra.height.toFixed(1)+' vs '+nm(kids[j])+' '+rb.height.toFixed(1));
        if(p.matches('.btn-row,.button-group,.proj-foot')){
          var lo=Math.min(ra.right,rb.right),hi=Math.max(ra.left,rb.left);
          var mid=kids.some(function(k,ix){if(ix===i||ix===j)return false;var rk=k.getBoundingClientRect();return Math.min(rk.bottom,ra.bottom)-Math.max(rk.top,ra.top)>0&&rk.left>=lo-1&&rk.right<=hi+1});
          var gap=rb.left>=ra.right-.5?rb.left-ra.right:ra.left-rb.right;
          if(!mid&&Math.abs(gap-G)>1.5&&gap<60)viol.push('gap '+gap.toFixed(1)+' != '+G+' '+nm(kids[i])+' | '+nm(kids[j]));
        }
      }
    }
  });
  if(document.documentElement.scrollWidth>(window.__W||innerWidth)+1)viol.push('page overflows horizontally '+document.documentElement.scrollWidth+' > '+(window.__W||innerWidth));
  return JSON.stringify({n:n,T:T,G:G,GL:GL,R:R,viol:viol});
})()
'@
function Test-Geometry([string]$scn) {
  $g = (Ev $jsGeometry) | ConvertFrom-Json
  Check 'geometry' $scn ($g.viol.Count -eq 0) (($g.viol | Select-Object -First 6) -join ' ; ')
  Info 'geometry-tokens' $scn ("{0} controls; target {1}px, gap {2}px, glyph {3}px, radius {4}px" -f $g.n, $g.T, $g.G, $g.GL, $g.R)
  return $g
}

# ---------------------------------------------------------------- contrast
$jsContrastLib = @'
window.__ck=(function(){
  function parse(c){var m=c.match(/^rgba?\(([^)]+)\)$/);if(m){var p=m[1].split(/[ ,\/]+/).filter(Boolean).map(Number);return{r:p[0],g:p[1],b:p[2],a:p.length>3?p[3]:1}}
    m=c.match(/^color\(srgb ([^)]+)\)$/);if(m){var q=m[1].split(/[ \/]+/).filter(Boolean).map(Number);return{r:q[0]*255,g:q[1]*255,b:q[2]*255,a:q.length>3?q[3]:1}}return null}
  function over(top,bot){var a=top.a+bot.a*(1-top.a);return{r:(top.r*top.a+bot.r*bot.a*(1-top.a))/a,g:(top.g*top.a+bot.g*bot.a*(1-top.a))/a,b:(top.b*top.a+bot.b*bot.a*(1-top.a))/a,a:a}}
  function eff(el){var layers=[];for(var e=el;e;e=e.parentElement){var c=parse(getComputedStyle(e).backgroundColor);if(c&&c.a>0)layers.push(c)}
    var base={r:255,g:255,b:255,a:1};for(var i=layers.length-1;i>=0;i--)base=over(layers[i],base);return base}
  function lum(c){function f(v){v/=255;return v<=.03928?v/12.92:Math.pow((v+.055)/1.055,2.4)}return .2126*f(c.r)+.7152*f(c.g)+.0722*f(c.b)}
  function ratio(a,b){var x=lum(a),y=lum(b),hi=Math.max(x,y),lo=Math.min(x,y);return (hi+.05)/(lo+.05)}
  return{parse:parse,over:over,eff:eff,ratio:ratio}
})();true
'@
$jsContrastRead = @'
(function(sel){
  var e=document.querySelector(sel);if(!e)return JSON.stringify({miss:true});
  var L=window.__ck,cs=getComputedStyle(e),face=L.eff(e),txt=L.over(L.parse(cs.color)||{r:0,g:0,b:0,a:1},face);
  var out={text:+L.ratio(txt,face).toFixed(2)};
  var g=e.querySelector('.gi');if(g){var gc=L.parse(getComputedStyle(g).backgroundColor);if(gc)out.glyph=+L.ratio(L.over(gc,face),face).toFixed(2)}
  return JSON.stringify(out);
})
'@
function Contrast-Read([string]$sel) {
  $js = $jsContrastRead + "(" + ($sel | ConvertTo-Json -Compress) + ")"
  return (Ev $js) | ConvertFrom-Json
}
function Test-Contrast([string]$scn, [object[]]$targets) {
  Ev $jsContrastLib | Out-Null
  Cdp 'DOM.enable' | Out-Null; Cdp 'CSS.enable' | Out-Null
  $bad = @(); $lines = @()
  foreach ($t in $targets) {
    $doc = Cdp 'DOM.getDocument' @{ depth = 0 }
    $q = Cdp 'DOM.querySelector' @{ nodeId = $doc.root.nodeId; selector = $t.sel }
    if (-not $q.nodeId) { $lines += "$($t.name): missing"; continue }
    foreach ($st in $t.states) {
      if ($st -eq 'normal') { $forced = [string[]]@() } else { $forced = [string[]]@($st) }
      Cdp 'CSS.forcePseudoState' @{ nodeId = $q.nodeId; forcedPseudoClasses = $forced } | Out-Null
      Pause 60
      $c = Contrast-Read $t.sel
      if ($c.miss) { continue }
      $line = "{0}/{1} text {2}" -f $t.name, $st, $c.text
      $minText = if ($t.min) { $t.min } else { 4.5 }
      if ($c.text -lt $minText) { $bad += "$($t.name)/$st text $($c.text) < $minText" }
      if ($null -ne $c.glyph) { $line += " glyph $($c.glyph)"; if ($c.glyph -lt 3) { $bad += "$($t.name)/$st glyph $($c.glyph) < 3" } }
      $lines += $line
    }
    Cdp 'CSS.forcePseudoState' @{ nodeId = $q.nodeId; forcedPseudoClasses = @() } | Out-Null
  }
  Check 'contrast' $scn ($bad.Count -eq 0) (($bad | Select-Object -First 6) -join ' ; ')
  Info 'contrast-pairs' $scn ($lines -join ' | ')
}

# ---------------------------------------------------------------- targets
$hubTargets = @(
  @{ name = 'primary';   sel = '.button-group .btn-primary'; states = @('normal', 'hover', 'active') },
  @{ name = 'ordinary';  sel = '.proj-foot .btn';            states = @('normal', 'hover', 'active') },
  @{ name = 'secondary'; sel = '.button-group .btn-ghost';   states = @('normal', 'hover', 'active') },
  @{ name = 'lang-selected'; sel = '.seg button[aria-pressed="true"]'; states = @('normal', 'hover') },
  @{ name = 'lang';      sel = '.seg button[aria-pressed="false"]';    states = @('normal', 'hover') },
  @{ name = 'theme';     sel = '#themeBtn';                  states = @('normal', 'hover', 'active') },
  @{ name = 'copy';      sel = '.copybox .copy';             states = @('normal', 'hover') },
  @{ name = 'to-top';    sel = '#toTop';                     states = @('normal', 'hover') },
  @{ name = 'card-text'; sel = '.proj-desc';                 states = @('normal') },
  @{ name = 'contact-btn'; sel = '.contact-boxes .btn';      states = @('normal', 'hover') }
)
$showTargets = @(
  @{ name = 'primary';   sel = '#ranks .btn-primary';        states = @('normal', 'hover', 'active') },
  @{ name = 'ordinary';  sel = '#ranks .btn:not(.btn-primary):not(.btn-ghost):not(.btn-danger):not(.is-selected):not([disabled])'; states = @('normal', 'hover', 'active') },
  @{ name = 'secondary'; sel = '#ranks .btn-ghost';          states = @('normal', 'hover', 'active') },
  @{ name = 'danger';    sel = '#ranks .btn-danger';         states = @('normal', 'hover', 'active') },
  @{ name = 'selected';  sel = '#ranks .is-selected';        states = @('normal', 'hover') },
  @{ name = 'lang-selected'; sel = '.seg[aria-label="Language example"] button[aria-pressed="true"]'; states = @('normal', 'hover') },
  @{ name = 'theme';     sel = '#themeBtn';                  states = @('normal', 'hover') },
  @{ name = 'copy';      sel = '.copybox .copy';             states = @('normal', 'hover') },
  @{ name = 'to-top';    sel = '#toTop';                     states = @('normal', 'hover') },
  @{ name = 'group-header'; sel = 'details.sec>summary';     states = @('normal', 'hover', 'active') },
  @{ name = 'option-label'; sel = '.opt-label';              states = @('normal') },
  @{ name = 'option-desc'; sel = '.opt-desc';                states = @('normal') }
)

$jsOptMark = @'
(function(){var L=window.__ck,out=[];
 document.querySelectorAll('.opt-mark').forEach(function(m){var cs=getComputedStyle(m),surf=L.eff(m.parentElement),cb=m.parentElement.querySelector('input');
  var bd=L.parse(cs.borderTopColor),bg=L.parse(cs.backgroundColor);
  var edge=L.ratio(L.over(bd,surf),surf);var tick=cb.checked?L.ratio(L.over(L.parse(cs.color),L.over(bg,surf)),L.over(bg,surf)):null;
  out.push({id:cb.id,checked:cb.checked,disabled:cb.disabled,edge:+edge.toFixed(2),tick:tick===null?null:+tick.toFixed(2)})});
 return JSON.stringify(out)})()
'@
function Test-OptMarks([string]$scn) {
  Ev $jsContrastLib | Out-Null
  $m = (Ev $jsOptMark) | ConvertFrom-Json
  $bad = @($m | Where-Object { -not $_.disabled -and ($_.edge -lt 3 -or ($null -ne $_.tick -and $_.tick -lt 3)) })
  Check 'contrast-checkbox' $scn ($bad.Count -eq 0) (($bad | ForEach-Object { "$($_.id) edge $($_.edge) tick $($_.tick)" }) -join ' ; ')
  Info 'contrast-checkbox-pairs' $scn (($m | ForEach-Object { "$($_.id):edge $($_.edge)$(if($null -ne $_.tick){' tick '+$_.tick})" }) -join ' | ')
}

# ================================================================ run
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('sza-ui-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $tmp | Out-Null
$port = Get-Random -Minimum 9300 -Maximum 9900
$proc = Start-Process -FilePath $Chrome -PassThru -WindowStyle Hidden -ArgumentList @('--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check', "--remote-debugging-port=$port", "--user-data-dir=$tmp\profile", '--hide-scrollbars', '--disable-extensions', 'about:blank')
try {
  $wsUrl = $null
  for ($i = 0; $i -lt 60 -and -not $wsUrl; $i++) {
    Start-Sleep -Milliseconds 250
    try { $lst = Invoke-RestMethod "http://127.0.0.1:$port/json/list"; foreach ($tg in $lst) { if ($tg.type -eq 'page' -and -not $wsUrl) { $wsUrl = [string]$tg.webSocketDebuggerUrl } } } catch { }
  }
  if (-not $wsUrl) { Write-Error 'Could not reach the browser debugging port.'; exit 2 }
  $script:ws = [Net.WebSockets.ClientWebSocket]::new()
  $null = $script:ws.ConnectAsync(([Uri]$wsUrl), [Threading.CancellationToken]::None).GetAwaiter().GetResult()
  foreach ($d in 'Page', 'Runtime', 'Network') { Cdp "$d.enable" | Out-Null }
  Cdp 'Network.setBlockedURLs' @{ urls = @('https://fonts.googleapis.com/*', 'https://fonts.gstatic.com/*', 'https://pagead2.googlesyndication.com/*', 'https://*.googlesyndication.com/*') } | Out-Null
  Cdp 'Page.addScriptToEvaluateOnNewDocument' @{ source = "try{localStorage.clear()}catch(e){}" } | Out-Null
  $ver = (Cdp 'Browser.getVersion').product

  $hubFile = if ($HubPage) { $HubPage } else { Join-Path $root 'index.html' }
  $hubUrl = ([Uri]$hubFile).AbsoluteUri
  Copy-Item (Join-Path $root 'kit/sza-kit.css') (Join-Path $tmp 'sza-kit.css')
  $haveShow = Test-Path $Showcase
  if ($haveShow) { Copy-Item $Showcase (Join-Path $tmp 'showcase.html') }
  $showUrl = ([Uri](Join-Path $tmp 'showcase.html')).AbsoluteUri

  # ------------------------------------------------------------ hub scenarios
  if ($Target -in 'all', 'hub') {
    $scn = @(
      @{ id = 'H1'; w = 1280; h = 900;  touch = $false; scheme = 'dark';  lang = 'en'; size = '';        forced = 'none' },
      @{ id = 'H2'; w = 1280; h = 900;  touch = $false; scheme = 'light'; lang = 'en'; size = '';        forced = 'none' },
      @{ id = 'H3'; w = 360;  h = 740;  touch = $true;  scheme = 'dark';  lang = 'en'; size = '';        forced = 'none' },
      @{ id = 'H4'; w = 360;  h = 740;  touch = $true;  scheme = 'light'; lang = 'ru'; size = '';        forced = 'none' },
      @{ id = 'H5'; w = 1280; h = 900;  touch = $false; scheme = 'dark';  lang = 'uk'; size = 'compact'; forced = 'none' },
      @{ id = 'H6'; w = 1280; h = 900;  touch = $false; scheme = 'dark';  lang = 'en'; size = 'huge';    forced = 'none' },
      @{ id = 'H7'; w = 320;  h = 640;  touch = $true;  scheme = 'dark';  lang = 'uk'; size = 'xlarge';  forced = 'none' },
      @{ id = 'H8'; w = 2560; h = 1100; touch = $false; scheme = 'dark';  lang = 'en'; size = '';        forced = 'none' },
      @{ id = 'H9'; w = 1280; h = 900;  touch = $false; scheme = 'dark';  lang = 'en'; size = '';        forced = 'active' },
      @{ id = 'H10'; w = 360; h = 740;  touch = $true;  scheme = 'dark';  lang = 'en'; size = 'compact'; forced = 'none' },
      @{ id = 'H11'; w = 1920; h = 1000; touch = $false; scheme = 'dark';  lang = 'en'; size = '';        forced = 'none' },
      @{ id = 'H12'; w = 768;  h = 1000; touch = $false; scheme = 'dark';  lang = 'en'; size = '';        forced = 'none' }
    )
    foreach ($s in $scn) {
      $name = "hub-$($s.id)-$($s.w)-$(if($s.touch){'touch'}else{'pointer'})-$($s.scheme)-$($s.lang)-$(if($s.size){$s.size}else{'ordinary'})$(if($s.forced -eq 'active'){'-forced-colors'})"
      Open-Page $hubUrl $s.w $s.h $s.touch $s.scheme $s.forced
      if ($s.lang -ne 'en') { Ev "setLanguage('$($s.lang)')" | Out-Null }
      if ($s.size) { Ev "document.documentElement.setAttribute('data-ui-size','$($s.size)')" | Out-Null }
      Pause 250
      $prof = Ev "document.documentElement.getAttribute('data-ui-profile')"
      Check 'profile-resolver' $name ($prof -eq $(if ($s.touch) { 'touch' } else { 'pointer' })) "data-ui-profile=$prof"
      Test-Geometry $name | Out-Null
      if ($s.forced -eq 'none' -and $s.id -in 'H1', 'H2', 'H3', 'H4') { Test-Contrast $name $hubTargets }
      $np = [int](Ev "document.querySelectorAll('.btn-primary').length")
      Check 'one-primary' $name ($np -le 1) "$np primary command(s) on the page"
      if ($s.forced -eq 'none' -and -not $s.size) {
        # PAGE-STYLE 11 / PAGE-CONTENT layout contract: the content box is at least the viewport minus 80 at 360, 768, 1280,
        # 1920 and 2560; no wrapper of ordinary text carries a max-width; header, hero text and footer share one left edge.
        $okw = Ev "(()=>{const r=(document.querySelector('main')||document.querySelector('.container')).getBoundingClientRect();return r.width>=(window.__W||innerWidth)-80})()"
        Check 'full-width' $name ([bool]$okw) 'container is at least viewport minus 80'
        $capped = Ev "JSON.stringify([].filter.call(document.querySelectorAll('html,body,.container,.site-header,.hero,.section,.site-footer,.section-desc,.lead,.hero-id'),function(e){return ['none','100%'].indexOf(getComputedStyle(e).maxWidth)<0}).map(function(e){return e.tagName+'.'+e.className+'='+getComputedStyle(e).maxWidth}))" | ConvertFrom-Json
        Check 'no-max-width-on-wrappers' $name (@($capped).Count -eq 0) ("capped: " + (@($capped) -join '; '))
        $edges = Ev "JSON.stringify({head:document.querySelector('.site-header .brand').getBoundingClientRect().left,hero:document.querySelector('.hero-id').getBoundingClientRect().left,foot:document.querySelector('.footer-bottom').getBoundingClientRect().left})" | ConvertFrom-Json
        Check 'left-edge-aligned' $name ([math]::Abs($edges.hero - $edges.foot) -lt 1.5) "hero $($edges.hero) footer $($edges.foot)"
        Info 'header-brand-inset' $name "header brand text starts at $($edges.head), hero at $($edges.hero): inset $([math]::Round($edges.head - $edges.hero, 1)) px (kit .brand padding-inline; PAGE-STYLE 5 Width asks one x position)"
      }
      if ($s.id -eq 'H3') {
        $ov = [double](Ev "document.documentElement.scrollWidth-(window.__W||innerWidth)")
        Check 'no-horizontal-scroll-360' $name ($ov -le 1) "overflow $ov"
      }
      Capture $name
    }

    # ---- hub behaviour: desktop pointer
    $b = 'hub-behaviour-pointer-1280'
    Open-Page $hubUrl 1280 900 $false 'dark'
    $order = @(); Ev "document.body.focus();true" | Out-Null
    for ($i = 0; $i -lt 12; $i++) { KTab; $order += (Ev "(function(){var e=document.activeElement;var o=getComputedStyle(e);return (e.id||e.className||e.tagName)+'|'+(e.getAttribute('data-lang')||'')+'|'+o.outlineStyle+'|'+o.outlineWidth})()") }
    Info 'tab-order' $b ($order -join ' > ')
    $noRing = @($order | Where-Object { $_ -match '\|none\|' })
    Check 'focus-ring-visible' $b ($noRing.Count -eq 0) (($noRing | Select-Object -First 3) -join ' ; ')
    $themeBefore = Ev "document.documentElement.getAttribute('data-theme')"
    Click '#themeBtn'
    $themeAfter = Ev "document.documentElement.getAttribute('data-theme')"
    Check 'theme-toggles-once' $b ($themeBefore -ne $themeAfter -and (Ev "localStorage.getItem('sza-theme')") -eq $themeAfter) "$themeBefore -> $themeAfter"
    Ev "document.getElementById('themeBtn').focus();true" | Out-Null; KEnter
    $t3 = Ev "document.documentElement.getAttribute('data-theme')"
    Check 'theme-keyboard-enter' $b ($t3 -eq $themeBefore) "after Enter $t3"
    Click '.seg button[data-lang="ru"]'
    $lg = Ev "JSON.stringify({lang:document.documentElement.lang,p:document.querySelector('.seg button[data-lang=ru]').getAttribute('aria-pressed'),copy:document.querySelector('.copy .cl-idle').textContent,ext:document.querySelector('.proj-foot .sr span').textContent})" | ConvertFrom-Json
    Check 'language-switch' $b ($lg.lang -eq 'ru' -and $lg.p -eq 'true' -and $lg.copy -eq 'Копировать' -and $lg.ext) ($lg | ConvertTo-Json -Compress)
    Click '.seg button[data-lang="en"]'
    # copy: state word reserves width, neighbours do not move, repeated activation
    $before = Ev "(function(){var c=document.querySelectorAll('.copybox .copy');return JSON.stringify([].map.call(c,function(x){var r=x.getBoundingClientRect();return[r.left,r.width,x.parentElement.getBoundingClientRect().right]}))})()" | ConvertFrom-Json
    Click '.copybox .copy'
    $done = Ev "document.querySelector('.copybox .copy').classList.contains('done')"
    $during = Ev "(function(){var c=document.querySelectorAll('.copybox .copy');return JSON.stringify([].map.call(c,function(x){var r=x.getBoundingClientRect();return[r.left,r.width,x.parentElement.getBoundingClientRect().right]}))})()" | ConvertFrom-Json
    $moved = $false; for ($i = 0; $i -lt $before.Count; $i++) { for ($k = 0; $k -lt 3; $k++) { if ([math]::Abs($before[$i][$k] - $during[$i][$k]) -gt 0.5) { $moved = $true } } }
    Check 'copy-done-no-movement' $b ($done -and -not $moved) "done=$done moved=$moved"
    Click '.copybox .copy'; Click '.copybox .copy'
    $status = Ev "document.getElementById('copyStatus').textContent"
    Check 'copy-repeat-and-announce' $b ($status -eq 'Copied') "status='$status'"
    Pause 1900
    Check 'copy-done-resets' $b (-not (Ev "document.querySelector('.copybox .copy').classList.contains('done')")) 'done class removed after 1.6 s'
    # back to top
    Ev "window.scrollTo(0,1400);true" | Out-Null; Pause 300
    $shown = Ev "document.getElementById('toTop').classList.contains('show')"
    Click '#toTop'; Pause 600
    Check 'to-top' $b ($shown -and (Ev 'window.scrollY') -lt 5) "shown=$shown scrollY=$(Ev 'window.scrollY')"
    $tt = Ev "JSON.stringify({t:document.getElementById('toTop').title,a:document.getElementById('toTop').getAttribute('aria-label')})" | ConvertFrom-Json
    Check 'to-top-name-and-title' $b ($tt.t -and $tt.a) ($tt | ConvertTo-Json -Compress)
    # external destination: link semantics, new window, accessible text
    $ext = Ev "(function(){var a=document.querySelector('.proj-foot a.btn');return JSON.stringify({tag:a.tagName,href:a.getAttribute('href'),target:a.target,rel:a.rel,sr:a.querySelector('.sr').textContent.trim(),marker:!!a.querySelector('.gi-external')})})()" | ConvertFrom-Json
    Check 'external-link-semantics' $b ($ext.tag -eq 'A' -and $ext.target -eq '_blank' -and $ext.rel -match 'noopener' -and $ext.marker -and $ext.sr) ($ext | ConvertTo-Json -Compress)
    # reduced motion: no running animation or transition
    Cdp 'Emulation.setEmulatedMedia' @{ features = @(@{ name = 'prefers-reduced-motion'; value = 'reduce' }) } | Out-Null
    $anim = [int](Ev "document.getAnimations().length")
    Info 'reduced-motion' $b "running animations with reduce: $anim (page-level transitions are disabled by the kit rule *, ::before, ::after)"

    # ---- hub behaviour: touch (tap vs scroll)
    $b = 'hub-behaviour-touch-360'
    Open-Page $hubUrl 360 740 $true 'dark'
    $r = Rect '.seg button[data-lang="ru"]'; Tap $r.x $r.y
    Check 'touch-tap-language' $b ((Ev "document.documentElement.getAttribute('data-lang')") -eq 'ru') 'tap on RU switches language'
    $r = Rect '#themeBtn'; $t0 = Ev "document.documentElement.getAttribute('data-theme')"; Tap $r.x $r.y
    Check 'touch-tap-theme' $b ((Ev "document.documentElement.getAttribute('data-theme')") -ne $t0) 'tap on Theme toggles the theme'
    # drag that scrolls must not activate a button
    $r = Rect '.button-group .btn-primary'; $y0 = [double](Ev 'window.scrollY'); $y1 = [double]$r.y
    Ev "window.__hit=0;document.querySelectorAll('.btn').forEach(function(b){b.addEventListener('click',function(e){window.__hit++;e.preventDefault()})});true" | Out-Null
    Cdp 'Input.dispatchTouchEvent' @{ type = 'touchStart'; touchPoints = @(@{ x = $r.x; y = $y1 }) } | Out-Null
    foreach ($d in 20, 60, 100, 140, 180) { Cdp 'Input.dispatchTouchEvent' @{ type = 'touchMove'; touchPoints = @(@{ x = $r.x; y = [math]::Max(5, $y1 - $d) }) } | Out-Null; Pause 30 }
    Cdp 'Input.dispatchTouchEvent' @{ type = 'touchEnd'; touchPoints = @() } | Out-Null; Pause 400
    $y2 = [double](Ev 'window.scrollY'); $hit = [int](Ev 'window.__hit')
    if ($y2 -gt $y0 + 20) { Check 'touch-scroll-cancels-activation' $b ($hit -eq 0) "scrolled $([int]($y2-$y0)) px, activations $hit" }
    else { Info 'touch-scroll-cancels-activation' $b "inconclusive: the synthetic drag did not scroll ($y0 -> $y2); native browsers emit no click after a scroll gesture" }

    # ---- hub stored values (PAGE-STYLE 7: sza-lang holds exactly ru/en/ua, sza-theme exactly dark/light; a reader maps
    # uk to ua and sends any other value to the navigator.language / prefers-color-scheme resolution). A script registered
    # after the harness's localStorage.clear() seeds each case before the page's pre-paint script runs.
    $cases = @(
      @{ n = 'garbage';  theme = 'blue'; lang = 'fr'; scheme = 'light'; wantTheme = 'light'; wantLang = 'en'; wantHtml = 'en' },
      @{ n = 'empty';    theme = '';     lang = '';   scheme = 'dark';  wantTheme = 'dark';  wantLang = 'en'; wantHtml = 'en' },
      @{ n = 'uk-alias'; theme = 'dark'; lang = 'uk'; scheme = 'light'; wantTheme = 'dark';  wantLang = 'ua'; wantHtml = 'uk' },
      @{ n = 'valid';    theme = 'light'; lang = 'ru'; scheme = 'dark'; wantTheme = 'light'; wantLang = 'ru'; wantHtml = 'ru' }
    )
    foreach ($c in $cases) {
      $b = "hub-stored-values-$($c.n)"
      $seedJs = "try{localStorage.setItem('sza-theme','$($c.theme)');localStorage.setItem('sza-lang','$($c.lang)')}catch(e){}"
      $seed = Cdp 'Page.addScriptToEvaluateOnNewDocument' @{ source = $seedJs }
      Open-Page $hubUrl 1280 900 $false $c.scheme
      Pause 300
      $got = Ev "JSON.stringify({theme:document.documentElement.getAttribute('data-theme'),lang:document.documentElement.getAttribute('data-lang'),html:document.documentElement.lang})" | ConvertFrom-Json
      Check 'stored-theme-fallback' $b ($got.theme -eq $c.wantTheme) "stored '$($c.theme)', prefers $($c.scheme) -> data-theme=$($got.theme), wanted $($c.wantTheme)"
      Check 'stored-lang-fallback' $b ($got.lang -eq $c.wantLang -and $got.html -eq $c.wantHtml) "stored '$($c.lang)' -> data-lang=$($got.lang) lang=$($got.html), wanted $($c.wantLang) / $($c.wantHtml)"
      Cdp 'Page.removeScriptToEvaluateOnNewDocument' @{ identifier = $seed.identifier } | Out-Null
    }
  }

  # ------------------------------------------------------------ showcase scenarios
  if ($Target -in 'all', 'showcase') {
    if (-not $haveShow) { Check 'showcase-present' 'showcase' $false "no showcase at $Showcase" }
    else {
      $sc = @(
        @{ id = 'S1'; w = 1280; h = 900; touch = $false; q = 'theme=dark&profile=pointer' },
        @{ id = 'S2'; w = 1280; h = 900; touch = $false; q = 'theme=light&profile=pointer' },
        @{ id = 'S3'; w = 360;  h = 740; touch = $true;  q = 'theme=dark' },
        @{ id = 'S4'; w = 360;  h = 740; touch = $true;  q = 'theme=light&long=1' },
        @{ id = 'S5'; w = 1280; h = 900; touch = $false; q = 'theme=dark&profile=pointer&size=compact' },
        @{ id = 'S6'; w = 1280; h = 900; touch = $false; q = 'theme=dark&profile=pointer&size=huge' },
        @{ id = 'S7'; w = 1280; h = 900; touch = $false; q = 'theme=dark&profile=pointer&dir=rtl' },
        @{ id = 'S8'; w = 320;  h = 640; touch = $true;  q = 'theme=dark&size=xlarge&long=1' },
        @{ id = 'S9'; w = 360;  h = 740; touch = $true;  q = 'theme=dark&size=compact&long=1' },
        @{ id = 'S10'; w = 1280; h = 900; touch = $false; q = 'theme=light&profile=pointer&long=1&dir=rtl' }
      )
      foreach ($s in $sc) {
        $name = "showcase-$($s.id)-$($s.w)-" + ($s.q -replace '[=&]', '-')
        Open-Page ($showUrl + '?' + $s.q) $s.w $s.h $s.touch ($(if ($s.q -match 'theme=light') { 'light' } else { 'dark' }))
        Test-Geometry $name | Out-Null
        if ($s.id -in 'S1', 'S2') { Test-Contrast $name $showTargets; Test-OptMarks $name }
        Capture $name
      }

      # ---- showcase behaviour: pointer
      $b = 'showcase-behaviour-pointer-1280'
      Open-Page ($showUrl + '?theme=dark&profile=pointer') 1280 900 $false 'dark'
      $secState = { param($i) Ev "document.querySelectorAll('details.sec')[$i].open" }
      # group header: whole header toggles once; body does not
      $o0 = & $secState 1
      Click 'details.sec:nth-of-type(2) > summary' -dx 0
      $o1 = & $secState 1
      Check 'group-header-caption-toggles-once' $b ($o0 -eq $false -and $o1 -eq $true) "closed=$o0 -> open=$o1"
      $r = Rect 'details.sec:nth-of-type(2) > summary'
      ClickAt ($r.l + $r.w - 12) $r.y
      Check 'group-header-whitespace-toggles' $b (-not (& $secState 1)) 'click on empty header space closes it'
      Click 'details.sec:nth-of-type(3) > p'
      Check 'group-body-click-does-not-toggle' $b ([bool](& $secState 2)) 'body paragraph click keeps the group open'
      Ev "document.querySelectorAll('details.sec')[1].querySelector('summary').focus();true" | Out-Null
      KEnter; $k1 = & $secState 1; KSpace; $k2 = & $secState 1
      $focused = Ev "document.activeElement.tagName"
      Check 'group-keyboard-enter-space' $b ($k1 -eq $true -and $k2 -eq $false -and $focused -eq 'SUMMARY') "Enter->$k1 Space->$k2 focus=$focused"
      $indep = (& $secState 0) -and (& $secState 2)
      Check 'groups-independent' $b ([bool]$indep) 'opening or closing one never closed another'
      $hidden = [int](Ev "(function(){var d=document.querySelectorAll('details.sec')[1];var n=0;d.querySelectorAll('a,button,input').forEach(function(e){if(e.offsetParent!==null)n++});return n})()")
      Check 'group-collapsed-has-no-reachable-targets' $b ($hidden -eq 0) "$hidden visible focus targets in a collapsed body"
      # boolean option: toggle once on checkbox, caption, glyph; never on description, gap or help
      function OptVal([string]$id) { Ev "document.getElementById('$id').checked" }
      $v = OptVal 'b2'; Click '#b2 + .opt-mark'; $v1 = OptVal 'b2'; Click 'label[for="b2"]'; $v2 = OptVal 'b2'; Click 'label[for="b2"] .gi'; $v3 = OptVal 'b2'
      Check 'option-checkbox-caption-glyph-toggle-once' $b ($v -eq $false -and $v1 -eq $true -and $v2 -eq $false -and $v3 -eq $true) "$v -> $v1 -> $v2 -> $v3"
      Click '#b2d'; $d1 = OptVal 'b2'
      Check 'option-explanation-does-not-toggle' $b ($d1 -eq $true) "after explanation click: $d1"
      $r = Rect '#b2d'; ClickAt ($r.l + $r.w + 20) $r.y; Check 'option-empty-space-does-not-toggle' $b ((OptVal 'b2') -eq $true) 'click on the empty row area'
      Click '.opt-help'; $h1 = OptVal 'b4'
      $exp = Ev "document.querySelector('.opt-help').getAttribute('aria-expanded')"; $pop = Ev "!!document.querySelector('.opt-pop')"
      Check 'option-help-click-opens-full-never-toggles' $b ($h1 -eq $false -and $exp -eq 'true' -and $pop) "checked=$h1 expanded=$exp popup=$pop"
      $full = Ev "document.querySelector('.opt-pop').textContent"; $short = Ev "document.querySelector('#h4').content.firstElementChild.textContent"
      Check 'option-help-one-source' $b ($full.StartsWith($short)) 'the full text begins with the short summary taken from the same template'
      Click '.opt-pop .btn'; $back = Ev "document.activeElement.className"
      Check 'option-help-close-returns-focus' $b ($back -match 'opt-help' -and -not (Ev "!!document.querySelector('.opt-pop')")) "focus on $back"
      Hover '.opt-help'; $tip = Ev "!!document.querySelector('.opt-tip')"
      KEsc; $tip2 = Ev "!!document.querySelector('.opt-tip')"
      Check 'option-help-hover-summary-escape' $b ($tip -and -not $tip2 -and -not (OptVal 'b4')) "tip=$tip after Esc=$tip2"
      Ev "document.getElementById('b2').focus();true" | Out-Null; $w0 = OptVal 'b2'; KSpace; $w1 = OptVal 'b2'
      Check 'option-space-toggles-focus-alone-does-not' $b ($w0 -ne $w1) "$w0 -> $w1"
      Ev "document.getElementById('b3').focus();true" | Out-Null; KSpace
      Check 'option-disabled-never-toggles' $b (-not (OptVal 'b3')) 'disabled checkbox ignored Space'; Click 'label[for="b3"]'; Check 'option-disabled-label-never-toggles' $b (-not (OptVal 'b3')) 'disabled caption click'
      # dialog: safe default focus, Escape, focus return, destructive explicit
      Click '#openDialog'; $df = Ev "document.activeElement.id"
      Check 'dialog-safe-default-focus' $b ($df -eq 'dlgCancel') "focus on $df"
      KEsc; $dr = Ev "document.activeElement.id"
      Check 'dialog-escape-no-action-focus-return' $b ($dr -eq 'openDialog' -and -not (Ev "document.getElementById('dlg').open") -and (Ev "document.getElementById('status').textContent") -ne 'Deleted') "focus on $dr"
      Click '#openDialog'; KTab; $tf = Ev "document.activeElement.id"; KEnter
      Check 'dialog-explicit-destructive' $b ($tf -eq 'dlgDelete' -and (Ev "document.getElementById('status').textContent") -eq 'Deleted') "tab reached $tf"
      # menu: focus in, Escape out and back
      Click '#menuBtn'; $mf = Ev "document.activeElement.getAttribute('role')"; $ex = Ev "document.getElementById('menuBtn').getAttribute('aria-expanded')"
      KEsc; $mr = Ev "document.activeElement.id"
      Check 'menu-focus-in-and-return' $b ($mf -eq 'menuitem' -and $ex -eq 'true' -and $mr -eq 'menuBtn') "in=$mf expanded=$ex back=$mr"
      # toggle / repeated activation / exclusive choice
      Click '#toggleBtn'; Click '#toggleBtn'; Click '#toggleBtn'
      Check 'toggle-repeated-activation' $b ((Ev "document.getElementById('toggleBtn').getAttribute('aria-pressed')") -eq 'true') 'three activations leave it pressed'
      Click '.seg[aria-label="Language example"] button:nth-child(3)'
      Check 'segmented-exclusive' $b ((Ev 'document.querySelectorAll(''.seg[aria-label="Language example"] button[aria-pressed=true]'').length') -eq 1) 'exactly one pressed part'
      # copy button widths: both state words sit in one cell
      $cw = Ev "(function(){var c=document.querySelector('.copybox .copy'),a=c.getBoundingClientRect().width;c.classList.add('done');var b=c.getBoundingClientRect().width;c.classList.remove('done');return a+'|'+b})()"
      $parts = $cw -split '\|'; Check 'copy-reserves-widest-state' $b ([math]::Abs([double]$parts[0] - [double]$parts[1]) -lt .5) "idle $($parts[0]) done $($parts[1])"

      # ---- showcase behaviour: touch (scroll versus tap on an option)
      $b = 'showcase-behaviour-touch-360'
      Open-Page ($showUrl + '?theme=dark') 360 740 $true 'dark'
      $r = Rect 'label[for="b2"]'; $before = OptVal 'b2'
      Ev "window.__c=[];['click','pointerdown','pointerup','touchstart'].forEach(function(t){document.addEventListener(t,function(e){window.__c.push(t+':'+(e.target.id||e.target.className||e.target.tagName))},true)});true" | Out-Null
      Tap $r.x $r.y; $after = OptVal 'b2'
      $evlog = Ev "window.__c.join(',')"; $atpt = Ev ("(function(){var e=document.elementFromPoint(" + $r.x + "," + $r.y + ");var v=window.visualViewport;return (e?(e.tagName+'.'+e.className):'none')+' sy='+scrollY+' vv='+v.scale+','+v.offsetTop+','+v.pageTop+' inner='+(window.__W||innerWidth)+'x'+innerHeight})()")
      Check 'touch-tap-caption-toggles-once' $b ($before -eq $false -and $after -eq $true) "$before -> $after; at point $atpt; events $evlog"
      $r = Rect 'label[for="b2"]'; $y0 = [double](Ev 'window.scrollY'); $y1 = $r.y
      Cdp 'Input.dispatchTouchEvent' @{ type = 'touchStart'; touchPoints = @(@{ x = $r.x; y = $y1 }) } | Out-Null
      foreach ($d in 20, 60, 100, 140, 180) { Cdp 'Input.dispatchTouchEvent' @{ type = 'touchMove'; touchPoints = @(@{ x = $r.x; y = [math]::Max(5, $y1 - $d) }) } | Out-Null; Pause 30 }
      Cdp 'Input.dispatchTouchEvent' @{ type = 'touchEnd'; touchPoints = @() } | Out-Null; Pause 400
      $y2 = [double](Ev 'window.scrollY'); $still = OptVal 'b2'
      if ($y2 -gt $y0 + 20) { Check 'touch-scroll-cancels-option-activation' $b ($still -eq $after) "scrolled $([int]($y2-$y0)) px, value $after -> $still" }
      else { Info 'touch-scroll-cancels-option-activation' $b "inconclusive: the synthetic drag did not scroll ($y0 -> $y2)" }
      $r = Rect 'details.sec:nth-of-type(2) > summary'; $s0 = Ev "document.querySelectorAll('details.sec')[1].open"; Tap $r.x $r.y
      Check 'touch-tap-group-header' $b ((Ev "document.querySelectorAll('details.sec')[1].open") -ne $s0) 'tap on the header toggles the group'
    }
  }
  $failed = @($script:Res | Where-Object Status -eq 'FAIL').Count
  $passed = @($script:Res | Where-Object Status -eq 'PASS').Count
}
finally {
  try { if ($script:ws) { $script:ws.Dispose() } } catch { }
  try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch { }
  Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*$tmp*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
  Start-Sleep -Milliseconds 400
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------- report
$report = New-Object System.Collections.Generic.List[string]
$report.Add('# UI check results')
$report.Add('')
$report.Add("- Run: $(Get-Date -Format 'yyyy-MM-dd HH:mm') on $([Environment]::OSVersion.VersionString), $ver (headless)")
$report.Add("- Target: $Target; kit sha256 $((Get-FileHash (Join-Path $root 'kit/sza-kit.css')).Hash.ToLower())")
$report.Add("- Contracts read at: BUTTONS 2.0, UI-SIZING 1.1, COLLAPSIBLE-GROUP 1.1, BOOLEAN-OPTION 2.0, ICON-RENDER 0.24, PAGE-STYLE 3.3, PAGE-CONTENT 1.5")
$report.Add('- External requests (web fonts, AdSense loader) are blocked: captures use the system-font fallback.')
$report.Add("- Result: $passed passed, $failed failed")
$report.Add('')
$report.Add('| Status | Check | Scenario | Detail |')
$report.Add('| --- | --- | --- | --- |')
foreach ($x in $script:Res) { $report.Add("| $($x.Status) | $($x.Id) | $($x.Scenario) | $(($x.Detail -replace '\|', '/') -replace "`r?`n", ' ') |") }
$report.Add('')
$report.Add('## Captures')
foreach ($c in $script:Caps) { $report.Add("- $c") }
[IO.File]::WriteAllText((Join-Path $Out 'RESULTS.md'), ($report -join "`n") + "`n", (New-Object System.Text.UTF8Encoding($false)))
Write-Host "ui-check: $passed passed, $failed failed; report $(Join-Path $Out 'RESULTS.md')"
if ($failed -gt 0) { exit 1 } else { exit 0 }

<#
  Fairy 一键安装器  (Fairy-DSH 语音桌宠)
  ---------------------------------------------------------------
  只用 Windows 内置能力（PowerShell 5.1 + tar.exe / Expand-Archive），
  目标电脑无需预装 Python / Node / 7-Zip。

  用法（普通用户双击同目录的「安装 Fairy.bat」即可）：
    powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1

  可选参数：
    -Target D:\Fairy      指定安装目录（默认 D:\Fairy；若该盘不存在则用 C:\Fairy）
    -DataZip <路径>       指定数据包 zip（默认自动在同目录找 Fairy-Data-*.zip）
    -SkipData             跳过数据包解压（只装程序，GPT-SoVITS 稍后再补）
    -Force                目标目录非空时不再询问，直接覆盖
    -NoShortcut           不创建桌面快捷方式
#>
#requires -version 5.1
[CmdletBinding()]
param(
    [string]$Target = "",
    [string]$DataZip = "",
    [switch]$SkipData,
    [switch]$Force,
    [switch]$NoShortcut
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'Continue'

$SrcRoot = $PSScriptRoot
$PayloadDir = Join-Path $SrcRoot 'payload'
$LogFile = Join-Path $env:TEMP ('fairy-install-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')

# 原开发机上的写死路径（打包时已把本机用户名路径预改写成 D:\Fairy 形态，
# 安装时只需把 D:\Fairy 整体替换成实际安装目录）
$OLD_ROOT = 'D:\Fairy'

function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }
function Step($n, $total, $msg) { Write-Host ''; Say ("[{0}/{1}] {2}" -f $n, $total, $msg) 'Cyan' }
function Ok($msg) { Say ("      OK  " + $msg) 'Green' }
function Warn($msg) { Say ("      !   " + $msg) 'Yellow' }
function Die($msg) { Say ("      X   " + $msg) 'Red'; Say ''; Say "日志: $LogFile"; exit 1 }

function Log($msg) {
    try { Add-Content -LiteralPath $LogFile -Value ("{0}  {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg) -Encoding UTF8 } catch { }
}

function Human($bytes) {
    if ($bytes -ge 1GB) { return ("{0:N2} GB" -f ($bytes / 1GB)) }
    if ($bytes -ge 1MB) { return ("{0:N1} MB" -f ($bytes / 1MB)) }
    if ($bytes -ge 1KB) { return ("{0:N0} KB" -f ($bytes / 1KB)) }
    return "$bytes B"
}

Say '============================================================' 'White'
Say '  Fairy 一键安装器  (Fairy-DSH 语音桌宠)' 'White'
Say '============================================================' 'White'
Say ("  来源: {0}" -f $SrcRoot)
Say ("  日志: {0}" -f $LogFile)
Log "install start, SrcRoot=$SrcRoot"

if (-not (Test-Path -LiteralPath $PayloadDir)) { Die "安装包不完整：找不到 payload 目录 ($PayloadDir)" }

# ---------------------------------------------------------------- 1. 目标目录
Step 1 7 '确定安装目录'

if (-not $Target) {
    if (Test-Path 'D:\') { $Target = 'D:\Fairy' } else { $Target = 'C:\Fairy' }
    Say ("      默认安装到: {0}" -f $Target)
    Say '      直接回车使用默认；或输入其它完整路径（例如 E:\Fairy）后回车：'
    $answer = Read-Host '  > '
    if ($answer -and $answer.Trim()) { $Target = $answer.Trim().Trim('"') }
}
$Target = $Target.TrimEnd('\').TrimEnd('/')

if ($Target -match '^[A-Za-z]:$') { Die "安装目录不能是盘符根目录，请给出子目录，例如 $Target\Fairy" }
$drive = Split-Path -Qualifier $Target -ErrorAction SilentlyContinue
if (-not $drive -or -not (Test-Path ($drive + '\'))) { Die "盘符不存在: $drive" }

# 空间检查：完整安装需要约 13GB
$needGB = if ($SkipData) { 3 } else { 13 }
$free = (Get-PSDrive ($drive.TrimEnd(':'))).Free
Say ("      可用空间 {0} / 需要约 {1} GB" -f (Human $free), $needGB)
if ($free -lt ($needGB * 1GB)) { Die "磁盘空间不足（$drive 可用 $(Human $free)）" }
Ok "安装目录 $Target"

$targetExists = (Test-Path -LiteralPath $Target) -and ((Get-ChildItem -LiteralPath $Target -Force -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0)
if ($targetExists -and -not $Force) {
    Warn "目标目录已存在且非空: $Target"
    Say '      继续会覆盖同名文件（不会删除该目录里的其它内容）。'
    $a = Read-Host '      确认继续？输入 y 继续，其它任意键退出 (y/N) '
    if ($a -notmatch '^(?i)y') { Say '      已取消。'; exit 0 }
}
if (-not (Test-Path -LiteralPath $Target)) { New-Item -ItemType Directory -Path $Target -Force | Out-Null }

# ---------------------------------------------------------------- 2. 数据包
Step 2 7 '定位数据包'

$dataFound = $null
if (-not $SkipData) {
    if ($DataZip) {
        if (Test-Path -LiteralPath $DataZip) { $dataFound = (Resolve-Path -LiteralPath $DataZip).Path }
        else { Warn "指定的数据包不存在: $DataZip" }
    } else {
        $cands = @(Get-ChildItem -LiteralPath $SrcRoot -Filter 'Fairy-Data-*.zip' -File -ErrorAction SilentlyContinue)
        $up = @(Get-ChildItem -LiteralPath (Split-Path $SrcRoot -Parent) -Filter 'Fairy-Data-*.zip' -File -ErrorAction SilentlyContinue)
        $all = @($cands) + @($up)
        if ($all.Count -gt 0) { $dataFound = ($all | Sort-Object Length -Descending | Select-Object -First 1).FullName }
    }
    if ($dataFound) {
        Ok ("数据包 " + (Split-Path $dataFound -Leaf) + "  " + (Human (Get-Item -LiteralPath $dataFound).Length))
    } else {
        Warn '没找到数据包 Fairy-Data-*.zip'
        Say '      它是 11GB 的 GPT-SoVITS 语音运行时，没有它桌宠能开但不会说话。'
        $a = Read-Host '      只装程序、稍后自己补数据包？(y/N) '
        if ($a -match '^(?i)y') { $SkipData = $true } else { Die '请把数据包放到安装器同目录后重试' }
    }
} else {
    Say '      已指定 -SkipData，跳过'
}

# ---------------------------------------------------------------- 3. 解压数据包
Step 3 7 '解压数据包（GPT-SoVITS 语音运行时，约 11GB，请耐心等待）'

if ($SkipData) {
    Warn '已跳过数据包解压 —— 语音后端不可用'
} else {
    $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
    $t0 = Get-Date
    if (Test-Path -LiteralPath $tar) {
        Say '      使用系统 tar.exe 解压（最快）...'
        Log "tar -xf $dataFound -C $Target"
        & $tar -xf $dataFound -C $Target
        if ($LASTEXITCODE -ne 0) { Die "tar.exe 解压失败（退出码 $LASTEXITCODE），可用资源管理器右键解压数据包到 $Target 后重跑本安装器" }
    } else {
        Warn '未找到 tar.exe，回退到 Expand-Archive（较慢）...'
        Expand-Archive -LiteralPath $dataFound -DestinationPath $Target -Force
    }
    $dt = (Get-Date) - $t0
    Ok ("数据包解压完成，用时 {0:N1} 分钟" -f $dt.TotalMinutes)
}

# ---------------------------------------------------------------- 4. 铺程序
Step 4 7 '写入程序文件'

# 必须用 robocopy：PowerShell 的 Copy-Item 逐文件拷贝，11 万个文件要跑一小时以上；
# robocopy /MT:16 实测是它的 100 倍（同批文件 27 文件/秒 → 2976 文件/秒）。
# robocopy 是 Windows 自带组件，不额外依赖任何东西。退出码 <8 表示成功。
$t0 = Get-Date
& robocopy $PayloadDir $Target /E /NFL /NDL /NP /R:1 /W:1 /MT:16 | Out-Null
$rc = $LASTEXITCODE
$dt = (Get-Date) - $t0
if ($rc -ge 8) { Die "复制程序文件失败（robocopy 退出码 $rc）" }
$n = (Get-ChildItem -LiteralPath $Target -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object).Count
Ok ("程序文件 {0:N0} 个，用时 {1:N1} 秒" -f $n, $dt.TotalSeconds)

# ---------------------------------------------------------------- 5. 路径重写
Step 5 7 '重写写死的绝对路径'

$rules = @()
# 同一个旧路径在文件里有三种写法，都要覆盖：
#   正斜杠      D:/Fairy      （原来 config.json 里就是这种）
#   单反斜杠    D:\Fairy      （bat / ps1 / py 里）
#   双反斜杠    D:\\Fairy     （JSON 会把反斜杠转义成两个！漏了这个则 json 里的路径改不掉）
foreach ($m in @(
        @{ old = $OLD_ROOT; new = $Target })) {
    $rules += @{ from = $m.old.Replace('\', '/'); to = $m.new.Replace('\', '/') }
    $rules += @{ from = $m.old; to = $m.new }
    $rules += @{ from = $m.old.Replace('\', '\\'); to = $m.new.Replace('\', '\\') }
}
# 先替换最长的形态（双反斜杠），避免被短规则截断
$rules = $rules | Sort-Object -Property @{ Expression = { $_.from.Length } } -Descending

$gbkExt = @('.bat', '.cmd')
$txtExt = @('.bat', '.cmd', '.ps1', '.py', '.js', '.mjs', '.cjs', '.json', '.yaml', '.yml',
    '.txt', '.md', '.ini', '.cfg', '.toml', '.conf')
# 只扫可能含路径的地方：全树扫描会把 10 万个 node_modules 文件也枚举一遍，纯浪费时间。
# node_modules 里的第三方包不会写死 D:\Fairy；apps/ 下的 tts_infer.yaml 用的是相对路径
# （已核实），所以也不需要动。
$scanRoots = @(
    $Target,
    (Join-Path $Target 'chat'),
    (Join-Path $Target 'tools'),
    (Join-Path $Target 'SnowLuma\config'),
    (Join-Path $Target 'qq-bridge'),
    (Join-Path $Target 'dsh-home\.agent-presets'),
    (Join-Path $Target 'dsh-home\plugins'),
    (Join-Path $Target 'fairy-dsh')
)
$scanFiles = New-Object System.Collections.Generic.List[string]
foreach ($r in $scanRoots) {
    if (-not (Test-Path -LiteralPath $r)) { continue }
    if ((Get-Item -LiteralPath $r).PSIsContainer) {
        Get-ChildItem -LiteralPath $r -Recurse -Force -File -ErrorAction SilentlyContinue |
            ForEach-Object { $scanFiles.Add($_.FullName) }
    } else {
        $scanFiles.Add((Get-Item -LiteralPath $r).FullName)
    }
}

$changed = 0
$touched = 0
foreach ($fp in $scanFiles) {
    if ($fp.IndexOf('\node_modules\', [StringComparison]::OrdinalIgnoreCase) -ge 0) { continue }
    if ($fp.IndexOf('\apps\', [StringComparison]::OrdinalIgnoreCase) -ge 0) { continue }
    if ($fp.IndexOf('\_trash', [StringComparison]::OrdinalIgnoreCase) -ge 0) { continue }
    if ($fp -eq $PSCommandPath) { continue }
    $ext = [IO.Path]::GetExtension($fp).ToLower()
    if ($txtExt -notcontains $ext) { continue }
    try {
        if ((Get-Item -LiteralPath $fp).Length -gt 3MB) { continue }
    } catch { continue }

    $enc = if ($gbkExt -contains $ext) { [Text.Encoding]::GetEncoding(936) } else { New-Object Text.UTF8Encoding($false) }
    $text = $null
    try { $text = $enc.GetString([IO.File]::ReadAllBytes($fp)) } catch { continue }
    $new = $text
    foreach ($r in $rules) { if ($new.Contains($r.from)) { $new = $new.Replace($r.from, $r.to) } }
    if ($new -ne $text) {
        [IO.File]::WriteAllBytes($fp, $enc.GetBytes($new))
        $changed++
    }
    $touched++
}
Ok ("扫描 {0:N0} 个文本文件，改写 {1:N0} 个" -f $touched, $changed)

# ---------------------------------------------------------------- 6. 修链接/补空目录
Step 6 7 '重建目录链接与运行时目录'

# dsh-home\profiles\web 在原机是指向 fairy-dsh\profiles\web 的 junction，
# 打包时按链接处理（内容只存一份），这里必须重建，否则 DSH 找不到 web profile。
$linkPath = Join-Path $Target 'dsh-home\profiles\web'
$linkTarget = Join-Path $Target 'fairy-dsh\profiles\web'
if (Test-Path -LiteralPath $linkTarget) {
    if (Test-Path -LiteralPath $linkPath) {
        $item = Get-Item -LiteralPath $linkPath -Force
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            # 真实目录（老安装残留）→ 让位给链接
            Warn 'dsh-home\profiles\web 是实体目录，替换为指向 fairy-dsh\profiles\web 的链接'
            Remove-Item -LiteralPath $linkPath -Recurse -Force
        }
    }
    if (-not (Test-Path -LiteralPath $linkPath)) {
        try {
            New-Item -ItemType Junction -Path $linkPath -Target $linkTarget -ErrorAction Stop | Out-Null
            Ok 'dsh-home\profiles\web -> fairy-dsh\profiles\web (junction 已建立)'
        } catch {
            Warn "创建 junction 失败：$($_.Exception.Message)；改为复制一份（多占 199MB）"
            Copy-Item -LiteralPath $linkTarget -Destination $linkPath -Recurse -Force
        }
    } else {
        Ok 'dsh-home\profiles\web 链接已存在'
    }
} else {
    Warn 'packages 目录缺失：fairy-dsh\profiles\web 不存在'
}

# 补运行时需要的空目录 + 清掉可能混进来的密钥残留
$emptyDirs = @('qq-bridge\state', 'qq-bridge\logs', 'dsh-home\browser-dock', 'logs')
foreach ($d in $emptyDirs) {
    $p = Join-Path $Target $d
    if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}
$secrets = @('dsh-home\.credentials.yaml', 'dsh-home\.anonymous-user-id',
    'dsh-home\balance-meter-daily.json', 'dsh-home\browser-dock\control-token')
foreach ($s in $secrets) {
    $p = Join-Path $Target $s
    if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p -Force; Warn "已移除不应随包的文件: $s" }
}

# qq-bridge: 从脱敏模板生成 config.json
$ex = Join-Path $Target 'qq-bridge\config.example.json'
$cf = Join-Path $Target 'qq-bridge\config.json'
if ((Test-Path -LiteralPath $ex) -and -not (Test-Path -LiteralPath $cf)) {
    Copy-Item -LiteralPath $ex -Destination $cf -Force
    Ok 'qq-bridge\config.json 已由脱敏模板生成（需填 QQ 号与 OneBot token）'
}

# ---------------------------------------------------------------- 7. 校验
Step 7 7 '校验关键文件'

$must = @(
    'start_all.bat', 'stop_all.bat', 'start_dsh.bat', 'start_qq_bridge.bat',
    'restart_tts.bat', 'restart_snowluma.bat',
    'console\tts_ctl.py', 'console\snowluma_ctl.py', 'console\FairyConsole.py',
    'chat\index.html',
    # 整合模式（黑窗并入）：无黑窗启动器 + 4 个子服务包装脚本
    'Fairy总控台.vbs',
    'run\svc_tts.bat', 'run\svc_dsh.bat', 'run\svc_luma.bat', 'run\svc_bridge.bat',
    'runtime\node\node.exe',
    'runtime\node\node_modules\@deepseek-ai\dsh\lib\bin.js',
    'reference\ref6.wav', 'reference\transcripts.json',
    'SnowLuma\launcher.bat', 'SnowLuma\node.exe',
    'qq-bridge\src\bridge.js', 'qq-bridge\config.json',
    'dsh-home\settings.yaml', 'dsh-home\profiles\node_modules',
    'fairy-dsh\profiles\web\node_modules',
    'fairy-dsh\fairy-visual\dsh-fairy-visual',
    'apps\GPT-SoVITS-v2pro-20250604-nvidia50\api_v2.py',
    'apps\GPT-SoVITS-v2pro-20250604-nvidia50\runtime\python.exe',
    'apps\GPT-SoVITS-v2pro-20250604-nvidia50\GPT_weights_v2\Fairy-e10.ckpt',
    'apps\GPT-SoVITS-v2pro-20250604-nvidia50\SoVITS_weights_v2\Fairy_e10_s870.pth'
)
$miss = @()
foreach ($m in $must) {
    $p = Join-Path $Target $m
    if (-not (Test-Path -LiteralPath $p)) { $miss += $m }
}
if ($miss.Count -gt 0) {
    Warn ("缺少 {0} 项：" -f $miss.Count)
    foreach ($m in $miss) { Say ("         - " + $m) 'Red' }
    if ($miss -contains 'apps\GPT-SoVITS-v2pro-20250604-nvidia50\runtime\python.exe') {
        Say '         （语音运行时缺失 → 数据包没解压成功，语音会不出声）' 'Yellow'
    }
} else {
    Ok '全部关键文件就位'
}

# 语音权重是否与 tts_infer.yaml 对得上
$yaml = Join-Path $Target 'apps\GPT-SoVITS-v2pro-20250604-nvidia50\GPT_SoVITS\configs\tts_infer.yaml'
if (Test-Path -LiteralPath $yaml) {
    $yl = Select-String -LiteralPath $yaml -Pattern 'D:\\Fairy|D:/Fairy' -ErrorAction SilentlyContinue
    if ($yl) {
        Warn "tts_infer.yaml 里还有旧路径（$($yl.Count) 处）——语音会加载失败，请检查"
    } else {
        Ok 'tts_infer.yaml 权重路径正常'
    }
}

# ---------------------------------------------------------------- 快捷方式
if (-not $NoShortcut) {
    try {
        $desktop = [Environment]::GetFolderPath('Desktop')
        $lnk = Join-Path $desktop 'Fairy 桌宠.lnk'
        $sh = New-Object -ComObject WScript.Shell
        $s = $sh.CreateShortcut($lnk)
        $s.TargetPath = Join-Path $Target 'Fairy总控台.vbs'
        $s.WorkingDirectory = $Target
        $s.IconLocation = "$env:SystemRoot\System32\shell32.dll,137"
        $s.Description = 'Fairy 总控台（整合模式：全部服务收在一个窗口，无黑窗）'
        $s.Save()
        Ok "桌面快捷方式已创建: $lnk"
    } catch {
        Warn "创建快捷方式失败（不影响使用）：$($_.Exception.Message)"
        Say "         可手动右键 $Target\Fairy总控台.vbs → 发送到 → 桌面快捷方式" 'Yellow'
    }
}

# ---------------------------------------------------------------- 收尾
Say ''
Say '============================================================' 'Green'
Say '  安装完成' 'Green'
Say '============================================================' 'Green'
Say ("  安装目录: {0}" -f $Target)
Say ''
Say '  接下来必须做三件事，否则桌宠不会说话 / QQ 不会回消息：' 'White'
Say ''
Say '  1) 填 DeepSeek API Key'
Say ("     双击 {0}\Fairy总控台.vbs（推荐，无黑窗）→ 点「▶ 全部启动」" -f $Target)
Say '     然后在总控台里点桌宠那行的「打开」，浏览器会打开 http://127.0.0.1:3080'
Say '     在页面里填入 Key（也可点"稍后配置"）。Key 只存在本机。'
Say ''
Say '     · 总控台 = 一个窗口管住 4 个服务，服务日志就在「运行输出」页里，'
Say '       不会再有 4 个黑色 cmd 窗口。想看原始控制台：取消勾选「整合模式」再启动。'
Say '     · 不想用总控台也可以照旧双击 start_all.bat（会开 4 个黑窗口）。'
Say ''
Say '  2) 首次合成需预热约 60 秒（模型加载），之后每句约 2 秒'
Say '     若不出声：双击 restart_tts.bat'
Say ''
Say '  3) QQ 分身（可选）'
Say ("     双击 {0}\restart_snowluma.bat 扫码登录 QQ" -f $Target)
Say '     扫码后，把 SnowLuma 里的 OneBot accessToken 填进 qq-bridge\config.json 的'
Say '     snowluma.accessToken，并把 ownerQQ 改成你自己的 QQ 号；'
Say '     然后双击 start_qq_bridge.bat，控制台 http://127.0.0.1:3100'
Say ''
Say '  端口一览: 3080 桌宠 / 9880 语音 / 3000+3001+5099 SnowLuma / 3100 QQ 桥接'
Say ("  停止全部: 双击 {0}\stop_all.bat" -f $Target)
Say ''
Say ("  安装日志: {0}" -f $LogFile)
Log 'install done'

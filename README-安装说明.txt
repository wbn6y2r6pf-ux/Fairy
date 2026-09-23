================================================================
  Fairy 语音桌宠  ——  一键安装包  v1.0
================================================================

这个包装了什么
----------------------------------------------------------------
Fairy 是基于 DeepSeek Harness (DSH) 的本地语音桌宠：浏览器里一个
Fairy 形象 + 本地 GPT-SoVITS 语音合成，还能接 QQ 当分身聊天。

整包分两个 zip，配合使用：

  1)  Fairy-Installer-v1.0.zip     ← 你正在看的这个
      程序文件（约 0.85GB）：桌宠界面、语音控制脚本、QQ 桥接、
      SnowLuma 客户端、Fairy 角色与视觉插件、便携 Node 运行时、
      以及参考音频(reference/)

  2)  Fairy-Data-v1.0.zip          ← 数据包（约 10.6GB）
      GPT-SoVITS v2Pro nvidia50 完整运行时（含 torch cu128、
      便携 Python 和 Fairy 音色权重）。没有它，桌宠能开但不会说话。

注意：只有 30 系以后（含 50 系）的 NVIDIA 显卡才能用这个数据包
（内部是 torch 2.7.0+cu128，为 sm_120 编译）。老显卡需要用普通
版 GPT-SoVITS 整合包替换 apps/ 下的目录。


怎么装
----------------------------------------------------------------
1. 把两个 zip 都解压，并且让它们待在**同一个文件夹**里：

     D:\Fairy-Download\
       install.ps1
       payload\
       安装 Fairy.bat
       Fairy-Data-v1.0.zip
       ...

2. 双击「安装 Fairy.bat」。

3. 按提示确认安装目录（默认 D:\Fairy，直接回车即可）。

4. 等 10-25 分钟。数据包解压最耗时。

安装器只用 Windows 自带能力（PowerShell 5.1 + 系统 tar.exe），
目标电脑**不需要**预装 Python、Node.js、7-Zip，也不需要管理员权限。


装完要做三件事
----------------------------------------------------------------
1) 填 DeepSeek API Key
   双击 <安装目录>\Fairy总控台.vbs（推荐，全程无黑窗）→ 点「▶ 全部启动」，
   再点桌宠那行的「打开」，浏览器会打开 http://127.0.0.1:3080，
   在页面里填入 Key。Key 只保存在本机 dsh-home 里，不会外传。

   为什么推荐总控台：
     · 一个窗口管住 4 个服务（桌宠/语音/QQ 客户端/桥接），能单独启停、重启、一键修复
     · 服务原本写在黑窗口里的日志，实时显示在「运行输出」页 —— 不再有 4 个黑色 cmd 窗口
     · 想看原始控制台：取消勾选顶栏「整合模式」再启动即可（会各自开最小化窗口）
   习惯老方式也可以照旧双击 start_all.bat。

2) 等语音预热
   首次合成约 60 秒（模型加载），之后每句约 2 秒。
   不出声就双击 restart_tts.bat。

3) QQ 分身（可选，不用 QQ 可以跳过）
   - 双击 restart_snowluma.bat，扫码登录 QQ
   - 把 SnowLuma 的 OneBot accessToken 填进
     qq-bridge\config.json 的 snowluma.accessToken
   - 把同文件的 ownerQQ 改成你自己的 QQ 号
     （allow.private 留空时只有 ownerQQ 能私聊机器人）
   - 双击 start_qq_bridge.bat，控制台 http://127.0.0.1:3100


端口与常用操作
----------------------------------------------------------------
  3080   桌宠界面 (DSH)
  9880   语音后端 (GPT-SoVITS api_v2)
  3000    SnowLuma HTTP   ┐
  3001    SnowLuma WS     ├ 同一个进程
  5099    SnowLuma WebUI  ┘
  3100    QQ 桥接控制台

  Fairy总控台.vbs        ★ 推荐入口：无黑窗启动图形总控台
                         （内部用 pythonw，双击后点「▶ 全部启动」，
                           4 个服务的日志都在「运行输出」页，无黑窗口）
  start_all.bat        启动全部（桌宠+语音+SnowLuma+桥接）——会在开 4 个黑窗口
  stop_all.bat         停止全部（含桥接守护进程回查）
  restart_tts.bat      语音后端出问题时用
  restart_snowluma.bat SnowLuma 报 mojo 管道超时/加载不成功时用
  Fairy控制台.bat      图形总控台（等价的传统启动方式，会闪一下批处理窗口）


安装器做了什么（便于排障）
----------------------------------------------------------------
1. 解压数据包到安装目录
2. 铺程序文件到安装目录
3. 重写所有写死的绝对路径 —— 原开发机是 D:\Fairy 与
   C:\Users\<用户>\.workbuddy\binaries\node\...，全部改成你的安装目录；
   bat 按 GBK 改写、其它文本按 UTF-8 改写
4. 重建 dsh-home\profiles\web 指向 fairy-dsh\profiles\web 的目录链接
   （原机就是链接，内容只存一份；这一步漏了 DSH 会找不到 web profile）
5. 校验关键文件是否就位
6. 在桌面创建「Fairy 桌宠」快捷方式（指向 Fairy总控台.vbs）


没有随包的个人数据
----------------------------------------------------------------
出于隐私，下列内容**刻意不打包**，新机需要重新配置：

  dsh-home\.credentials.yaml      DeepSeek API Key
  dsh-home\.anonymous-user-id     匿名标识
  dsh-home\balance-meter-daily.json  用量计费
  dsh-home\browser-dock\control-token
  dsh-home\sessions\              对话历史
  dsh-home\storages\              会话缓存（含旧绝对路径）
  qq-bridge\state\                QQ 登录态、社交状态缓存
  qq-bridge\config.json           已脱敏为 config.example.json
                                  （QQ 号、OneBot token、灰名单已清空）

保留的是角色与调优成果：Fairy 人格预设(.agent-presets)、视觉与语音
插件的全部参数、qq-bridge 的社交/回复/贴纸等上百项调校值、
SnowLuma 与 qq-bridge 的运行配置。所以新机只需填 Key + 扫码，
Fairy 的性格和说话方式不用重调。


常见问题
----------------------------------------------------------------
Q: 提示"磁盘空间不足"
   完整安装约 13GB。数据包和安装目录最好在同一个盘。

Q: 报错说 tar.exe 解压失败
   用资源管理器右键数据包 → 全部解压缩到安装目录，然后重新双击
   「安装 Fairy.bat」（它会跳过已存在的文件）。

Q: 桌宠能开但没声音
   ① 数据包没装（检查 <安装目录>\apps\GPT-SoVITS-v2pro-20250604-nvidia50\
      runtime\python.exe 是否存在）
   ② 没填 DeepSeek API Key
   ③ 语音后端挂了 → restart_tts.bat

Q: 想卸载
   双击 stop_all.bat 停服务，然后直接删掉安装目录即可
   （默认没有往系统里写任何东西，只多一个桌面快捷方式）。

Q: 想装到别的盘
   安装时直接输入路径，例如 E:\Fairy。所有路径会按新位置重写。

================================================================

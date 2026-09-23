# Fairy

Fairy 桌宠的 Windows 一键安装整合包：包含安装脚本（`INSTALL.bat` / `install.ps1`）、安装说明与组件清单（`manifest.json`）。

## 来源声明 / Attribution

本项目基于以下开源项目修改和打包：

> **[Fairy-DSH](https://github.com/Chengzhibense/Fairy-DSH)** — Fairy personality and visual plugin suite for DeepSeek Harness
> 作者：橙橙子（[Chengzhibense](https://github.com/Chengzhibense)）

- 原项目以 **Apache License 2.0** 发布，本项目遵循同一许可证进行二次分发。
- 本仓库为**打包分发版**，对原项目做了以下修改：将原插件套件整合为 Windows 一键安装器（`.bat` / `.ps1` 安装脚本 + `manifest.json` 组件清单），未修改原插件核心逻辑。
- 原项目的许可证全文与声明见原仓库 [LICENSE](https://github.com/Chengzhibense/Fairy-DSH/blob/main/LICENSE) 与 [NOTICE](https://github.com/Chengzhibense/Fairy-DSH/blob/main/NOTICE)。

## 许可边界

- 本仓库中的安装脚本与说明文件按 **Apache License 2.0** 发布。
- 原始 Fairy-DSH 插件代码的权利与许可边界以原仓库为准。
- 《绝区零》相关文本素材、角色资料、官方素材，TTS 模型、私有语料及个人数据**不包含在本仓库中**，不随本仓库分发。
- 大体积组件（`Fairy-Data-v1.0.zip`、`Fairy-Installer-v1.0.zip`、`apps/`、`payload/`）仅在本地分发，不纳入本仓库；完整性校验见 `SHA256SUMS.txt`。

## 安装

**本仓库只包含安装脚本与文档，不包含程序本体和数据，单独克隆/下载本仓库无法完成安装。**

完整安装需要获取全量安装包，有两种形态：

1. **一键安装器（推荐）**：`Fairy-Setup-v1.0.exe` + `Fairy-Setup-v1.0-1.bin`（约 13GB），两个文件放同一文件夹后双击 exe，按组件勾选安装（桌宠 / GPT-SoVITS 语音 / SnowLuma / QQ 桥接）。
2. **散装整合包**：`Fairy-Installer-v1.0.zip`（解压后含 `payload/` 目录）+ `Fairy-Data-v1.0.zip`（语音数据），全部解压/放置到同一目录后，双击 `安装 Fairy.bat`。

全量包下载地址：*（网盘 / Release 链接待补充）*

> 仅当 `安装 Fairy.bat` 与 `payload/` 目录、`Fairy-Data-*.zip` 数据包在同一目录时才能运行；否则会提示"安装包不完整"。

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

运行 `安装 Fairy.bat`（或 `INSTALL.bat`）开始安装，详见 `README-安装说明.txt`。

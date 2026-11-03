# M4-TOTK Cloud · iPad-only developer branch

这是 **M4-TOTK v0.6** 的 GitHub 独立分支云端试编译入口，**不是**可安装或可游玩的《王国之泪》IPA。

## 现在能做什么
- \`m4-totk-cloud/ios/\` 提供 M4 中文设置面板和预设 Swift 源码。
- \`m4-totk-cloud/demo/\` 提供不含游戏资源的 XcodeGen 试编译 App。
- 仓库根目录两个 M4 工作流用于 GitHub Actions：Linux 免费优先预检、手动 macOS iOS 界面编译。
- 不上传游戏 ROM、\`prod.keys\`、P12、激活码和卖家的 IPA。

## 重要
本分支从现有的 \`desktop-tutorial/main\` 派生，**不会修改 main**，是临时独立位置。要把这套开发内容放进真正独立的仓库，需要先在 GitHub 建立新仓库再迁移。

这里是可直接审阅的 **云端 UI 试编译子集**。之前制作的完整 v0.6 ZIP 包仍然包含更多诊断、集成补丁和单元测试；此仓库分支不代表已经全部导入或验证，也不代表真实游戏程序通过 Xcode 编译。

## 如何使用
1. Safari 打开此分支，在 \`Actions\` 查看 Ubuntu 预检工作流。只有 GitHub 在此分支启用工作流时才会产生运行记录。
2. macOS 编译工作流只允许手动触发，以免意外使用付费/配额分钟。GitHub 可能要求先把工作流放到默认分支才允许从 Actions 页面点击「Run workflow」。
3. iOS 设置面板试编译通过也 **不等于** 游戏运行核心已经编译，更不证明 120 FPS。

基于公开项目 https://github.com/ly05010419/MacNativeGames 的接口设计，未包含其游戏资源。
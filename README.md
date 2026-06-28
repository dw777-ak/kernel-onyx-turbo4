# Redmi Turbo 4 Pro 平衡续航/游戏稳定内核构建

这个仓库提供一个可直接在 GitHub Actions 中编译内核的最小模板，目标是为 Redmi Turbo 4 Pro 生成一个偏向“日常省电、游戏稳帧、调度更顺滑”的内核构建。

## 特色
- 使用 GitHub Actions 自动拉取内核源码并编译
- 支持切换目标内核源码、分支和 defconfig
- 内置一份偏向省电与游戏稳定性的配置文件

## 使用方法
1. 将仓库推送到 GitHub
2. 打开 Actions 页面，运行“Build Balanced Redmi Turbo 4 Pro Kernel”工作流
3. 选择需要的内核源码仓库、分支和 defconfig
4. 下载构建产物中的内核镜像

## 说明
- 默认使用 Linux 源码仓库的主分支，适合试验和适配
- 你也可以把构建脚本改成实际的 Redmi Turbo 4 Pro 内核源码仓库
- 如果你有更精确的设备树、补丁或配置，可以把它们放进 kernel-config 或 scripts 中继续扩展

## 目录说明
- .github/workflows/build-kernel.yml：GitHub Actions 工作流
- scripts/build-kernel.sh：编译脚本
- kernel-config/redmi-turbo4-pro.config：平衡配置文件

# Redmi Turbo 4 Pro 平衡续航/游戏稳定内核构建

这个仓库提供一个可直接在 GitHub Actions 中编译内核的最小模板，目标是为 Redmi Turbo 4 Pro 生成一个偏向“日常省电、游戏稳帧、调度更顺滑”的内核构建。

## 特色
- 使用 GitHub Actions 自动拉取内核源码并编译
- 支持同时指定内核源码仓库和设备树仓库
- 内置一份偏向省电与游戏稳定性的配置文件
- 针对低功耗调度、频率调度和游戏场景低延迟做了基础调优

## 使用方法
1. 将仓库推送到 GitHub
2. 打开 Actions 页面，运行“Build Balanced Redmi Turbo 4 Pro Kernel”工作流
3. 在输入项中填入真实的内核源码仓库和设备树仓库地址
4. 选择目标分支、defconfig 和交叉编译器
5. 下载构建产物中的内核镜像

## 说明
- 默认仍使用 Linux 主线源码作为可运行模板，便于先验证工作流
- 如果你有真实的 Redmi Turbo 4 Pro 内核源码或设备树仓库，把对应 URL 填入工作流输入即可
- 脚本会自动把设备树仓库中的 DTS 资源挂载到构建目录中，便于后续做更贴近机型的编译

## 目录说明
- .github/workflows/build-kernel.yml：GitHub Actions 工作流
- scripts/build-kernel.sh：编译脚本
- kernel-config/redmi-turbo4-pro.config：平衡配置文件

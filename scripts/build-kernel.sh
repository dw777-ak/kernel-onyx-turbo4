#!/usr/bin/env bash
set -euo pipefail

KERNEL_REPO="${1:-https://github.com/torvalds/linux.git}"
KERNEL_REF="${2:-master}"
WORKDIR="${3:-$RUNNER_TEMP/kernel-src}"
OUT_DIR="${4:-$WORKDIR/out}"
DEFCONFIG="${5:-defconfig}"
ARCH="${6:-arm64}"
CROSS_COMPILE="${7:-aarch64-linux-gnu-}"
USE_CUSTOM_CONFIG="${8:-true}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CUSTOM_CONFIG="$ROOT_DIR/kernel-config/redmi-turbo4-pro.config"

mkdir -p "$WORKDIR"

if [ ! -d "$WORKDIR/.git" ]; then
  git clone --depth 1 --branch "$KERNEL_REF" "$KERNEL_REPO" "$WORKDIR"
else
  git -C "$WORKDIR" fetch --depth 1 origin "$KERNEL_REF" >/dev/null 2>&1 || true
  git -C "$WORKDIR" checkout -f FETCH_HEAD >/dev/null 2>&1 || true
fi

cd "$WORKDIR"
mkdir -p "$OUT_DIR"

export ARCH
export CROSS_COMPILE
export CLANG_TRIPLE="${CLANG_TRIPLE:-aarch64-linux-gnu}"
export CC="${CC:-${CROSS_COMPILE}gcc}"
export LD="${LD:-${CROSS_COMPILE}ld}"
export KBUILD_BUILD_USER="${KBUILD_BUILD_USER:-github-actions}"
export KBUILD_BUILD_HOST="${KBUILD_BUILD_HOST:-github-actions}"

make O="$OUT_DIR" "$DEFCONFIG"

if [ "$USE_CUSTOM_CONFIG" = "true" ] && [ -f "$CUSTOM_CONFIG" ]; then
  if [ -f "$OUT_DIR/.config" ]; then
    scripts/kconfig/merge_config.sh -m -O "$OUT_DIR" "$OUT_DIR/.config" "$CUSTOM_CONFIG"
    make O="$OUT_DIR" olddefconfig
  fi
fi

make O="$OUT_DIR" -j"$(nproc)" Image.gz

echo "Kernel build completed: $OUT_DIR/arch/$ARCH/boot/Image.gz"

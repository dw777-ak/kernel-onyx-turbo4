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
DEVICE_TREE_REPO="${9:-}"
DEVICE_TREE_REF="${10:-master}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CUSTOM_CONFIG="$ROOT_DIR/kernel-config/redmi-turbo4-pro.config"

clone_or_update_repo() {
  local repo="$1"
  local ref="$2"
  local target="$3"

  if [ -z "$repo" ]; then
    return 0
  fi

  if [ ! -d "$target/.git" ]; then
    git clone --depth 1 --branch "$ref" "$repo" "$target"
  else
    git -C "$target" fetch --depth 1 origin "$ref" >/dev/null 2>&1 || true
    git -C "$target" checkout -f FETCH_HEAD >/dev/null 2>&1 || true
  fi
}

mkdir -p "$WORKDIR"
clone_or_update_repo "$KERNEL_REPO" "$KERNEL_REF" "$WORKDIR"

cd "$WORKDIR"
mkdir -p "$OUT_DIR"

if [ -n "$DEVICE_TREE_REPO" ]; then
  DEVICE_TREE_DIR="$WORKDIR/device-tree"
  clone_or_update_repo "$DEVICE_TREE_REPO" "$DEVICE_TREE_REF" "$DEVICE_TREE_DIR"
  if [ -d "$DEVICE_TREE_DIR/arch/arm64/boot/dts" ]; then
    mkdir -p "$WORKDIR/arch/arm64/boot/dts/vendor"
    cp -a "$DEVICE_TREE_DIR/arch/arm64/boot/dts/." "$WORKDIR/arch/arm64/boot/dts/vendor/" 2>/dev/null || true
  fi
fi

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

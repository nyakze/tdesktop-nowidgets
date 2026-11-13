#!/usr/bin/env bash
# Сборка форка tdesktop-nowidgets (Linux, docker-окружение апстрима).
#
# Обязательные креды (НЕ коммитить в репозиторий!):
#   ~/.config/tdesktop-fork/api.conf:
#     export TDESKTOP_API_ID=1234567
#     export TDESKTOP_API_HASH=0123456789abcdef0123456789abcdef
#   либо переменные окружения TDESKTOP_API_ID / TDESKTOP_API_HASH.
#
# Форк всегда собирается с DESKTOP_APP_DISABLE_AUTOUPDATE=ON: официальный
# апдейтер подменяет бинарник на официальный (с QuickJS) независимо от api_id.
set -euo pipefail

cd "$(dirname "$0")"

CONF="${HOME}/.config/tdesktop-fork/api.conf"
if [[ -f "$CONF" ]]; then
    # Credentials must not be readable by other local users.
    perms="$(stat -c %a "$CONF")"
    if [[ "$perms" != "600" && "$perms" != "400" ]]; then
        echo "ERROR: $CONF has mode $perms (world/group readable)."
        echo "Run: chmod 600 $CONF"
        exit 1
    fi
    # shellcheck disable=SC1090
    source "$CONF"
fi

: "${TDESKTOP_API_ID:?Set TDESKTOP_API_ID (see ~/.config/tdesktop-fork/api.conf)}"
: "${TDESKTOP_API_HASH:?Set TDESKTOP_API_HASH (see ~/.config/tdesktop-fork/api.conf)}"

echo "==> Verifying the nowidgets patch survived rebases..."
./tools/verify-nowidgets.sh

if [[ ! -d Telegram/lib_base ]]; then
    echo "==> Initializing submodules (first run, several GB)..."
    git submodule update --init --recursive
fi

if ! docker image inspect tdesktop:centos_env >/dev/null 2>&1; then
    echo "==> Building the tdesktop:centos_env docker image (first run)..."
    echo "    (requires poetry + docker; see docs/building-linux.md)"
    pushd Telegram/build/docker/centos_env >/dev/null
    poetry install
    poetry run gen_dockerfile | DOCKER_BUILDKIT=1 docker build -t tdesktop:centos_env -
    popd >/dev/null
fi

echo "==> Building: Release, auto-update DISABLED, widgets non-executing..."
docker run --rm -it \
    -u "$(id -u)" \
    -v "$PWD:/usr/src/tdesktop" \
    tdesktop:centos_env \
    /usr/src/tdesktop/Telegram/build/docker/centos_env/build.sh \
    -D TDESKTOP_API_ID="$TDESKTOP_API_ID" \
    -D TDESKTOP_API_HASH="$TDESKTOP_API_HASH" \
    -D DESKTOP_APP_DISABLE_AUTOUPDATE=ON

echo "==> Done. Binary: out/Telegram"
echo "==> Post-build smoke test: send a widget from a test bot -> it must render"
echo "    as an 'unsupported message' card, with no JS execution."

#!/usr/bin/env bash
# Статические проверки, что патч «nowidgets» на месте.
# Запускать после каждого ребейза на upstream и перед каждой сборкой.
set -euo pipefail

cd "$(dirname "$0")/.."
SRC=Telegram/SourceFiles
fail=0

echo "==> 1. WidgetMedia::createView() must not construct HtmlWidget"
if grep -n "make_unique<HistoryView::HtmlWidget>" "$SRC/tgw/tgw_media.cpp"; then
    echo "FAIL: HtmlWidget construction is back in tgw_media.cpp"
    fail=1
fi

echo "==> 2. createView() must return UnsupportedWidget"
if ! grep -q "return std::make_unique<HistoryView::UnsupportedWidget>(message);" "$SRC/tgw/tgw_media.cpp"; then
    echo "FAIL: the nowidgets fallback in createView() is missing"
    fail=1
fi

echo "==> 3. No other HtmlWidget construction sites anywhere"
if grep -rn "make_unique<HistoryView::HtmlWidget>\|new HistoryView::HtmlWidget" "$SRC" --include="*.cpp" | grep -v "history_view_html_widget"; then
    echo "FAIL: a new HtmlWidget construction site appeared (upstream change?)"
    fail=1
fi

echo "==> 4. Tgw::Runtime construction only in history_view_html_widget.*"
if grep -rln "make_unique<Tgw::Runtime>" "$SRC" --include="*.cpp" | grep -v "history_view_html_widget"; then
    echo "FAIL: Tgw::Runtime is now constructed elsewhere — review the new call chain"
    fail=1
fi

echo "==> 5. Auto-update must stay disabled in the build script"
if ! grep -q "DESKTOP_APP_DISABLE_AUTOUPDATE=ON" build-fork.sh; then
    echo "FAIL: build-fork.sh lost DESKTOP_APP_DISABLE_AUTOUPDATE=ON"
    fail=1
fi

if [[ $fail -ne 0 ]]; then
    echo
    echo "PATCH CHECK FAILED — see docs/fork-nowidgets.md"
    exit 1
fi
echo
echo "All nowidgets checks passed."

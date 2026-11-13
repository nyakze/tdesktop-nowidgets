# tdesktop-nowidgets

Fork of [telegramdesktop/tdesktop](https://github.com/telegramdesktop/tdesktop)
where **message widgets never execute JavaScript**.

Telegram widgets are HTML + JS running in an embedded QuickJS sandbox. Public
exploits achieved arbitrary code execution on **viewing a widget message alone**
(desktop 7.4.1 / 7.4.2, fixed in 7.4.3), QuickJS-ng keeps receiving memory-safety
bugs, and widgets cannot be disabled in settings. This fork removes the whole
class of attacks with a minimal one-file patch.

**What the patch does:** `Tgw::WidgetMedia::createView()` never instantiates
`HistoryView::HtmlWidget` (the only construction site of the QuickJS-backed
`Tgw::Runtime`); widget messages render as an "unsupported message" card instead.

**Build note:** the fork is always built with `DESKTOP_APP_DISABLE_AUTOUPDATE=ON`,
because the official updater replaces the binary with the official build
(signature check is independent of api_id).

Details, build instructions and maintenance duties: **[docs/fork-nowidgets.md](docs/fork-nowidgets.md)**.
Patch verification after every rebase: `tools/verify-nowidgets.sh`.

Not affiliated with Telegram. Upstream is GPLv3 (OpenSSL exception); this fork
is distributed under the same terms. Do not use Telegram's name or logo.

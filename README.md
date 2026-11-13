# tdesktop-nowidgets

**NoWidgetGram** — an unofficial fork of [Telegram Desktop][tdesktop] with JavaScript
execution disabled in message widgets.

Not affiliated with Telegram. Based on the GPLv3 (OpenSSL exception) sources of the official client.

---

## Why this fork exists

Telegram Desktop recently gained **widgets** — HTML + JavaScript mini-apps embedded in
messages, executed in a bundled [QuickJS][quickjs] sandbox inside the client.

The feature is moving quickly: known exploits achieved code execution on viewing a
message with a widget in desktop 7.4.1 / 7.4.2 (those vectors were fixed in 7.4.3), and
the QuickJS-ng engine continues to receive memory-safety fixes upstream. At the moment
there is no way to disable widgets in the client settings.

For my own use I currently consider this attack surface an unnecessary risk, so this
fork removes it with a minimal patch: widget messages render as an "unsupported
message" card, and the JavaScript runtime is never instantiated. Everything else —
including all upstream fixes and features — is stock.

If the official client gains a built-in control over widgets (for example, loading them
on click, or a settings toggle), this fork would no longer be necessary.

## Download

Prebuilt binaries are on the [Releases][releases] page:

* `NoWidgetGram-linux` — Linux (x86-64)
* `NoWidgetGram-windows` — Windows (x64)
* `NoWidgetGram-macos` — macOS

The application is branded **NoWidgetGram** (own name and icon) and keeps its profile
in the `nwgram` working directory, separately from official Telegram Desktop.

## Builds

* CI builds **Release** binaries for **Linux, Windows (x64) and macOS** on every push —
  see the [Actions][actions] page (artifacts are kept 30 days).
* Builds use `DESKTOP_APP_DISABLE_AUTOUPDATE=ON`, since the official updater would
  replace this fork with the official binary. There is no auto-update channel yet —
  watch the repository to hear about new releases.
* API credentials are **not** included: building requires your own `api_id`/`api_hash`
  ([how to obtain][api_credentials]), passed via `TDESKTOP_API_ID`/`TDESKTOP_API_HASH`
  repository secrets (CI) or `~/.config/tdesktop-fork/api.conf` (local `build-fork.sh`).

## Verification & maintenance

* `tools/verify-nowidgets.sh` — static checks that the patch survived rebases.
* `docs/fork-nowidgets.md` — the technical details (where QuickJS is wired in, what
  exactly the patch does, how to maintain the fork).
* The fork is regularly rebased onto upstream `dev`; the patch lives in a single file,
  `Telegram/SourceFiles/tgw/tgw_media.cpp`, and is easy to compare against upstream.

## Disclaimer

* Unofficial. Not affiliated with or endorsed by Telegram. The name "Telegram" is used
  only to refer to the original product; the application itself is branded as
  NoWidgetGram with its own name and icons.
* The patch removes the widget JavaScript execution path only. Other attack surfaces of
  the client remain, as in any messenger — upstream security updates are still required.
* Distributed under the same terms as upstream: GPLv3 with OpenSSL exception.

---

## На русском

**NoWidgetGram** — неофициальный форк Telegram Desktop, в котором **виджеты в сообщениях
не исполняют JavaScript**.

В Telegram Desktop появились виджеты — HTML + JS мини-приложения в сообщениях,
исполняемые в песочнице QuickJS внутри клиента. Фича развивается быстро: известные
эксплойты выполняли код при просмотре сообщения с виджетом в десктопе 7.4.1 / 7.4.2
(эти вектора исправлены в 7.4.3), движок QuickJS-ng продолжает получать
memory-safety исправления, а отключить виджеты в настройках пока нельзя.

Я пока считаю эту поверхность атак для себя ненужным риском, поэтому форк убирает её
минимальным патчем: виджет-сообщения показываются карточкой «unsupported message», а
JS-рантайм не создаётся никогда. Всё остальное, включая исправления безопасности
апстрима, — как в официальном клиенте.

Если в официальном клиенте появится встроенная регулировка виджетов (например,
загрузка по клику или переключатель в настройках), форк станет не нужен.

Сборки (Linux / Windows / macOS) собираются в Actions, автообновление отключено.
Готовые бинарники — на странице [Releases][releases]; приложение называется **NoWidgetGram**
(своё имя и иконка) и хранит профиль в отдельном рабочем каталоге `nwgram`.
Подробнее: `docs/fork-nowidgets.md`. Проверка патча: `tools/verify-nowidgets.sh`.

[tdesktop]: https://github.com/telegramdesktop/tdesktop
[quickjs]: https://github.com/quickjs-ng/quickjs
[actions]: https://github.com/nyakze/tdesktop-nowidgets/actions
[releases]: https://github.com/nyakze/tdesktop-nowidgets/releases
[api_credentials]: https://core.telegram.org/api/obtaining_api_id

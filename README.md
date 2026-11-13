# tdesktop-nowidgets

**Unofficial fork of [Telegram Desktop][tdesktop] where message widgets never execute JavaScript.**

Not affiliated with Telegram. Based on the GPLv3 (OpenSSL exception) sources of the official client.

---

## Why this repository exists

Telegram recently shipped **widgets** — HTML + JavaScript mini-apps embedded directly in
messages, executed in a bundled [QuickJS][quickjs] sandbox inside the client. This is a
powerful feature, and also a brand-new remote attack surface:

* Public exploits achieved **arbitrary code execution on merely viewing a message**
  with a widget (desktop 7.4.1 / 7.4.2; the known vectors were fixed in 7.4.3).
* The QuickJS-ng engine keeps receiving memory-safety bugs (heap overflows, code
  injection) — every one of them is potentially a new "view a message → run code" vector
  until the patched engine reaches users.
* **Widgets cannot be disabled in settings.** The only mitigation is "don't open chats
  with bots you don't trust".
* Telegram's own codebase notes that the JS policy sandbox and memory limits do **not**
  guarantee containment of native engine memory errors.

Compromise means full account takeover, stolen session keys, files and funds — the client
is a high-value target and a message preview should never be able to do this.

This fork removes the whole class of attacks with a minimal one-file patch: widget
messages render as an "unsupported message" card, and the JavaScript runtime is **never
instantiated** — not in background, not on click. Everything else (fixes, features) is
stock upstream.

## What we hope to see in the official client

Until there is a built-in control, this fork exists. We would gladly abandon it if
official Telegram Desktop adds at least one of:

1. **Tap-to-run widgets** — show a "load interactive widget?" card instead of running
   JavaScript automatically on message view (the same pattern as "click to load" for
   large media). This alone turns 0-click RCE into a deliberate user action.
2. **A settings switch** to disable widgets entirely (or per-chat).
3. Ideally: running the widget engine out-of-process, like bot web views already do.

## Builds

* CI builds **Release** binaries for **Linux, Windows (x64) and macOS** on every push —
  see the [Actions][actions] page (artifacts are kept 30 days).
* Builds are made with `DESKTOP_APP_DISABLE_AUTOUPDATE=ON`: the official updater would
  replace this fork with the official binary. There is no auto-update channel yet —
  watch the repository to hear about new releases.
* API credentials are **not** included: building requires your own `api_id`/`api_hash`
  ([how to obtain][api_credentials]), passed via `TDESKTOP_API_ID`/`TDESKTOP_API_HASH`
  repository secrets (CI) or `~/.config/tdesktop-fork/api.conf` (local `build-fork.sh`).

## Verification & maintenance

* `tools/verify-nowidgets.sh` — static checks that the patch survived rebases.
* `docs/fork-nowidgets.md` — the full technical picture (where QuickJS is wired in, what
  exactly the patch does, how to maintain the fork).
* The fork is regularly rebased onto upstream `dev`; when in doubt, compare
  `Telegram/SourceFiles/tgw/tgw_media.cpp` with upstream — the patch lives only there.

## Disclaimer

* Unofficial. Not affiliated with or endorsed by Telegram. Do not use Telegram's name or
  logo for this fork.
* The patch removes the widget JavaScript execution path. Other attack surfaces of the
  client (as in any messenger) remain — **upstream security updates are still required**.
* Distributed under the same terms as upstream: GPLv3 with OpenSSL exception.

---

## На русском

Это **неофициальный форк Telegram Desktop, в котором виджеты в сообщениях не исполняют
JavaScript**. Зачем: виджеты — это HTML + JS в песочнице QuickJS внутри клиента;
публичные эксплойты выполняли произвольный код **при одном лишь просмотре сообщения**
(7.4.1 / 7.4.2, известные вектора исправлены в 7.4.3), движок QuickJS-ng регулярно
получает новые memory-safety баги, а отключить виджеты в настройках нельзя.

Форк снимает весь класс атак минимальным патчем: виджет-сообщения показываются карточкой
«unsupported message», JS-рантайм не создаётся никогда. Сборки (Linux / Windows / macOS)
собираются в Actions, автообновление отключено.

**Чего мы ждём от официального Telegram** (и надеемся, что это появится — тогда форк можно
будет закрыть):

1. **Загрузка виджета по клику** — карточка «запустить интерактивный виджет?» вместо
   автоматического выполнения JS при просмотре сообщения (как «нажмите, чтобы загрузить»
   у больших медиа). Одно это превращает 0-click RCE в осознанное действие пользователя.
2. **Переключатель в настройках** — выключить виджеты полностью или по чатам.
3. В идеале — изоляция движка виджетов в отдельном процессе, как уже сделано для
   веб-приложений ботов.

Подробнее: `docs/fork-nowidgets.md`. Проверка патча: `tools/verify-nowidgets.sh`.

[tdesktop]: https://github.com/telegramdesktop/tdesktop
[quickjs]: https://github.com/quickjs-ng/quickjs
[actions]: https://github.com/nyakze/tdesktop-nowidgets/actions
[api_credentials]: https://core.telegram.org/api/obtaining_api_id

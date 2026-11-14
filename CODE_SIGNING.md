# Code Signing Policy

**Status: code signing is not active yet.** This project is in the process of
setting up code signing via SignPath Foundation. Until the first signed release
is published, all binaries are unsigned — this page describes how signing will
work once it is enabled.

Once signing is active, the following attribution will apply (this is the
wording required by SignPath Foundation terms):

> Free code signing provided by SignPath.io, certificate by SignPath Foundation.

## What is signed

Release artifacts built by this project's CI (GitHub Actions) from this
repository:

* `NoWidgetGram` — Linux binary
* `NoWidgetGram.exe` — Windows binary
* `NoWidgetGram.app` — macOS application bundle

No other binaries are signed with this project's certificate. In particular,
upstream Telegram Desktop binaries are not signed by this project.

## How signing happens

* Binaries are built **only** by the CI release workflow from the public source
  code in this repository. Signing never happens on a developer's local machine.
* Signed artifacts are built from an exact commit; the build workflow is public
  and reproducible (see `.github/workflows/`).
* Every signing request requires **manual approval** by the maintainer before
  the signature is issued.
* Test or unsigned builds are never published as releases.

## Roles

This is a single-maintainer project:

* **Author / committer / reviewer:** the maintainer (GitHub: [nyakze](https://github.com/nyakze)).
  All changes to source code and build scripts are made by the maintainer.
* **Approver (signing requests):** the maintainer.

All team members use multi-factor authentication for GitHub.

## Related policies

* [Privacy policy](PRIVACY.md) — the application collects no user data.
* License: GPLv3 with OpenSSL exception (see `LICENSE` / `LEGAL`).

---

# Политика подписи (рус.)

**Статус: подпись ещё не активна.** Проект настраивает подпись через SignPath
Foundation. Пока первый подписанный релиз не выпущен, все бинарники неподписаны.

После активации подписи будет действовать следующая атрибуция (обязательная
формулировка по условиям SignPath Foundation):

> Бесплатная подпись предоставлена SignPath.io, сертификат — SignPath Foundation.

**Что подписывается:** только релизные артефакты, собранные CI (GitHub Actions)
из исходников этого репозитория (`NoWidgetGram` для Linux, `NoWidgetGram.exe`
для Windows, `NoWidgetGram.app` для macOS).

**Как это работает:** сборка и подпись происходят только в CI из публичных
исходников, каждый запрос подписи проходит ручное одобрение мейнтейнером,
тестовые сборки никогда не публикуются как релизы.

**Роли:** проект с одним мейнтейнером — автор, ревьюер и аппрувер подписей
(аккаунт [nyakze](https://github.com/nyakze)). Используется двухфакторная
аутентификация.

**Приватность:** см. [PRIVACY.md](PRIVACY.md).

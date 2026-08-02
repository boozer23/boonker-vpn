# Boonker VPN iOS

Первый нативный vertical slice на SwiftUI.

Сейчас реализовано:
- server-first экран;
- выбор страны и города;
- Favorites / Recent;
- поиск по стране и городу;
- Best ping;
- connect/disconnect state;
- live-style metrics;
- protection toggles.

Следующий технический слой: `NetworkExtension` + WireGuard adapter, API серверов, авторизация и StoreKit 2.

## Локальная сборка

Из корня проекта запускайте:

```sh
./ios/build.sh
```

Скрипт синхронизирует `outputs/vpn-prototype.html` с ресурсом iOS-приложения, собирает Debug-бандл и проверяет, что HTML действительно попал внутрь `.app`.

Контракт будущего backend находится в `backend/API_CONTRACT.md`.

# Routes (Enhanced)

An enhanced fork of [Routes](https://www.curseforge.com/wow/addons/routes) by Grum and Xinhuan. All credit for the original addon goes to the upstream authors; this fork adds an opt-in visual feature on top.

## What changed

- **Direction arrow overlay for drawn routes.** New per-route toggle, "Arrow Line", in the route's existing "Line Settings" tab. When enabled, a direction arrow is drawn at each route segment's midpoint, pointing the way the route actually travels — useful for routes that are easy to walk backwards by mistake.
  - Implemented as a fully separate overlay texture (the built-in `Interface\Minimap\MinimapArrow`, rotated per-segment via `SetRotation`), not by modifying the line's own texture coordinates. An earlier attempt baked a directional pattern into the line's own sheared texture coordinates directly; that renderer routinely produces UV coordinates far outside the normal `[0,1]` range on long/thin segments (invisible with the original blank line texture, but visibly broken with any directional pattern baked in, especially under minimap rotation) — so the arrow is now a fully independent texture pool, and the line-drawing code itself is completely untouched when the toggle is off.
- **Added: cast-gated node verification and a "Verified Nodes Only" route filter.** GatherMate2's own database has no notion of provenance — an entry added by a real gather and one merged in from a shared/imported dataset are byte-for-byte identical, so routes built from it had no way to tell a confirmed node from one that may not exist on this server at all.
  - New `Modules/NodeVerification.lua` tracks per-coordinate `verified`/`missCount` state in `RoutesDB`, driven off `GatherMate2NodeAdded` — which only fires from a real gathering-spell cast (GatherMate2's own `Collector.lua`), never from its importer, making it the one reliable confirmation signal available. `Plugins/GatherMate2.lua`'s `InsertNode` wrapper now also calls `Routes:MarkNodeVerified` on every `GatherMate2NodeAdded`. Proximity alone is deliberately never used to record a miss — riding past a point proves nothing; a miss is only counted when the player actually starts a gathering-type spell cast (the same spell list GatherMate2's own Collector watches) while within range of an unverified point, and that specific point isn't confirmed within a few seconds. The "Create Route from Data Sources" screen (and "Recreate Route", which shares the same creation code path) gets a new "Verified Nodes Only" toggle that drops any node without `verified == true` from the resulting route.

## Installation

Drop this folder into `Interface/AddOns/Routes`. Enable "Arrow Line" per-route via `/routes` → pick a route → Line Settings.

---

# Routes (улучшенная версия)

Улучшенный форк [Routes](https://www.curseforge.com/wow/addons/routes) авторства Grum и Xinhuan. Вся заслуга за оригинальный аддон принадлежит авторам; этот форк добавляет один необязательный визуальный элемент поверх.

## Что изменено

- **Оверлей-стрелка направления для нарисованных маршрутов.** Новый переключатель для каждого маршрута, «Линия со стрелками», во вкладке «Настройки линии». При включении в середине каждого сегмента маршрута рисуется стрелка, указывающая реальное направление движения — полезно для маршрутов, которые легко случайно пройти в обратную сторону.
  - Реализовано как полностью отдельная накладываемая текстура (встроенная `Interface\Minimap\MinimapArrow`, поворачиваемая для каждого сегмента через `SetRotation`), а не изменением текстурных координат самой линии. Первая попытка встраивала направленный узор прямо в текстурные координаты линии; этот рендерер регулярно выдаёт UV-координаты далеко за пределами обычного диапазона `[0,1]` на длинных тонких сегментах (незаметно при пустой текстуре линии, но видимо ломается при любом направленном узоре, особенно при повороте миникарты) — поэтому стрелка теперь полностью независимый пул текстур, а код отрисовки линии остаётся нетронутым, когда переключатель выключен.
- **Добавлено: проверка узлов по касту способности и фильтр маршрута «Только проверенные узлы».** В собственной базе GatherMate2 нет понятия происхождения данных — запись, добавленная реальным сбором, и запись, слитая из общего/импортированного набора данных, неотличимы побайтово, поэтому маршруты, построенные на этой базе, не могли отличить подтверждённый узел от узла, которого на этом сервере может не существовать вовсе.
  - Новый `Modules/NodeVerification.lua` хранит состояние `verified`/`missCount` для каждой координаты в `RoutesDB`, основываясь на событии `GatherMate2NodeAdded` — оно срабатывает только при реальном касте способности сбора (собственный `Collector.lua` в GatherMate2), а не при импорте, что делает его единственным надёжным сигналом подтверждения. Обёртка `InsertNode` в `Plugins/GatherMate2.lua` теперь также вызывает `Routes:MarkNodeVerified` при каждом срабатывании `GatherMate2NodeAdded`. Одна лишь близость к точке никогда не засчитывается как промах — проезд мимо ничего не доказывает; промах засчитывается только тогда, когда игрок действительно начинает каст способности сбора (тот же список способностей, что отслеживает Collector самого GatherMate2) находясь в радиусе неподтверждённой точки, и именно эта точка не подтверждается в течение нескольких секунд. На экране «Создать маршрут из источников данных» (и в «Пересоздать маршрут», который использует тот же код создания) появился новый переключатель «Только проверенные узлы», отбрасывающий из итогового маршрута любой узел без `verified == true`.

## Установка

Поместите эту папку в `Interface/AddOns/Routes`. Включайте «Линия со стрелками» для каждого маршрута отдельно через `/routes` → выбрать маршрут → Настройки линии.

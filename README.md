# Routes (Enhanced)

An enhanced fork of [Routes](https://www.curseforge.com/wow/addons/routes) by Grum and Xinhuan. All credit for the original addon goes to the upstream authors; this fork adds an opt-in visual feature on top.

## What changed

- **Direction arrow overlay for drawn routes.** New per-route toggle, "Arrow Line", in the route's existing "Line Settings" tab. When enabled, a direction arrow is drawn at each route segment's midpoint, pointing the way the route actually travels — useful for routes that are easy to walk backwards by mistake.
  - Implemented as a fully separate overlay texture (the built-in `Interface\Minimap\MinimapArrow`, rotated per-segment via `SetRotation`), not by modifying the line's own texture coordinates. An earlier attempt baked a directional pattern into the line's own sheared texture coordinates directly; that renderer routinely produces UV coordinates far outside the normal `[0,1]` range on long/thin segments (invisible with the original blank line texture, but visibly broken with any directional pattern baked in, especially under minimap rotation) — so the arrow is now a fully independent texture pool, and the line-drawing code itself is completely untouched when the toggle is off.

## Installation

Drop this folder into `Interface/AddOns/Routes`. Enable "Arrow Line" per-route via `/routes` → pick a route → Line Settings.

---

# Routes (улучшенная версия)

Улучшенный форк [Routes](https://www.curseforge.com/wow/addons/routes) авторства Grum и Xinhuan. Вся заслуга за оригинальный аддон принадлежит авторам; этот форк добавляет один необязательный визуальный элемент поверх.

## Что изменено

- **Оверлей-стрелка направления для нарисованных маршрутов.** Новый переключатель для каждого маршрута, «Линия со стрелками», во вкладке «Настройки линии». При включении в середине каждого сегмента маршрута рисуется стрелка, указывающая реальное направление движения — полезно для маршрутов, которые легко случайно пройти в обратную сторону.
  - Реализовано как полностью отдельная накладываемая текстура (встроенная `Interface\Minimap\MinimapArrow`, поворачиваемая для каждого сегмента через `SetRotation`), а не изменением текстурных координат самой линии. Первая попытка встраивала направленный узор прямо в текстурные координаты линии; этот рендерер регулярно выдаёт UV-координаты далеко за пределами обычного диапазона `[0,1]` на длинных тонких сегментах (незаметно при пустой текстуре линии, но видимо ломается при любом направленном узоре, особенно при повороте миникарты) — поэтому стрелка теперь полностью независимый пул текстур, а код отрисовки линии остаётся нетронутым, когда переключатель выключен.

## Установка

Поместите эту папку в `Interface/AddOns/Routes`. Включайте «Линия со стрелками» для каждого маршрута отдельно через `/routes` → выбрать маршрут → Настройки линии.

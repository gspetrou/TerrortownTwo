L.LanguageName = "Russian"

-- Roles
L.innocent = "Невиновный"
L.detective = "Детектив"
L.traitor = "Предатель"
L.spectator = "Наблюдатель" -- # Я думаю тут должны быть Наблюдатели.
L.terrorist = "Террористы"

-- Round states
L.waiting = "Ожидание"
L.preperation = "Подготовка"
L.roundend = "Конец" -- # или Конец раунда
L.active = "В процессе"

-- Scoreboard
L.sb_roundinfo = "Карта сменится через %s раунд (а/ов) или %s"
L.sb_karma = "Карма"
L.sb_score = "Счёт"
L.sb_deaths = "Смертей"
L.sb_ping = "Пинг"
L.sb_terrorists = "Террористы"
L.sb_missing = "Пропавшие без вести"
L.sb_dead = "Мёртвые"
L.sb_spectators = "Наблюдатели"
L.sb_playingon = "Вы играете на..."
L.sb_name = "Игрок"
L.sb_role = "Роль"
L.sb_sort_by = "Сортировка:"
L.sb_tag_friend = "ДРУГ"
L.sb_tag_suspect = "ПОДОЗРЕВАЕМЫЙ"
L.sb_tag_avoid = "ИЗБЕГАТЬ"
L.sb_tag_kill = "УБИТЬ"
L.sb_tag_missing = "ПРОПАЛ"

-- Health
L.hp_healthy = "Здоров"
L.hp_hurt = "Слегка ранен"
L.hp_wounded = "Ранен"
L.hp_badwound = "Тяжело ранен"
L.hp_death = "При смерти"

-- T Buttons
L.tbutton_singleuse = "Одноразовое использование."
L.tbutton_reusable = "Многоразовое использование."
L.tbutton_reuse_time = "Можно использовать повторно через %s сек."
L.tbutton_help = "Нажмите %s, чтобы активировать."
L.tbutton_help_command = "Пропишите %s в консоль для активации."

-- Weapons
L.weapon_drop_no_room = "Здесь нет места, чтобы выбросить оружие!"

L.weapon_m16 = "M16"
L.weapon_crowbar = "Монтировка"
L.weapon_deagle = "Deagle"
L.weapon_glock = "Glock"
L.weapon_mac10 = "MAC10"
L.weapon_pistol = "Пистолет"
L.weapon_shotgun = "Дробовик"
L.weapon_scout = "Винтовка"
L.weapon_unarmed = "Ничего"

L.weapon_dnascanner = "Сканер ДНК"

-- Grenades
L.weapon_firenade = "Зажигательная граната"
L.weapon_discombob = "Отталкивающая граната"
L.weapon_smokenade = "Дымовая граната"

L.ammo_not_enough = "Недостаточно патронов в обойме для их выброса в виде коробки с патронами."
L.ammo_drop_no_room = "Здесь нет места, чтобы выбросить патроны!"

-- Body Search
L.body_search_results = "Результаты осмотра тела"

-- Notifications
L.notification_start_innocent = [[Вы невиновный террорист! Но вокруг есть предатели...
Кому вы можете доверять, а кого стоит опасаться?

Оглядывайтесь по сторонам и работайте вместе со своими товарищами, чтобы остаться в живых!]]

L.notification_start_detective = [[Вы детектив! Штаб выдал вам особое снаряжение, чтобы найти предателей.
Используйте его, чтобы помочь невиновным выжить, но будьте осторожны,
ведь предатели будут стараться убить вас первым!

Нажмите %s, чтобы купить особое снаряжение!]]

L.notification_start_traitor_solo = [[Вы предатель! В этом раунде у вас нет товарищей.
Убейте всех, чтобы победить!

Нажмите %s, чтобы купить особое снаряжение!]]

L.notification_start_traitor_multi = [[Вы предатель! Работайте со своими товарищами, чтобы убить всех остальных.
Но будьте осторожны, иначе ваше предательство будет раскрыто...

Ваши товарищи:
%s

Нажмите %s, чтобы купить особое снаряжение!
]]
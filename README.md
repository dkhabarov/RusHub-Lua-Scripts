Access_IPRanges_v0.1beta.lua:
Скрипт проверяет айпи адрес юзера и если тот не соответствует диапазонам которые указаны в таблице, отключает с хаба. 

---------------------------------------
RHConfManager.lua:
Скрипт быстрой настройки хаба, при помощи команд:
+setconfig [переменная] [новое значение] - Установить настройку
+getconfig - Посмотреть настройки хаба
Так же есть логирование управления настройками. При старте скрипта будет создана дериктория: ~/rushub/logs/cfg/, а при управлении настройками в ней будут файлы-логи с названием [11-04-26]-<ник_юзера>.log.
Например:
+setconfig sTopic Добро пожаловать - Будет установлен топик "Добро пожаловать".
Цитата
Saymon-[10.128.162.28]:[26.04.2011 03:00:27] просмотр настрек хаба
Saymon-[10.128.162.28]:[26.04.2011 03:00:35] просмотр настрек хаба
Saymon-[10.128.162.28]:[26.04.2011 03:00:51] Установка переменной sTopic с test на test....
Saymon-[10.128.162.28]:[26.04.2011 03:09:44] Установка переменной sTopic с test.... на Добро пожаловать!
Saymon-[10.128.162.28]:[26.04.2011 17:02:49] Попытка установки запрещённого параметра sAddresses

О настройках хаба читать тут: http://mydc.ru/topic2378.html

---------------------------------------
SendReports.lua
Простой скрипт позволяющий отправить жалобу на юзера админам хаба
(по командам: !жалоба <ник> <причина> или !report <ник> <причина> + есть меню.) 

---------------------------------------
AntiTor_1.0.lua

Описание скрипта: Скрипт не даёт зайти на хаб пользователям, использующим технологию Tor.

Протестировано на Debian GNU/Linux 6.0.4, RusHub 2.3.9, LuaPlugin 2.8

Отличия этой версии:

1) curl теперь вызывается не из скрипта. Надо подумать зарание об обновлении бд через сторонний планировщик. Например cron. Под венду были сборки. Хотя там есть и куча других альтернатив. google://.
Пример задачи для cron:

$ crontab -l |grep curl
*/50 * * * * /usr/bin/curl -L --retry 3 --connect-timeout 5 -m 15 -s -o "/usr/local/etc/rushub/scripts/AntiTor/torlist.txt" "http://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv"

Вместо curl также можно использовать wget, fetch аля bsd, libwww-perl и т.п.

2) в Ban ныне она ExecuteOnTor (карательная функция для тех, кто лезет с tor'ом) добавлена возможность вызова iptables, ipfw, route, ipchains (Можно вписать вызов любых утилит). В комментариях показаны примеры некоторых правил к ним. Под венду: google://wipfw. Все вопросы о настройке утилит, sudo, fw, google:// пожалуйста.

3) Добавлена возможность блокировки чата/привата tor-юзерам, на случай если кто-то решит что лучше пускать всех подряд, но пусть они сидят молча.
Из фич тут есть возможность тихой блокировки.

4) Добавлена проверка всех онлайн юзеров на подключение с Tor при старте скрипта и при обновления списка адресов.

5) Добавлена проверка OnMCTo. (Персональные сообщения в главном чате). Настройки такие же, как и для чата/лс. 

---------------------------------------
RHWarningsUsers.lua:

Скрипт предупреждений юзера с возможностью отправки в бан после N предупреждений.

Для работы нужен модуль банов: http://mydc.ru/topic2885.html

---------------------------------------
chatcontrol.lua:
Скрипт аварийной заглушки чата хаба для тех случаев, когда нет иного способа присечь например флуд.
Есть возможность заглушить чать отдельно для незарегистрированных юзеров или всех, кроме операторов.
!chat on - Обычный режим чата
!chat off - Для всех, кроме операторов (тех, кто в ОПлисте или имеет ключ)
!chat regs - Только для зарегистрированных. 

----------------------------------------
scripts.lua:

Скрипт управления скриптами. (Остановка, перезапуск, запуск, список скриптов)

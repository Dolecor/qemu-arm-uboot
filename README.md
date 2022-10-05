# Описание
В данном проекте представлена сборка ядра Linux, загрузчика U-Boot и подготовка корневой файловой системы с целью запуска ОС Debian 11 в Qemu для ARM устройства.

# Скачивание проекта
Скачивание проекта и подмодулей (ядро Linux, загрузчик U-Boot, модуль ядра):
```bash
git clone https://github.com/Dolecor/qemu-arm-boot-procedure.git
git submodule update --init
```

# Сборка
## Зависимости
Для сборки понадобится кросс-компилятор arm-linux-gnueabihf-, который может быть установлен командой:
```bash
sudo apt install gcc-arm-linux-gnueabihf
```

Также необходимы пакеты build-essential, bison, flex, openssl. В случае ошибок см. набор пакетов для сборки ядра и загрузчика: [Minimal requirements to compile the Kernel](https://www.kernel.org/doc/html/latest/process/changes.html) и [Build U-Boot with GCC](https://u-boot.readthedocs.io/en/latest/build/gcc.html#debian-based).
```bash
sudo apt install build-essential bison flex libssl-dev
```

Для создания образа uImage и переменных окружения U-Boot необходим пакет u-boot-tools:
```bash
sudo apt install u-boot-tools
```

Для настройки файловой системы необходимо установить пакеты debootstrap и qemu-user-static:
```bash
sudo apt install debootstrap qemu-user-static
```

## Процесс сборки
Для начала сборки необходимо выполнить команду `make`. Сначала выполняется сборка загрузчика U-Boot, в ходе которой вызывается menuconfig. На этом этапе необходимо выбрать в меню Environment загрузку с EXT4 файловой системы и заполнить появившиеся пункты:

 - name of the block device (mmc)
 - device and partition (0:1)
 - name of EXT4 file (/boot/uboot.env)

Следующий этап, который потребует ввода, это подготовка корневой файловой системы. Для выполнения команды qemu-debootstrap требуется ввести пароль для root пользователя. Права root также понадобятся на этапе создания образа SD-карты.

Для очистки проекта: `make clean`.

# Запуск эмулятора Qemu
Для запуска необходим пакет qemu-system-arm:
```bash
sudo apt install qemu-system-arm
```

В процессе сборки создаются два необходимых для запуска эмулятора файла:
 - исполняемый файл u-boot (qemu-arm-boot-procedure/u-boot/u-boot),
 - образ SD-карты (qemu-arm-boot-procedure/misc/sd.img).

Инструкция по запуску ОС в эмуляторе:
1. Запуск Qemu (из корня проекта):
    ```bash
    qemu-system-arm -M vexpress-a9 -m 1G -nographic -kernel u-boot/u-boot -sd misc/sd.img
    ```
2. Данные для входа в командную оболочку:  
    логин - root, пароль - 123.
3. (Опционально) В качестве проверки можно загрузить модуль (см. [pseudo-device-driver: Проверка работы устройств](https://github.com/Dolecor/pseudo-device-driver#проверка-работы-устройств) read/write и sysfs):
    ```bash
    insmod /lib/modules/5.19.0/pseud/pseud.ko
    ```

# Авторство и лицензия
## Автор
Copyright (c) 2022 Доленко Дмитрий <<dolenko.dv@yandex.ru>>
## Лицензия
Исходный код распространяется под лицензией MIT (см. прилагаемый файл LICENSE).
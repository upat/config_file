# シングルボードPC個人的メモ(update:2025.06.17)

## 目次
- [基本操作](#基本操作)
- [pip](#pip)
- [samba](#samba)
- [NTFSなディスクを使用する時](#NTFSなディスクを使用する時)
- [GUIとCUIの切替](#GUIとCUIの切替)
- [SSH通信切断後もバッググラウンド実行の維持](#SSH通信切断後もバッググラウンド実行の維持)
- [HDDのSMART値出力](#HDDのSMART値出力)
- [(未使用)Bluetooth導入](#Bluetooth導入)
- [(未使用)音声出力ハードの確認](#音声出力ハードの確認)
- [(未使用)Nginxの導入](#Nginxの導入)
- [NTPの設定](#NTPの設定)
- [crontabの設定](#crontabの設定)
- [(未使用)Apacheの設定](#Apacheの設定)
- [USB電源管理](#USB電源管理)
- [HDDを完全停止させる手順](#HDDを完全停止させる手順)
- [(未使用)TinkerBoard設定](#TinkerBoard設定)
- [chromedriverの導入](#chromedriverの導入)
- [TeraTermリモート設定](#TeraTermリモート設定)
- [Raspberry PiのステルスSSID対応](#Raspberry-PiのステルスSSID対応)
- [ウォッチドッグタイマ有効化＆再起動](#ウォッチドッグタイマ有効化＆再起動)

### 基本操作
---
- シャットダウン
    - `sudo halt` または `shutdown -h now`
- 再起動
    - `sudo reboot`
- デバイスのマウント
    - `sudo umount [デバイスのパス]`
- デバイスのアンマウント
    - `sudo mount -a`
- HDMI出力の停止(動くか謎)
    - `tvservice --off`
        - 出力再開は `tvservice -p`
- とりあえずアプデ(`-y` は全て自動でyes入力)
    - `sudo apt update`
        - パッケージリストの更新
    - `sudo apt full-upgrade -y`
        - インストール済みのパッケージを全てアップグレード
    - `sudo apt autoremove -y`
    - `sudo apt clean`
        - 不要なパッケージの削除
    - `sudo reboot`
        - 再起動

### pip
---
- pipのインストール(ラズパイは初期インストール済み)
    - `sudo apt install python3-dev python3-pip`
- pipのアプグレ
    - `python3 -m pip install --upgrade pip`
- アップデート有無確認
    - `python3 -m pip list --o`

### samba
---
- インストール
    - `sudo apt install samba`
    - 上記インストール中にWINS設定を使うか尋ねられるが「いいえ」でOK
- 設定ファイル編集
    - `sudo vi /etc/samba/smb.conf`
- 設定例
    ```
    [pi]
        comment = Raspberry Pi
        path = /home/pi
        guest ok = yes
        read only = no
        browseable = yes
        force user = pi
    ```
- 起動
    - `sudo service smbd restart`
    - `sudo service nmbd restart`
- 停止
    - `sudo service samba stop`
- 自動で起動しないとき
    ```
    sudo systemctl enable smbd
    sudo systemctl enable nmbd
    ```

### NTFSなディスクを使用する時
---
- 対象NTFSデバイスの調べ方
	- `sudo parted -l` でデバイスを調べる( `/dev/sda` など)
    - `sudo blkid` でUUIDを調べる(/dev/sdaなどの場合、 `/dev/sda2` に書かれている)
    
- 設定
    - `sudo apt install ntfs-3g` でパッケージを入れる(ラズパイは初期インストール済)
    - `sudo vim /etc/fstab` を開く
    - 上記の末尾へ下記を挿入
    ```
    UUID="[上記で調べたUUID]"    [マウントしたデバイスのパス]    ntfs-3g    default,nofail    0,0
    ```
    - 再起動後、`df` コマンドでマウントされているか確認

### GUIとCUIの切替
---
- 一時的
    - `startx`
- 起動時から
    - `sudo raspi-config` 実行
    - `System Options` → `Boot / Auto Login` → `Console Autologin` または `Desktop Autologin`

### SSH通信切断後もバッググラウンド実行の維持
---
- 開始
    - `nohup [コマンド] > ~/nohup.txt &`
- 停止(Pythonコマンド例)
    - `ps -fu pi` でPIDの検索( `ps -fC "python3 [Pythonファイル]"` でも可)
    - `kill [PID]` で停止

### HDDのSMART値出力
---
- smartmontoolsをインストールする
- `smartctl -a [デバイスのパス] -d sat` ( `-d sat` オプションはエラーが出た場合)

### Bluetooth導入
---
- インストール
    - `sudo apt install bluez pulseaudio-module-bluetooth python-gobject python-gobject-2`
- 設定など
    - `sudo bluetoothctl` 後に `show` を入力し、 `UUID: Audio Sink` の項目があるか確認
        - powered yes
        - discoverable no … ペアリング後はoffに切り替わるらしい
        - pairable yes -> の状態になっているか show のコマンドで確認
- ペアリング
    - `sudo bluetoothctl`
    - `trust [bluetoothのID]`

### 音声出力ハードの確認
---
- コマンド
    - `pactl list sinks short`
    - `pactl list sources short`
    - `lsusb`
    - `aplay -l`
- 出力先切り替えコマンド
    - `/etc/pulse/default.pa` に `set-default-sink [デバイス名(pactl list sinks shortに表示される方)]`
        - `load-module module-suspend-on-idle` をコメントアウト（デバイスがIDLEではなくSUSPENDEDから復帰しない時）
- ノイズ低減？
    - `/etc/pulse/daemon.conf` に `resample-method = trivial,default-sample-rate = 48000`

- `pulseaudio --start` しておく
   - Daemon化させて自動実行
       - `/etc/rc.local` に `pulseaudio -D` を追記

### Nginxの導入
---
- インストール
    - `sudo apt install nginx`
    - `curl http://uwsgi.it/install | bash -s cgi /home/pi/uwsgi`
- サーバー設定
    - `/etc/nginx/sites-enabled/default`
    - `uwsgi_config.ini` の場所は `~/uwsgi_config.ini`

### NTPの設定
---
- `/etc/systemd/timesyncd.conf` を開き、下記設定に変更

    ```
    [Time]
    NTP=ntp.nict.jp
    FallbackNTP=time1.google.com time2.google.com time3.google.com time4.google.com
    ```
- 上記実施後 `sudo systemctl restart systemd-timedated.service`

### crontabの設定
---
- 動作状態の確認
    - `service cron status`
- 再起動
    - `sudo service cron restart`
- テキスト記載したcrontabの設定をロード
    - `crontab [ファイル名]`
- 設定済みコマンドの確認
    - `crontab -l`
- 設定済みのコマンドをすべて消去
    - `crontab -r`

- 毎時15分に実行されるサンプル
    ```
    SHELL=/bin/sh
    PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    15 * * * * bash -l -c 'python3 /home/pi/hoge.py'
    ```

- crontabログの取得
    - `sudo vim /etc/rsyslog.conf` を開き、cron.*のコメントアウトを有効化
    - `sudo /etc/init.d/rsyslog restart`
    - `sudo vim /etc/default/cron` を開き、`EXTRA_OPTS="-L 15"` にする
    - `sudo /etc/init.d/cron restart`
    - `tail -f /var/log/cron.log` で保存先指定？

### Apacheの設定
---
- インストール
    - `sudo apt install apache2`
- 設定ファイル
    - `/etc/apache2/mods-available/mime.conf`
    - `/etc/apache2/conf-available/serve-cgi-bin.conf`

### USB電源管理
---
- hub-ctrlコマンド(使う前にlsusbで調べる)
    - インストール
        - `sudo apt install libusb-dev` (ラズパイは初期インストール済)
        - 任意のディレクトリで下記コマンド実行
        ```
        wget http://www.gniibe.org/oitoite/ac-power-control-by-USB-hub/hub-ctrl.c
        gcc -O2 hub-ctrl.c -o hub-ctrl-armhf-static -lusb -static
        sudo mv hub-ctrl-armhf-static /usr/local/bin/hub-ctrl
        ```

### HDDを完全停止させる手順
---
- アンマウント
    - `echo -n "1-1.2" | sudo tee /sys/bus/usb/drivers/usb/unbind` (実行前に`udevadm info --query=path --name=/dev/sda2` で確認)
- USB電源供給停止
    - `sudo hub-ctrl -b 1 -d 2 -P 2 -p 0`
    - 上記の調べ方
    ```
    lsusb を実行
    →Bus 001 Device 006: ID 174c:55aa ASMedia Technology Inc. Name: ASM1051E SATA 6Gb/s bridge(省略) を見つける
    lsusb -tを実行
    →|__ Port 3: Dev 6, If 0, Class=Mass Storage, Driver=usb-storage, 480M を見つける
    
    hub-ctrlのオプション
    -b: Bus
    -d: Device(Dev)
    -P: Port
    -p: 0=off, 1=on
    以上より-b 1 -d 6 -P 3 -p 0(ハードによっては1つ上のルートのハブを指定しないといけない)
    ```
    - ※一部の機器は電源供給停止不可(ESP8266はダメだった)

### TinkerBoard設定
---
- CH340ドライバ導入
    - おそらく `sudo modprobe ch341` 実行して再起動でいいはず…
    - その他わるあがき
        - `sudo apt install git-core device-tree-compiler`
        - `git clone https://github.com/TinkerBoard/debian_kernel.git`
        - `ln -s ~/debian_kernel /usr/src/linux-headers-$(uname -r)`

- タイムゾーン設定
    - `sudo dpkg-reconfigure tzdata`
        - Asia > Tokyoを設定

- 内蔵RTCがないので最後にシャットダウンした時刻から調整
    - `sudo apt install fake-hwclock -y`

- node.jsを入れたい
    - 下記コマンドを実行
    ```
    sudo curl -sL https://deb.nodesource.com/setup_9.x | sudo bash -
    sudo apt install nodejs
    ```

    - pageresのインストール(動かなかった)
        - node.jsインストール後、`npm i -g pageres-cli`

- Chromium問題(新しいOSバージョンだと勝手にロックされてるらしい)
    ```
    wget https://snapshot.debian.org/archive/debian-security/20180701T015633Z/pool/updates/main/c/chromium-browser/chromium_67.0.3396.87-1~deb9u1_armhf.deb
    sudo dpkg -i chromium_67.0.3396.87-1~deb9u1_armhf.deb
    sudo apt-mark hold chromium
    ```
### chromedriverの導入
---
- パッケージに含まれているため、`sudo apt install chromium chromium-driver` でOK

### TeraTermリモート設定
---
- `sudo raspi-config` を実行
- Interface Options を選択
- SSH を選択
- Enable を選択
- ※TinkerBoardは初期設定の状態で接続可能らしい(ユーザー名：linaro,パス：linaro)

### Raspberry PiのステルスSSID対応
---
- ※非ステルスSSIDで設定済みの前提
- `sudo vi /etc/wpa_supplicant/wpa_supplicant.conf` を開く
- 下記記述を探す
    ```
    network={
            ssid=[任意のSSID]
            psk=[任意のパスワード]
            key_mgmt=WPA-PSK
    }
    ```
- 上記に `scan_ssid=1` を追加

### ウォッチドッグタイマ有効化＆再起動
---
- `/boot/config.txt` に `dtparam=watchdog=on` を行追加
- `sudo mkdir /etc/systemd/system.conf.d/` でフォルダ作成
- `sudo nano /etc/systemd/system.conf.d/main.conf` でファイル作成し、以下を追加
  ```
  [Manager]
  RuntimeWatchdogSec=5
  ```
- `sudo nano /etc/modprobe.d/bcm2835-wdt.conf` でファイル作成し、以下を追加
  ```
  options bcm2835_wdt heartbeat=10 nowayout=0
  ```
- `sudo reboot` で再起動し以下のコマンド応答があれば設定完了
  ```
  pi@raspberrypi:~ $ sudo dmesg | grep bcm2835-wdt
  [    3.109339] bcm2835-wdt bcm2835-wdt: Broadcom BCM2835 watchdog timer
  pi@raspberrypi:~ $ sudo dmesg | grep systemd | grep watchdog
  [    4.523176] systemd[1]: Hardware watchdog 'Broadcom BCM2835 Watchdog timer', version 0
  [    4.523230] systemd[1]: Set hardware watchdog to 5s.
  ```

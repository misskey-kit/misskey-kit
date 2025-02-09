#!/bin/bash

# bind mountした外部のcrontabファイルが変更されたら即座にcrondに反映されるように監視する
# 監視などしないでも外部のcrontabファイルを直接crondの設定ファイルにマウントしてしまえばそれで良いのではないかと
# 思うかも知れないが、crondの設定ファイルはrootがオーナーである必要があり、bind mountファイルではそれを満たせない。
echo /misskey/etc/crontab | entr -n busybox crontab /_ &

busybox crond -f -l  0 -L /dev/stderr
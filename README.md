# prok
easy process grep with ps output

```
Prok: easy process grep with ps output

Usage: prok [--user <USERNAME>] [--uid <UID>] [-fmp1239] [--SIG<SIGNAL>] [<PATTERN>]

Parameters:
    -f --forest         print parents of all matched PID's.
                            On linux prints with 'ps f'
    -m --my             match only processes of current user
    -p --procname       match only executable, not full command
    --user USERNAME     match only processes of USERNAME
    --uid UID           match only processes of UID(numeric)

    --kill              ask to kill all matched processes
    --SIG<SIGNAL>       do killing with this signal. e.g. --SIGKILL
    -1 -2 -3 -9         do killing with signal's numeric alias
                            Be cautious with -f option, it'll bring whole forest down
```

## Examples

let's spawn some processes:
```
server:~/>sleep 20000 &
[2] 31029
server:~/>sleep 20000 &
[3] 31061
server:~/>sleep 20000 &
[4] 31093
server:~/>sleep 20000 &
[5] 31125
server:~/>sleep 20000 &
[6] 31157
```
### simple grep
```
server:~/>prok sleep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     30703  0.0  0.0   6008   700 pts/2    SN   04:28   0:00 sleep 50000
root     30732  0.0  0.0   6008   660 pts/2    SN   04:28   0:00 sleep 50000
root     30761  0.0  0.0   6008   656 pts/2    SN   04:28   0:00 sleep 50000
root     30790  0.0  0.0   6008   804 pts/2    SN   04:28   0:00 sleep 50000
root     30819  0.0  0.0   6008   668 pts/2    SN   04:28   0:00 sleep 50000
root     30848  0.0  0.0   6008   664 pts/2    SN   04:28   0:00 sleep 50000
root     30877  0.0  0.0   6008   644 pts/2    SN   04:28   0:00 sleep 50000
cornhol+ 30910  0.0  0.0   6008   672 pts/0    SN   04:29   0:00 sleep 20000
cornhol+ 31029  0.0  0.0   6008   796 pts/0    SN   04:29   0:00 sleep 20000
cornhol+ 31061  0.0  0.0   6008   676 pts/0    SN   04:29   0:00 sleep 20000
cornhol+ 31093  0.0  0.0   6008   696 pts/0    SN   04:29   0:00 sleep 20000
cornhol+ 31125  0.0  0.0   6008   744 pts/0    SN   04:29   0:00 sleep 20000
cornhol+ 31157  0.0  0.0   6008   696 pts/0    SN   04:29   0:00 sleep 20000
root     31192  0.0  0.0   6008   672 ?        S    04:29   0:00 sleep 10
```
### only my processes
```
server:~/>./prok.sh --my sleep
    PID TTY          TIME CMD
 994486 pts/13   00:00:00 sleep
 994509 pts/13   00:00:00 sleep
 994533 pts/13   00:00:00 sleep
 994555 pts/13   00:00:00 sleep
 994590 pts/13   00:00:00 sleep
```
### process trees
```
server:~/>prok -f sleep
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1204  0.0  0.0  20004  3384 ?        Ss   Oct14  23:18 /bin/bash /usr/sbin/fancontrol
root     31836  0.0  0.0   6008   652 ?        S    04:31   0:00  \_ sleep 10
root       949  0.0  0.0  65508  2884 ?        Ss   Oct14   0:00 /usr/sbin/sshd -D
root     29930  0.0  0.1  94888  6880 ?        Ss   04:28   0:00  \_ sshd: cornholio [priv]
cornhol+ 29936  0.0  0.0  94888  3244 ?        S    04:28   0:00  |   \_ sshd: cornholio@pts/0
cornhol+ 29937  0.7  0.1  43052  5584 pts/0    Ss   04:28   0:01  |       \_ -zsh
cornhol+ 31837  0.0  0.0   6008   640 pts/0    SN   04:31   0:00  |           \_ sleep 20000
cornhol+ 31869  0.0  0.0   6008   804 pts/0    SN   04:31   0:00  |           \_ sleep 20000
cornhol+ 31901  0.0  0.0   6008   648 pts/0    SN   04:31   0:00  |           \_ sleep 20000
cornhol+ 31933  0.0  0.0   6008   744 pts/0    SN   04:31   0:00  |           \_ sleep 20000
cornhol+ 31965  0.0  0.0   6008   652 pts/0    SN   04:31   0:00  |           \_ sleep 20000
cornhol+ 31997  0.0  0.0   6008   740 pts/0    SN   04:31   0:00  |           \_ sleep 20000
root     30261  0.0  0.1  94888  6852 ?        Ss   04:28   0:00  \_ sshd: cornholio [priv]
cornhol+ 30267  0.0  0.0  94888  3184 ?        S    04:28   0:00      \_ sshd: cornholio@pts/2
cornhol+ 30268  0.2  0.1  43012  5348 pts/2    Ss   04:28   0:00          \_ -zsh
root     30566  0.0  0.1  53512  3924 pts/2    S    04:28   0:00              \_ sudo su
root     30567  0.0  0.0  53096  3508 pts/2    S    04:28   0:00                  \_ su
root     30568  0.2  0.1  42840  5396 pts/2    S+   04:28   0:00                      \_ zsh
root     30703  0.0  0.0   6008   700 pts/2    SN   04:28   0:00                          \_ sleep 50000
root     30732  0.0  0.0   6008   660 pts/2    SN   04:28   0:00                          \_ sleep 50000
root     30761  0.0  0.0   6008   656 pts/2    SN   04:28   0:00                          \_ sleep 50000
root     30790  0.0  0.0   6008   804 pts/2    SN   04:28   0:00                          \_ sleep 50000
root     30819  0.0  0.0   6008   668 pts/2    SN   04:28   0:00                          \_ sleep 50000
root     30848  0.0  0.0   6008   664 pts/2    SN   04:28   0:00                          \_ sleep 50000
root     30877  0.0  0.0   6008   644 pts/2    SN   04:28   0:00                          \_ sleep 50000
 ```
### kill the bastards
```
server:~/>./prok.sh -u --kill --my sleep
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
27860     994486  0.0  0.0   9816  1420 pts/13   SN   18:55   0:00 sleep 20000
27860     994509  0.0  0.0   9816  1380 pts/13   SN   18:55   0:00 sleep 20000
27860     994533  0.0  0.0   9816  1424 pts/13   SN   18:55   0:00 sleep 20000
27860     994555  0.0  0.0   9816  1420 pts/13   SN   18:55   0:00 sleep 20000
27860     994590  0.0  0.0   9816  1380 pts/13   SN   18:55   0:00 sleep 20000
Kill each of these processes? (y/n)
y
Killed
[1]    994486 terminated  sleep 20000
[2]    994509 terminated  sleep 20000
[3]    994533 terminated  sleep 20000
[4]  - 994555 terminated  sleep 20000
[5]  + 994590 terminated  sleep 20000
```

# prok
easy process grep with ps output

```
Usage: prok [--user <USERNAME>] [--uid <UID>] [-fmpu] [<PATTERN>]

Parameters:
    -f --forest         print parents of all matched PID's.
                            On linux prints with 'ps f'
    -m --my             match only processes of current user
    -p --procname       match only process name, not full command line
    -u                  print output in 'ps u' style
    --user USERNAME     match only processes of USERNAME
    --uid UID           match only processes of UID(numeric)
    --kill              ask to kill all matched processes.
                            Be cautious with -f option, it'll bring whole forest down
```

## Examples
let's spawn some processes:
```
server:~/>sleep 20000 &
[1] 994486
server:~/>sleep 20000 &
[2] 994509
server:~/>sleep 20000 &
[3] 994533
server:~/>sleep 20000 &
[4] 994555
server:~/>sleep 20000 &
[5] 994590
```
### simple grep
```
server:~/>./prok.sh sleep
    PID TTY          TIME CMD
 991940 pts/1    00:00:00 sleep
 991943 pts/1    00:00:00 sleep
 991944 pts/1    00:00:00 sleep
 991946 pts/1    00:00:00 sleep
 994486 pts/13   00:00:00 sleep
 994509 pts/13   00:00:00 sleep
 994533 pts/13   00:00:00 sleep
 994555 pts/13   00:00:00 sleep
 994590 pts/13   00:00:00 sleep
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
### use `ps -u`
```
server:~/>./prok.sh -u sleep
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      991940  0.0  0.0   9816  1352 pts/1    S    18:54   0:00 sleep 400000
root      991943  0.0  0.0   9816  1348 pts/1    S    18:54   0:00 sleep 400000
root      991944  0.0  0.0   9816  1424 pts/1    S    18:54   0:00 sleep 400000
root      991946  0.0  0.0   9816  1300 pts/1    S    18:54   0:00 sleep 400000
27860     994486  0.0  0.0   9816  1420 pts/13   SN   18:55   0:00 sleep 20000
27860     994509  0.0  0.0   9816  1380 pts/13   SN   18:55   0:00 sleep 20000
27860     994533  0.0  0.0   9816  1424 pts/13   SN   18:55   0:00 sleep 20000
27860     994555  0.0  0.0   9816  1420 pts/13   SN   18:55   0:00 sleep 20000
27860     994590  0.0  0.0   9816  1380 pts/13   SN   18:55   0:00 sleep 20000
```
### process trees
```
server:~/>./prok.sh -f sleep
    PID TTY      STAT   TIME COMMAND
 693979 ?        Ss     0:00  \_ sshd: cornholio [priv]
 694806 ?        S      0:01  |   \_ sshd: cornholio@pts/13
 694825 pts/13   Ss     0:00  |       \_ -zsh
 994486 pts/13   SN     0:00  |           \_ sleep 20000
 994509 pts/13   SN     0:00  |           \_ sleep 20000
 994533 pts/13   SN     0:00  |           \_ sleep 20000
 994555 pts/13   SN     0:00  |           \_ sleep 20000
 994590 pts/13   SN     0:00  |           \_ sleep 20000
 990473 ?        Ss     0:00  \_ sshd: cornholio [priv]
 990857 ?        S      0:00      \_ sshd: cornholio@pts/1
 990858 pts/1    Ss     0:00          \_ -zsh
 991092 pts/1    S      0:00              \_ sudo su
 991093 pts/1    S      0:00                  \_ su
 991094 pts/1    S+     0:00                      \_ bash
 991940 pts/1    S      0:00                          \_ sleep 400000
 991943 pts/1    S      0:00                          \_ sleep 400000
 991944 pts/1    S      0:00                          \_ sleep 400000
 991946 pts/1    S      0:00                          \_ sleep 400000
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

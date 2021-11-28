IR8x9 LXC版アプリの起動の例
============================

- 2021年11月くらいの話。
- sysbenchを動かす例。

基本は [Tutorial](https://developer.cisco.com/docs/iox/#!tutorial-build-sample-lxc-type-iox-app-using-docker-toolchain/tutorial-build-sample-lxc-type-iox-app-using-docker-toolchain) に従う。

- Dockerでrootイメージを作るのでLXC版アプリのビルドはMacでもできる。
- LXC版アプリのビルドはLinuxでないとダメ。
    + Docker in Dockerできないのかな？

```
Generating IOx package, type =  lxc
Error while exporting docker image and creating rootfs image
Error occurred :  For this command, IOxclient needs to be run in a Linux environment!
```

## Dockerを使ったアプリのビルド

- 開発環境はDocker。
- Docker版アプリのコンテナを作るまでは、ほぼ同じ。
- [IOX SDE 1.7.0](https://developer.cisco.com/docs/iox/#!iox-resource-downloads/downloads)に入ってるDockerは17.03でマルチステージビルドが使えない。
    + docker環境があれば何でもいいはずなので独自に作る方が便利かもしれない。

以下、IOX SDEを使ってみた。

```
docker build -t ir8x9-benchmark-lxc-dev -f Dockerfile.dev .
docker run --name dev ir8x9-benchmark-lxc-dev
docker start dev
docker cp dev:/build .
docker stop dev
docker rm dev
```

/sbin/init から起動するので、/etc/init.dに起動スクリプトを置く。

```
cat init_benchmark.sh
#!/bin/sh
# chkconfig: 123 69 68
# description: Hello World application init script

# Source function library.
. /etc/init.d/functions

start() {
    echo -n "Start benchmark"
    #source /data/.env
    /bin/benchmark.sh &
}

stop() {
    kill -9 `pidof benchmark.sh`
}

case "$1" in 
    start)
       start
       ;;
    stop)
       stop
       ;;
    restart)
       stop
       start
       ;;
    status)
       # code to check status of app comes here 
       # example: status program_name
       ;;
    *)
       echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0 
```

```
docker build -t ir8x9-benchmark-lxc .
```

ここでDockerコンテナのビルドが完了。

## LXC版アプリのパッケージを作る。

Dockerコンテナから、LXC版アプリのパッケージを作る。

package.yamlのポイントは下記の3つ。

```
type: lxc
startup:
  rootfs: rootfs.img
  target: /sbin/init
```

package.yaml全部

```
% cat pkg/package.yaml 
descriptor-schema-version: "2.4"
info:
  name: ir8x9-benchmark
  description: "Ubuntu Linux with sysbench LXC"
  version: "1.0"
app:
  type: lxc
  kernel-version: "1.0"
  cpuarch: x86_6"4
  resources:
    profile: custom
    cpu: 512
    memory: 64
    disk: 2
    network:
    - interface-name: eth0
      ports: {}
  startup:
    rootfs: rootfs.img
    target: /sbin/init
```

パッケージ作成の前に必要ならioxclientを初期設定する。
ioxclientについては、[What is ioxclient?](https://developer.cisco.com/docs/iox/#what-is-ioxclient)を参照する。

```
ioxclient pr c
```

DockerイメージからDocker版IOxパッケージを作る。

```
ioxclient docker pkg ir8x9-benchmark pkg/
```

## パッケージのインストール

パッケージのインストールから起動してログ取得まで。

```
ioxclient app in benchmark pkg/package.tar
ioxclient app act benchmark
ioxclient app appdata upload benchmark appenv.txt appenv.txt
ioxclient app start benchmark
ioxclient app logs download benchmark benchmark.log
```

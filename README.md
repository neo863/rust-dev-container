# 离线环境 Rust Dev Container 构建

默认镜像基于 Rust 官方镜像并安装必要的开发工具。同时默认开启了字节的 [https://rsproxy.cn/](https://rsproxy.cn/) 源，默认安装好了 rust-src、cargo-edit 等 Rust 项目的基本工具，后续可以基于这个源继续安装其他的依赖。

## 1. 镜像构建

构建镜像：

```shell
docker build -t rust-dev-container:1.94.1-trixie .
```

## 2. 初始化 VSCode 插件

首先运行容器：

```shell
docker run -it --name rust-dev-container rust-dev-container:1.94.0-trixie /bin/bash
```

然后通过 VSCode 连接当前目标容器，连接后安装必要的插件：

核心插件：

1. [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)
2. [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
3. [Even Better TOML](https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml)

其他辅助开发插件：

1. CMake  [https://marketplace.visualstudio.com/items?itemName=twxs.cmake](https://marketplace.visualstudio.com/items?itemName=twxs.cmake)
2. CMake Tools  [https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools)
3. Container Tools [https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers)
4. Docker  [https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) 
5. Git History  [https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)
6. Git History Diff [https://marketplace.visualstudio.com/items?itemName=huizhou.githd](https://marketplace.visualstudio.com/items?itemName=huizhou.githd)
7. Makefile Tools [https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools)
8. Markdown All in One [https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
9. Markdown Preview Mermaid Support  [https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)

为了方便运行 Python 测试脚本也可以安装 Python 相关的插件：

1. [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

会自动包含下面几个插件：

1. [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance)
2. [Python Debugger](https://marketplace.visualstudio.com/items?itemName=ms-python.debugpy)
3. [Python Environments](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-python-envs)

安装插件后可以将当前容器发布为镜像：

```shell
# DATE_VERSION 为构建的日期
DATE_VERSION=$(date +%Y%m%d)
docker commit -m "Rust Dev Container (VSCode 1.115.0)" \
    rust-dev-container \
    rust-vscode-dev-container:1.94.1-trixie-${DATE_VERSION}
```

也可以安装插件后打包 `~/.vscode-server` 目录，然后在 `Dockerfile` 中释放目录，这样一次构建即可形成最终的镜像。

## 3. 离线环境安装

导出开发镜像包：

```shell
docker save rust-vscode-dev-container:1.94.1-trixie-${$DATE_VERSION} -o rust-vscode-dev-container-1.94.1-trixie-${DATE_VERSION}.tar
# 可以选择压缩减少空间占用
gzip rust-vscode-dev-container-1.94.1-trixie-${DATE_VERSION}.tar
```

离线环境导入镜像：

```shell
# 导入之前解压
gzip -d rust-vscode-dev-container-1.94.1-trixie-${DATE_VERSION}.tar
docker load -i rust-vscode-dev-container-1.94.1-trixie-${DATE_VERSION}.tar
```

执行前先创建卷用于保存本地镜像缓存：

```shell
docker volume create rust-registry-cache
```

注意不要直接使用目录映射，因为容器内部 `/usr/local/cargo/registry` 默认是有依赖的，直接映射目录会被覆盖，但是使用卷在启动时会先将容器中的数据同步进去，后续也是向这个卷中持续写入增量的数据，后续重新启动镜像数据依然存在。

然后运行容器：

```shell
docker run -d \
    -v rust-registry-cache:/usr/local/cargo/registry \
    -v /opt/programming/rust-practice-example:/workspace/rust-practice-example \
    rust-vscode-dev-container:1.94.1-trixie-20260414
```

或者先修改 `.env` 配置项目路径，然后使用 Docker Compose 运行容器：

```shell
docker compose up -d
```

然后通过 VSCode 连接 Linux 后再连接该容器并打开项目路径即可进行开发。


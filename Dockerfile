FROM rust:1.94.0-trixie

RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' \
    /etc/apt/sources.list.d/debian.sources

RUN apt update && apt install -y \
    cmake \
    gdb \
    lld \
    clang \
    lldb \
    vim \
    bash-completion

ENV RUSTUP_DIST_SERVER="https://rsproxy.cn"
ENV RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

RUN echo '[source.crates-io]' > /usr/local/cargo/config.toml && \
    echo 'replace-with = "rsproxy-sparse"' >> /usr/local/cargo/config.toml && \
    echo '[source.rsproxy]' >> /usr/local/cargo/config.toml && \
    echo 'registry = "https://rsproxy.cn/crates.io-index"' >> /usr/local/cargo/config.toml && \
    echo '[source.rsproxy-sparse]' >> /usr/local/cargo/config.toml && \
    echo 'registry = "sparse+https://rsproxy.cn/index/"' >> /usr/local/cargo/config.toml && \
    echo '[registries.rsproxy]' >> /usr/local/cargo/config.toml && \
    echo 'index = "https://rsproxy.cn/crates.io-index"' >> /usr/local/cargo/config.toml && \
    echo '[net]' >> /usr/local/cargo/config.toml && \
    echo 'git-fetch-with-cli = true' >> /usr/local/cargo/config.toml

# 如果离线环境可以通过代理访问源则下面的依赖无需安装，否则构建产生的镜像会比较大
# 可以映射磁盘的数据目录到 /usr/local/cargo/registry 将镜像源持久化到主机
RUN rustup component add rust-analyzer rust-src clippy rustfmt && \
    # 使用 cargo-binstall 避免现场编译
    cargo install cargo-binstall && \
    cargo install cargo-edit cargo-watch cargo-expand cargo-audit
# 开启 lld 链接器
ENV RUSTFLAGS="-C link-arg=-fuse-ld=lld"
WORKDIR /workspace

CMD ["sleep", "infinity"]

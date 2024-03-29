FROM python:3.9

LABEL multi.version="1.0" multi.maintainer="takapy <takanobu.030210@gmail.com>"

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE

RUN apt-get -y update && apt-get install -y --no-install-recommends \
        curl \
        sudo \
        graphviz-dev \
        graphviz \
        mecab \
        libmecab-dev \
        mecab-ipadic \
        mecab-ipadic-utf8 \
        git \
        wget \
        g++ \
        make \
        cmake \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Timezone jst
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# nodejsの導入
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

# ipadic-neologdの導入
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
    && cd mecab-ipadic-neologd \
    && bin/install-mecab-ipadic-neologd -n -y

# jumanpp
# RUN wget https://github.com/ku-nlp/jumanpp/releases/download/v2.0.0-rc3/jumanpp-2.0.0-rc3.tar.xz && \
#     tar xvf jumanpp-2.0.0-rc3.tar.xz && \
#     cd jumanpp-2.0.0-rc3 && mkdir build && cd build && cmake .. && make install

# ENV
# Locale Japanese
# ENV LC_ALL=ja_JP.UTF-8
# tensorflowのログレベルをERRORのみに設定
ENV TF_CPP_MIN_LOG_LEVEL=2
# mecabrcが見つからないと怒られるので、環境変数MECABRCにパスを通す。(https://qiita.com/NLPingu/items/6f794635c4ac35889da6)
ENV MECABRC=/etc/mecabrc

# TA-Lib（株価分析）
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
RUN tar -zxvf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf ta-lib-0.4.0-src.tar.gz && rm -rf ta-lib

# jupyter lab
RUN python3 -m pip install -U pip && \
    python3 -m pip install jupyterlab && \
    python3 -m pip install jupyterlab-git && \
    mkdir ~/.jupyter
COPY ./jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
RUN export NODE_OPTIONS=--max-old-space-size=4096
RUN jupyter serverextension enable --py jupyterlab && \
    jupyter labextension install --no-build jupyterlab-plotly && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install luxwidget && \
    # jupyter labextension install --no-build @jupyterlab/toc && \
    # jupyter labextension install --no-build jupyterlab-flake8 && \
    # jupyter labextension install --no-build jupyterlab-topbar-extension jupyterlab-system-monitor && \
    # jupyter labextension install --no-build @jupyter-widgets/jupyterlab-manager && \
    # jupyter labextension install --no-build @jupyterlab/debugger && \
    jupyter lab build

# RUN git clone https://github.com/K-PTL/noglobal-python
RUN git clone https://github.com/facebookresearch/fastText.git && \
    cd fastText && \
    python3 -m pip install --no-deps .

COPY requirements.lock /tmp/requirements.lock
RUN python3 -m pip install -U pip && \
    python3 -m pip install --no-deps -r /tmp/requirements.lock && \
    rm /tmp/requirements.lock && \
    rm -rf /root/.cache

# takaggle
# 頻繁に更新するので個別でインストール
# RUN pip3 install -U git+https://github.com/takapy0210/takaggle@v1.0.27 && \
#     rm -rf /root/.cache

# Set up the program in the image
COPY working /opt/program/working
WORKDIR /opt/program/working

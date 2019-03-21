FROM tensorflow/tensorflow:1.12.0-gpu-py3
# set the working directory
RUN mkdir app
WORKDIR app

# download and configure miniconda
# cf. https://hub.docker.com/r/continuumio/miniconda3/dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# install code dependencies
COPY requirements.txt requirements.txt
RUN conda create --name runenv python=3.6 && \
    /opt/conda/envs/runenv/bin/pip install -r requirements.txt
# install environment dependencies
COPY "run.sh" .
COPY "train.py" .
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
# provision environment
RUN chmod +x ./run.sh
EXPOSE 8080
ENTRYPOINT ["./run.sh"]
CMD ["build"]
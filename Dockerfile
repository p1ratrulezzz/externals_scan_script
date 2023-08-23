# Use Kali Rolling release latest as the main base image
FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update package index and install kali-linux-large without recommended packages
RUN apt-get update  \
    && apt-get install -y --no-install-recommends  \
	build-essential \
	python3 \
	python3-pip \
	iputils-ping \
	dnsutils \
	nmap \
	wget \
	curl \
	git \
	sudo \
	nano \
	zip \
	musl-dev \
	unzip

# Cleanup
RUN apt-get autoremove -y && apt-get clean  &&  rm -rf /var/lib/apt/lists/*

# Install Go 1.20.7
RUN wget https://go.dev/dl/go1.20.7.linux-amd64.tar.gz  && \
    tar -C /usr/local -xzf go*.tar.gz  && \
    rm go*.tar.gz

# Adding Go paths to the PATH environment variable
ENV PATH=$PATH:/usr/local/go/bin
ENV PATH=$PATH:/root/go/bin

# Project Discovery's tools.
RUN go install github.com/xm1k3/cent@latest && \
    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && \
    go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest && \
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest && \
    go install github.com/projectdiscovery/katana/cmd/katana@latest && \
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && \
    go install github.com/tomnomnom/fff@latest && \
    go install github.com/tomnomnom/assetfinder@latest && \
    go install github.com/tomnomnom/waybackurls@latest

# Clone git repositories
RUN git clone 'https://github.com/projectdiscovery/nuclei-templates' ~/nuclei-templates
RUN cent init && cent -p cent-nuclei-templates -k

# Install requirements
RUN mkdir -p /root/script
COPY ./requirements.txt /root/script/

RUN pip3 install -r ~/script/requirements.txt

ENV PATH=$PATH:/root/script

ENTRYPOINT ["python3", "scan.py"]

WORKDIR /root/script

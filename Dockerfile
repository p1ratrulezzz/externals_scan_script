# Use Kali Rolling release latest as the main base image
FROM kalilinux/kali-rolling:latest

# Update package index and install kali-linux-large without recommended packages
# Remove junk files and apt cache
RUN apt-get clean &&  apt-get update &&  \
    apt-get full-upgrade -y &&  apt-get autoremove -y &&  \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
                        kali-linux-headless \
                        python3 \
                        python3-pip \
                        python3-venv \
                        iputils-ping \
                        nano \
                        zip \
                        unzip && \
    apt-get update && apt-get install -y gcc musl-dev && \
    apt-get clean  &&  rm -rf /var/lib/apt/lists/*

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
    
# Install pip packages
RUN pip3 install requests loguru

# Clone git repositories
RUN git clone 'https://github.com/projectdiscovery/nuclei-templates' ~/nuclei-templates && \
    cent init && cent -p cent-nuclei-templates -k && \
    git clone https://github.com/aleksey-vi/externals_scan_script ~/script
    
# Keep the container running indefinitely
ENTRYPOINT ["tail", "-f", "/dev/null"]

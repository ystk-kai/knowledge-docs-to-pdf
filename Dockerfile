# Use Ubuntu as base image
FROM ubuntu:latest

# Set timezone to Japan
RUN ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && echo Asia/Tokyo > /etc/timezone

# Update package list and install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    pandoc \
    parallel \
    ghostscript \
    fontconfig \
    texlive-xetex

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    echo 'eval "$(starship init bash)"' >> ~/.bashrc

# Install Noto Sans font
RUN apt-get install -y fonts-noto fonts-noto-color-emoji

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


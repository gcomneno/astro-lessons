# Usa un'immagine di Ubuntu 20.04 come base
FROM ubuntu:20.04

# Define the project directory path as an environment variable
ENV WORKSPACE_DIR=/usr/src/astro-ws

# Create the project directory within the container
RUN mkdir -p $WORKSPACE_DIR

# Set the working directory to the project directory
WORKDIR $WORKSPACE_DIR

# Copy the project files from the host machine to the container
COPY . $WORKSPACE_DIR

# Aggiorna l'elenco dei pacchetti e installa le dipendenze necessarie (curl)
RUN apt-get update && \
    apt-get install -y curl

# Download & Installa Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs npm

# Install npm

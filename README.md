An ASTRO framework dockerized workspace for your own Astro Projects!

This repository contains a minimal Astro example together with a Dockerfile and Makefile.
It is intended to provide a quick way to spin up a containerized Astro development environment.

## Build the Docker image
Run `make build` from the repository root to build the Docker image (`astro_image`).

## Run the container
Start the environment with `make run`. This mounts the `app/` directory inside the container. The Astro dev server uses port 4321; map this port (e.g. `-p 4321:4321`) when running the container if you want to access it from your browser.

## Developing
Edit files under `app/` and run `npm install` followed by `npm run dev` inside the container. Once the server is running you can open `http://localhost:4321` (if the port is mapped) to see your changes.

## Licensed under the MIT License. See [LICENSE](LICENSE) for details.

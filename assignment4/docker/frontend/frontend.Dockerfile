# Frontend image is based on the official nginx image from the repository (Dockerhub)
FROM nginx:latest
# Copy the frontend configuration file into the frontend image
COPY docker/frontend/frontend.nginx.conf /etc/nginx/frontend.nginx.conf
# make the container listen to (TCP) port 80 at runtime
EXPOSE 80
# Backend image is based on the official nginx image from the repository (Dockerhub)
FROM nginx:latest
# Copy the backend configuration file into the backend image
COPY docker/backend/backend.nginx.conf /etc/nginx/backend.nginx.conf
# make the container listen to (TCP) port 80 at runtime
EXPOSE 80
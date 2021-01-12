FROM nginx:stable-alpine-perl
COPY backend.nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

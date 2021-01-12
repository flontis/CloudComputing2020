FROM nginx:stable-alpine-perl
COPY frontend.nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

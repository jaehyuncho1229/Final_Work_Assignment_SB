FROM nginx:latest

COPY ./index.html /usr/share/nginx/html/index.html

# docker run -d --name web-server-2 -p 8081:80 -v /usr/share/nginx/html nginx:custom
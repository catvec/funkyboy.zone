FROM nginx:1.27.5

COPY ./www/ /usr/share/nginx/html
COPY ./nginx-conf.d/ /etc/nginx/conf.d
RUN rm /etc/nginx/conf.d/default.conf

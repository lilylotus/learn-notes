FROM redis:5.0.14-bullseye

COPY sentinel1.conf /usr/local/etc/redis/sentinel.conf

CMD ["redis-sentinel", "/usr/local/etc/redis/sentinel.conf"]
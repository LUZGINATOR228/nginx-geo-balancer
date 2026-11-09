FROM nginx:1.27 as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    libmaxminddb-dev

COPY ngx_http_geoip2_module /opt/ngx_http_geoip2_module
COPY nginx /opt/nginx

RUN cd /opt/nginx \
    && auto/configure --with-compat --add-dynamic-module=/opt/ngx_http_geoip2_module \
    && make modules

FROM nginx:1.27

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmaxminddb0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/nginx/objs/ngx_http_geoip2_module.so /usr/lib/nginx/modules/


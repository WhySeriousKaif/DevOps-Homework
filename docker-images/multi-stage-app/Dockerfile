# Stage 1: Build stage
FROM node:18-alpine AS builder
WORKDIR /build
RUN echo '<!DOCTYPE html><html><head><title>Multi-Stage Build</title></head><body><h1>Hello World from Docker multi-stage build</h1></body></html>' > index.html

# Stage 2: Minimal production runtime stage
FROM nginx:alpine
COPY --from=builder /build/index.html /usr/share/nginx/html/index.html
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf 2>/dev/null || sed -i 's/80;/8080;/g' /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

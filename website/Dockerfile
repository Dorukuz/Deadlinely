FROM alpine:3.20 AS builder
WORKDIR /app
COPY . .
RUN chmod +x build.sh && ./build.sh

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/dist .
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

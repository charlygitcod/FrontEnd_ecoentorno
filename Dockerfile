# Etapa 1: Construir la aplicación
FROM node:18-slim AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de dependencias
COPY package*.json ./

# Instala las dependencias
RUN npm install

# Copia el resto del proyecto
COPY . .

# Construye el proyecto de producción
RUN npm run build

# Etapa 2: Servir la aplicación
FROM nginx:alpine

# Copia la build
COPY --from=build /app/dist /usr/share/nginx/html

# Instala envsubst para reemplazar variables de entorno
RUN apk add --no-cache gettext

# Crea la carpeta de templates primero
RUN mkdir -p /etc/nginx/templates

# Ahora sí, crea el template de configuración
RUN printf 'server {\n\
    listen ${PORT};\n\
    server_name localhost;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/templates/default.conf.template

# Expone un puerto (Railway igual inyecta el real)
EXPOSE 8080

# Comando de inicio: reemplazar variables de entorno y correr nginx
CMD ["sh", "-c", "envsubst < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]

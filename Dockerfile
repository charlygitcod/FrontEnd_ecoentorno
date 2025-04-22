# Etapa 1: Construir la aplicación
FROM node:18-slim AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de dependencias
COPY package*.json ./

# Instala las dependencias
RUN npm install

# Copia el resto de los archivos del proyecto
COPY . .

# Construye la aplicación para producción
RUN npm run build

# Etapa 2: Servir la aplicación
FROM nginx:alpine

# Copia la build desde la etapa anterior
COPY --from=build /app/dist /usr/share/nginx/html

# Expone el puerto
EXPOSE 8081

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]

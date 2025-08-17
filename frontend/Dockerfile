# Stage 1: build
FROM node:18-alpine AS build

WORKDIR /app

# copy dependency manifests
COPY package.json package-lock.json* ./

# install dependencies
RUN npm install

# copy rest of the frontend
COPY . .

# build vite app for production (optional, if you want nginx serve later)
RUN npm run build

# Stage 2: dev server (Vite)
FROM node:18-alpine

WORKDIR /app

# copy node_modules from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app ./

EXPOSE 8443

CMD ["npm", "run", "dev", "--", "--host", "--port", "8443"]

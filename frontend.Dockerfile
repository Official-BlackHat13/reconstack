FROM node:18-alpine

# Set working dir
WORKDIR /app

# Install deps
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

# Copy code
COPY frontend/ .

# Expose frontend port
EXPOSE 8443

# Run dev server (for prod we’d do npm run build + serve)
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "8443"]

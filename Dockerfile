# --- Stage 1: Builder ---
    FROM node:latest AS builder

    WORKDIR /app
    
    # Copy the full repo
    COPY . .
    
    # Install dependencies
    RUN npm install
    
    # Build all apps
    RUN npm run build --filter=web --filter=docs
    
    # --- Stage 2: Runner ---
    FROM node:latest AS runner
    
    WORKDIR /app
    
    # Copy all built apps
    COPY --from=builder /app/apps/web/dist ./dist/web
    COPY --from=builder /app/apps/docs/dist ./dist/docs
    
    # Serve them with Bun static server
    # We will merge into one folder structure so Bun can serve SPA routes
    RUN mkdir -p ./dist/root && cp -r ./dist/web/* ./dist/root/
    
    EXPOSE 3000
    
    # Serve root (web), /second, /third using static files
    CMD ["npm", "x", "serve", "./dist", "--port", "3000"]
    
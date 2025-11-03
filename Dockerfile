# --- Stage 1: Builder ---
    FROM oven/bun:1 AS builder

    WORKDIR /app
    
    # Copy the full repo
    COPY . .
    
    # Install dependencies
    RUN bun install
    
    # Build all apps
    RUN bun run build --filter=web --filter=second --filter=third
    
    # --- Stage 2: Runner ---
    FROM oven/bun:1 AS runner
    
    WORKDIR /app
    
    # Copy all built apps
    COPY --from=builder /app/apps/web/dist ./dist/web
    COPY --from=builder /app/apps/second/dist ./dist/second
    COPY --from=builder /app/apps/third/dist ./dist/third
    
    # Serve them with Bun static server
    # We will merge into one folder structure so Bun can serve SPA routes
    RUN mkdir -p ./dist/root && cp -r ./dist/web/* ./dist/root/
    
    EXPOSE 3000
    
    # Serve root (web), /second, /third using static files
    CMD ["bun", "x", "serve", "./dist", "--port", "3000"]
    
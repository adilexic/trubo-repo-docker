# --- Stage 1: Builder ---
    FROM oven/bun:1 AS builder
    WORKDIR /app
    
    COPY . .
    
    # Set build target (default: web)
    ARG APP_NAME=web
    
    RUN bun install 
    RUN bun run build --filter=${APP_NAME}
    
    # --- Stage 2: Runner ---
    FROM oven/bun:1 AS runner
    WORKDIR /app
    
    # Copy built output
    COPY --from=builder /app/apps/${APP_NAME}/dist ./dist
    
    # Serve static files with Bun
    CMD ["bun", "x", "serve", "dist"]
    
    EXPOSE 3000
    
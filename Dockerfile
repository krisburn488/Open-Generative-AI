FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies
FROM base AS deps
RUN apk add --no-cache git
RUN git clone https://github.com/SamurAIGPT/Vibe-Workflow.git packages/Vibe-Workflow \
    && git -C packages/Vibe-Workflow checkout 4fed75125da0c9bb9d94ad18f0b7746ed6531a9f \
    && git clone https://github.com/Anil-matcha/Open-Poe-AI.git packages/Open-Poe-AI \
    && git -C packages/Open-Poe-AI checkout 0e9f0c23f39cf9e4e955c047356ac5e7b99c523 \
    && git clone https://github.com/Anil-matcha/Open-AI-Design-Agent.git packages/Open-AI-Design-Agent \
    && git -C packages/Open-AI-Design-Agent checkout e179fe1a6c47b26ee6afac9128155d9f259a5d14
COPY package*.json ./
RUN npm install

# Build sub-packages
FROM deps AS builder
COPY . .
RUN npm run build:packages
RUN npm run build

# Production runner
FROM base AS runner
ENV NODE_ENV=production
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000
CMD ["npm", "start"]

# Stage 1: Installing dependencies
FROM node:current-alpine AS deps
WORKDIR /app
COPY package.json ./
COPY .env.local ./
RUN npm install
COPY . .

# Stage 2: Building App
FROM deps AS build
ENV NODE_ENV=production
WORKDIR /build
COPY --from=deps /app ./
RUN npm run build

# Stage 3: Production build
FROM node:current-alpine AS prod
ENV NODE_ENV=production
WORKDIR /app

COPY --from=build /build/public ./public
COPY --from=build /build/package*.json ./
COPY --from=build /build/.next ./.next
COPY --from=build /build/static ./static
COPY --from=build /build/firebase ./firebase
COPY --from=build /build/.env.local ./.env.local
RUN npm install next

EXPOSE 3000

CMD ["npm", "start"]
ARG NODE_VERSION=22.9.0
FROM node:$NODE_VERSION as base

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Pass the build argument and set it as an environment variable
ARG NEXT_PUBLIC_API_BASE_URL
ENV NEXT_PUBLIC_API_BASE_URL=${NEXT_PUBLIC_API_BASE_URL}

RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
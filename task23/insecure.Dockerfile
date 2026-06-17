
FROM node:20
ENV API_SECRET_KEY="super_secret_admin_token"

WORKDIR /app
COPY package.json .
RUN npm install
COPY . .


EXPOSE 8080
CMD ["npm", "start"]
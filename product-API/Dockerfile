FROM --platform=linux/amd64 node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 80
CMD ["npm", "start"]

# 영주님은 --platform=linux/amd64 빼고 하셔야할 수도 있습니다.
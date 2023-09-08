FROM node:latest

# Setting the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

RUN npm install --ignore-scripts

RUN npm install -g patch-package

EXPOSE 8080

# Copying the rest of the application source code to the working directory
COPY . .

# Manually applied patches and build CSS
RUN patch-package && npm run scss

# Defining the command to start our Node.js application
CMD ["node", "app.js"]

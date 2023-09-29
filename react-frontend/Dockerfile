# Use an official Node.js runtime as the base image
FROM node:16

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY react-frontend/package*.json ./

# Install the project dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY react-frontend/. .

# Build your React application (you may need to adjust this based on your project)
RUN npm run build

# Define the command to start your application
CMD ["npm", "start"]

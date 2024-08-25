# Stage 1: Build the Flutter web app
FROM cirrusci/flutter:stable AS build

# Set the working directiory
WORKDIR /app

# Copy the pubspec and pubspec.lock files to fetch dependencies
COPY pubspect.* ./

# Fetch dependencies
RUN flutter pub get

# Copy the rest of the Flutter project files
COPY . .

# Build the Flutter app for the web
RUN flutter build web

# Stage 2: Serve the Flutter web app using an NGINX server
FROM nginx:alpine

# Copy the build output from the previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose the port NGINX will run on
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
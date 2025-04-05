FROM docker.io/amazoncorretto:17-alpine

WORKDIR /app

# Install required packages
RUN apk add --no-cache bash curl unzip

# Copy Gradle build files
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle
COPY gradlew ./

# Copy Smithy model files
COPY model ./model
COPY smithy-build.json ./

# Make gradlew executable
RUN chmod +x ./gradlew

# Optional - speeds up builds by caching Gradle dependencies
RUN ./gradlew --no-daemon dependencies

# The actual build will happen when the container runs
ENTRYPOINT ["./gradlew", "build"]
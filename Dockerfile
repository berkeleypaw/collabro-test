FROM maven:3.8.4-openjdk-17-slim AS build

# Update package lists and upgrade installed packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the Maven project files into the container
COPY . .

# Build the Maven project
RUN mvn clean install
RUN mvn dependency:copy-dependencies

# Use a smaller image for deployment
FROM openjdk:26-slim@sha256:16693571bfb14c180f7bac28a211357248f0374f4e61d5936db9df9f6bacd065

LABEL org.opencontainers.image.base.name="openjdk:26-slim@sha256:16693571bfb14c180f7bac28a211357248f0374f4e61d5936db9df9f6bacd065"

# Update package lists and upgrade installed packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the built artifact from the build stage
COPY --from=build /app/target/endor-java-webapp-demo.jar .
COPY --from=build /app/target/endor-java-webapp-demo-jar-with-dependencies.jar .
# Expose any necessary ports
EXPOSE 443

# Set the command to run your application
CMD ["java", "-jar", "endor-java-webapp-demo.jar"]

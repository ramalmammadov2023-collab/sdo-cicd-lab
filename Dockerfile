FROM gcc:14.2 AS build

# Create the folder /app and work inside it.
WORKDIR /app
COPY expo.c .

# Compile the code into a program called expo.
RUN gcc -static -o expo expo.c -lm

FROM scratch
ARG VERSION=1.0
LABEL version="${VERSION}"
COPY --from=build /app/expo /expo

# Run as a non-root user (65534 = "nobody")
USER 65534:65534

# When the container starts, run /expo. 
# Any arguments you pass to docker run like 2 10 are handed to it.
ENTRYPOINT ["/expo"]

FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

# Copy the server script and web export files
COPY server.py .
COPY . ./web/

# Expose the default port
EXPOSE 8000

# Set working directory to web folder where the export files are
WORKDIR /app/web

# Run the server
CMD ["python3", "../server.py"]

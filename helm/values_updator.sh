#!/bin/bash

# Assuming NEW_IMAGE_TAG contains the new tag retrieved from the build process
ACR_NAME="testacr"
IMG_REPO_NAME="img"
NEW_IMAGE_TAG=$(az acr repository show-tags --name $ACR_NAME --repository $IMG_REPO_NAME --output tsv --orderby time_desc | head -n 1)
echo "Latest image tag: $NEW_IMAGE_TAG"

# Path to your values.yaml file
VALUES_FILE="./backend/values.yaml"

# Update the image tag in values.yaml
sed -i "s|tag:.*|tag: $NEW_IMAGE_TAG|" $VALUES_FILE

echo "script ran successfully!"

#!/bin/bash
set -e

# Variables (update these as needed)
REPO_NAME="wordpress-helm-chart"
AWS_REGION="us-east-1"  # Change to your AWS region
REPO_URL="https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/${REPO_NAME}"
LOCAL_CHART_FOLDER="wordpress"  # relative path to your wordpress folder

# Clone the empty CodeCommit repository (it uses the default branch specified in Terraform, e.g., dev)
git clone ${REPO_URL}
cd ${REPO_NAME}

# Ensure we are on the default branch (dev)
git checkout -B dev

# Copy the wordpress chart folder from your local terraform code location into the repo
# Adjust the source path if necessary
cp -R ../${LOCAL_CHART_FOLDER} .

# Add, commit, and push the changes on dev branch
git add ${LOCAL_CHART_FOLDER}
git commit -m "Add WordPress Helm chart"
git push -u origin dev

# Get the latest commit ID from the dev branch
LATEST_COMMIT=$(git rev-parse HEAD)

# Create the prod branch using AWS CLI (this uses the commit ID from dev)
aws codecommit create-branch --repository-name ${REPO_NAME} --branch-name prod --commit-id ${LATEST_COMMIT} --region ${AWS_REGION}

echo "Both dev and prod branches have been set up and your wordpress chart has been uploaded."


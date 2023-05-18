# COSC2759 Assignment 2

## Student details

- Full Name: **Nushura Islam**
- Student ID: **s3796107**

## Steps taken for SECTION A

1. Changed credentials file

2. Created a feature branch for answering **section A question 2** called --> **'feature/terraform-deploy-infrastructure'**

3. Created a key folder inside app --> cosc2759-assignment-2-Nushura/app/key

4. Generated public and private keys by this command --> **ssh-keygen**

5. Created a new folder inside app to build the EC2 instances infrastructure --> cosc2759-assignment-2-Nushura/app/infra

6. Then the following created files and populated it with respective codes
    - main.tf (This is the main file responsible for building the infrastructure of EC2 instance)
    - .gitignore
    - vars.tf
    - you.auto.tfvars

7. The changed directory to go inside app/infra folder followed by doing
    - **terraform init** --> to download AWS provider + initialize working directory
    - **terraform validate** --> to check for syntax errors
    - **terraform apply** --> to run + make changes in AWS (This goes and actually created the instances in AWS)


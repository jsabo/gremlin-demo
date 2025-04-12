# Deploying Cloud Foundry on AWS with BOSH Bootloader

This repository provides step-by-step instructions to deploy Cloud Foundry on AWS using BOSH Bootloader (bbl) along with BOSH, Terraform, and cf-deployment. It also shows how to install the CredHub CLI.

> **Note:** These instructions assume you are running on an Ubuntu machine and have your AWS credentials ready.

---

## Prerequisites

### 1. Update System & Install Build Dependencies

Update your package lists and install the required build dependencies:

```bash
sudo apt update && sudo apt install -y \
  build-essential \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  libffi-dev \
  ruby-full
```

---

## Installing Core Tools

### 2. Install Terraform

Download and install Terraform (example uses version **1.11.4**):

```bash
wget https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip
unzip terraform_1.11.4_linux_amd64.zip
chmod +x terraform
rm terraform_1.11.4_linux_amd64.zip
```

> **Optional:** Move Terraform to a directory in your `PATH`:
>
> ```bash
> sudo mv terraform /usr/local/bin/
> ```

### 3. Install bosh-cli

Download and set up the BOSH CLI (example uses version **7.9.4**):

```bash
wget https://github.com/cloudfoundry/bosh-cli/releases/download/v7.9.4/bosh-cli-7.9.4-linux-amd64
chmod +x bosh-cli-7.9.4-linux-amd64
sudo mv bosh-cli-7.9.4-linux-amd64 /usr/local/bin/bosh
```

### 4. Install bosh-bootloader (bbl)

Download the bosh-bootloader binary (example uses version **9.0.32**):

```bash
wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v9.0.32/bbl-v9.0.32_linux_amd64.tgz
tar -zxvf bbl-v9.0.32_linux_amd64.tgz
chmod +x bbl
sudo mv bbl /usr/local/bin/
rm bbl-v9.0.32_linux_amd64.tgz
```

---

## Install the CredHub CLI

Cloud Foundry uses CredHub for secrets management. To interact with CredHub, install the CredHub CLI. For example, to install version **2.9.44** on Linux:

```bash
wget https://github.com/cloudfoundry/credhub-cli/releases/download/2.9.44/credhub-linux-amd64-2.9.44.tgz
tar -zxvf credhub-linux-amd64-2.9.44.tgz
sudo mv credhub /usr/local/bin/credhub
rm credhub-linux-amd64-2.9.44.tgz
```

Verify the installation by checking its version:

```bash
credhub --version
```

---

## Deploying the BOSH Director on AWS

### 5. Deploy the BOSH Environment

Run the following command to create your BOSH environment on AWS. Make sure your AWS credentials are set (using environment variables, for example):

```bash
bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
       --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
       --aws-region us-east-1 \
       --iaas aws
```

This command provisions a new BOSH director.

### 6. Log In to BOSH

After your BOSH environment is up, export its environment variables and log in:

```bash
eval "$(bbl print-env)"
export BOSH_ENVIRONMENT=$(bbl director-address)
bosh log-in
```

---

## Pre-Cloud Foundry Deployment Setup

### 7. Verify Your BOSH Environment

Use these commands to see what’s currently configured:

- **List VMs**  
  ```bash
  bosh vms
  ```

- **Show Director Info**  
  ```bash
  bosh env
  ```

- **List Deployments**  
  ```bash
  bosh deployments
  ```

- **List Stemcells**  
  ```bash
  bosh stemcells
  ```

- **List Releases**  
  ```bash
  bosh releases
  ```

- **Show Runtime Config**  
  ```bash
  bosh runtime-config
  ```

- **List Running Tasks**  
  ```bash
  bosh tasks
  ```

At this point, your director may be “empty” aside from the internal system releases, which is expected.

### 8. Cloud Config and Stemcell Upload

Before deploying Cloud Foundry, update your cloud config and upload an appropriate stemcell.

#### Upload a Stemcell

Cloud Foundry requires a compatible stemcell. For example, to upload an Ubuntu stemcell:

```bash
bosh upload-stemcell <path-to-stemcell.tgz>
```

Consult [cf-deployment documentation](https://github.com/cloudfoundry/cf-deployment) for the required stemcell details.

#### Update Cloud Config

If you need to update your cloud config, prepare your YAML file (e.g., `cloud-config.yml`) and run:

```bash
bosh update-cloud-config cloud-config.yml
```

---

## Deploying Cloud Foundry

### 9. Clone cf-deployment Repository

Clone the official Cloud Foundry deployment repository:

```bash
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
```

### 10. Deploy Cloud Foundry

After ensuring your stemcell and cloud config are in place, deploy Cloud Foundry by merging the base manifest with required ops files. An example command (adjust ops files as needed) might be:

```bash
bosh -e <director-alias> -d cf deploy cf-deployment.yml \
  -v system_domain=<your-system-domain> \
  -o operations/aws.yml \
  -o operations/uaa.yml \
  -o operations/experimental/use-compiled-releases.yml \
  -n
```

---

## Post-Deployment

### 11. Retrieve CF Credentials and Login

To obtain the initial admin password from CredHub:

```bash
credhub find -n cf_admin_password
credhub get -n /bosh-bbl-env-<your-env-name>/cf/cf_admin_password
```

Then target your Cloud Foundry API and log in:

```bash
cf api https://api.<your-system-domain> --skip-ssl-validation
cf create-space <space-name>
cf target -o "system" -s "<space-name>"
```

---

## Reference Documentation

- [BOSH Bootloader Getting Started on AWS](https://cloudfoundry.github.io/bosh-bootloader/getting-started-aws/)
- [cf-deployment Deployment Guide](https://github.com/cloudfoundry/cf-deployment/blob/main/texts/deployment-guide.md)
- [BOSH CLI Documentation](https://bosh.io/docs/cli-v2/)
- [CredHub CLI Releases](https://github.com/cloudfoundry/credhub-cli/releases)

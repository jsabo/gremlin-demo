# Deploying Cloud Foundry on AWS with BOSH Bootloader

This repository provides step-by-step instructions to deploy Cloud Foundry on AWS using BOSH Bootloader (bbl) along with BOSH and cf-deployment.

> **Note:** These instructions assume you are running on an Ubuntu machine and have AWS credentials prepared.

---

## Prerequisites

### 1. Update System & Install Build Dependencies

Update your package lists and install necessary build dependencies including development libraries and Ruby:

```bash
sudo apt update && sudo apt install \
  build-essential \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  libffi-dev \
  ruby-full \
  -y
```

---

## BOSH Bootloader (bbl) and Supporting Tools

### 2. Install Terraform

Download and install Terraform. In this example we’re using Terraform version **1.11.4**:

```bash
curl -L -o terraform.zip https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip
unzip -p terraform.zip terraform > terraform && chmod +x terraform
rm -f terraform.zip
```

### 3. Install bosh-cli

Download and make executable the BOSH CLI (version **7.9.4** is used here):

```bash
curl -L -o bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v7.9.4/bosh-cli-7.9.4-linux-amd64
chmod +x bosh
```

### 4. Install bosh-bootloader (bbl)

Download the bosh-bootloader binary (version **9.0.32** in this example):

```bash
curl -L -o bbl https://github.com/cloudfoundry/bosh-bootloader/releases/download/v9.0.32/bbl-v9.0.32_linux_amd64
chmod +x bbl
```

> **Tip:** To make these binaries available system-wide, move them (along with Terraform) to `/usr/local/bin`:
>
> ```bash
> sudo mv bbl bosh terraform /usr/local/bin/
> ```

---

## Deploying the BOSH Director on AWS

### 5. Deploy the BOSH Environment

Run the following command to create a new BOSH environment on AWS. Make sure to set your AWS credentials in the environment variables:

```bash
bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
       --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
       --aws-region us-east-1 \
       --iaas aws
```

This command deploys a new BOSH director.

### 6. Log In to BOSH

After deployment, export the environment variables and log in:

```bash
eval "$(bbl print-env)"
export BOSH_ENVIRONMENT=$(bbl director-address)
bosh log-in
```

### 7. (Optional) Setup Load Balancers with Self-Signed Certificates

If you plan to use load balancers with Cloud Foundry (e.g. for the CF API), create self-signed certificates using openssl:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout sabo.gremlin.rocks.key \
  -out sabo.gremlin.rocks.crt \
  -subj "/CN=sabo.gremlin.rocks"
```

With the certificates ready, plan the environment with the load balancer settings:

```bash
bbl plan --lb-type cf \
         --lb-cert sabo.gremlin.rocks.crt \
         --lb-key sabo.gremlin.rocks.key \
         --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
         --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
         --lb-domain sabo.gremlin.rocks
```

Then update your environment with the load balancer configuration:

```bash
bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
       --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
       --aws-region us-east-1 \
       --iaas aws
```

---

## Deploying Cloud Foundry

### 8. Clone cf-deployment Repository

Clone the cf-deployment Git repository:

```bash
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
```

### 9. Upload a Stemcell

Cloud Foundry requires a stemcell (virtual machine image). First, set your IAAS information and fetch the default stemcell version from the manifest:

```bash
export IAAS_INFO=aws-xen-hvm
export STEMCELL_VERSION=$(bosh interpolate cf-deployment.yml --path="/stemcells/alias=default/version")
```

Then, upload the corresponding stemcell from BOSH.io. (Adjust the URL if necessary based on your cf-deployment requirements):

```bash
bosh upload-stemcell "https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-jammy-go_agent?v=${STEMCELL_VERSION}"
```

### 10. Deploy Cloud Foundry

Set your system domain, alias your BOSH environment, and deploy cf-deployment using the merged manifest and ops files:

```bash
export SYSTEM_DOMAIN=sys.sabo.gremlin.rocks
bosh alias-env bosh-1

bosh -e bosh-1 -d cf deploy cf-deployment.yml \
  -v system_domain=$SYSTEM_DOMAIN \
  -o operations/use-compiled-releases.yml \
  -o operations/experimental/fast-deploy-with-downtime-and-danger.yml \
  -o operations/aws.yml \
  -o operations/enable-privileged-container-support.yml \
  -o operations/scale-to-one-az.yml \
  -n
```

> **Note:** The ops files used above are examples. Adjust them based on your AWS settings and deployment strategy.

---

## Post-Deployment

### 11. Retrieve CF Credentials and Login

To get the initial admin password from CredHub:

```bash
credhub find -n cf_admin_password
credhub get -n /bosh-bbl-env-<your-env-name>/cf/cf_admin_password
```

Then target your Cloud Foundry API and login:

```bash
cf api https://api.sys.sabo.gremlin.rocks --skip-ssl-validation
cf create-space sabo
cf target -o "system" -s "sabo"
```

---

## BOSH CLI Commands for Environment Inspection

After deploying, you can use these BOSH commands to inspect your deployment:
- **List VMs:**  
  ```bash
  bosh vms
  ```
- **Show Environment Info:**  
  ```bash
  bosh env
  ```
- **List Deployments:**  
  ```bash
  bosh deployments
  ```
- **List Stemcells:**  
  ```bash
  bosh stemcells
  ```
- **List Releases:**  
  ```bash
  bosh releases
  ```
- **Show Runtime Config:**  
  ```bash
  bosh runtime-config
  ```
- **List Tasks:**  
  ```bash
  bosh tasks
  ```

These commands help you verify the current state of your director before deploying Cloud Foundry.

---

## Reference Documentation

- [BOSH Bootloader Getting Started on AWS](https://cloudfoundry.github.io/bosh-bootloader/getting-started-aws/)
- [cf-deployment Deployment Guide](https://github.com/cloudfoundry/cf-deployment/blob/main/texts/deployment-guide.md)
- [BOSH CLI Documentation](https://bosh.io/docs/cli-v2/)

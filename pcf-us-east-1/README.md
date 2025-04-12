# Deploying Cloud Foundry on AWS with BOSH Bootloader

This guide provides step‑by‑step instructions to deploy Cloud Foundry on AWS using BOSH Bootloader (bbl), BOSH, and cf‑deployment. The instructions assume you’re running on Ubuntu with your AWS credentials available.

## Prerequisites

### 1. Update the System & Install Build Dependencies

Update your package lists and install the necessary build dependencies and Ruby:

```bash
sudo apt update && sudo apt install -y \
  build-essential \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  libffi-dev \
  ruby-full
```

## Tool Installation

### 2. Install Terraform (v1.11.4)

Download, unzip, and set permissions for Terraform:

```bash
curl -L -o terraform.zip "https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip"
unzip -p terraform.zip terraform > terraform
chmod +x terraform
rm terraform.zip
```

### 3. Install the BOSH CLI (v7.9.4)

Download and make the BOSH CLI executable:

```bash
curl -L -o bosh "https://github.com/cloudfoundry/bosh-cli/releases/download/v7.9.4/bosh-cli-7.9.4-linux-amd64"
chmod +x bosh
```

### 4. Install BOSH Bootloader (bbl, v9.0.32)

Download and install the bbl binary:

```bash
curl -L -o bbl "https://github.com/cloudfoundry/bosh-bootloader/releases/download/v9.0.32/bbl-v9.0.32_linux_amd64"
chmod +x bbl
```

> **Tip:** To make these binaries available system‑wide, move them to `/usr/local/bin/`:
> 
> ```bash
> sudo mv bbl bosh terraform /usr/local/bin/
> ```

### 5. Install the CredHub CLI (v2.9.44)

Cloud Foundry uses CredHub for secrets management. Install the CredHub CLI with:

```bash
curl -L "https://github.com/cloudfoundry/credhub-cli/releases/download/2.9.44/credhub-linux-amd64-2.9.44.tgz" | tar -zxvf - && sudo mv credhub /usr/local/bin/
```

Verify the installation:

```bash
credhub --version
```

### 6. Install the Cloud Foundry CLI (Linux)

Run these commands to download, extract, and install the Cloud Foundry CLI:

```bash
# Download and extract the Linux 64-bit CLI (v8)
curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v8&source=github" | tar -zx

# Move the 'cf8' binary and its 'cf' symlink to /usr/local/bin (or a directory in your $PATH)
sudo mv cf8 /usr/local/bin
sudo mv cf /usr/local/bin

# Install Bash tab completion for cf on Ubuntu (takes effect after restarting your shell)
sudo curl -o /usr/share/bash-completion/completions/cf8 https://raw.githubusercontent.com/cloudfoundry/cli-ci/master/ci/installers/completion/cf8

# Confirm the installation by checking the cf CLI version
cf version
```

## Deploying the BOSH Director on AWS

### 7. Deploy the BOSH Environment

Make sure your AWS credentials are set as environment variables, then run:

```bash
bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
       --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
       --aws-region us-east-1 \
       --iaas aws
```

### 8. Log In to BOSH

After the director is deployed, export the environment variables and log in:

```bash
eval "$(bbl print-env)"
export BOSH_ENVIRONMENT=$(bbl director-address)
bosh log-in
```

### 9. Set Up Load Balancers with Self‑Signed Certificates

If you require a load balancer (for example, to expose the Cloud Foundry API), follow these steps:

#### a. Create Self‑Signed Certificates

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout sabo.gremlin.rocks.key \
  -out sabo.gremlin.rocks.crt \
  -subj "/CN=sabo.gremlin.rocks"
```

#### b. Plan the Environment with Load Balancer Settings

```bash
bbl plan --lb-type cf \
         --lb-cert sabo.gremlin.rocks.crt \
         --lb-key sabo.gremlin.rocks.key \
         --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
         --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
         --lb-domain sabo.gremlin.rocks
```

#### c. Update the Environment

```bash
bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID \
       --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY \
       --aws-region us-east-1 \
       --iaas aws
```

## Deploying Cloud Foundry

### 10. Clone the cf-deployment Repository

```bash
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
```

### 11. Upload a Stemcell

Cloud Foundry requires a stemcell (a virtual machine image). First, set your IAAS information and fetch the default stemcell version from the manifest:

```bash
export IAAS_INFO=aws-xen-hvm
export STEMCELL_VERSION=$(bosh interpolate cf-deployment.yml --path="/stemcells/alias=default/version")
```

Then, upload the corresponding stemcell (adjust the URL if necessary):

```bash
bosh upload-stemcell "https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-jammy-go_agent?v=${STEMCELL_VERSION}"
```

### 12. Deploy Cloud Foundry

Set your system domain, alias your BOSH environment, and deploy cf-deployment with your chosen ops files:

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

> **Note:** The ops files above are examples. Adjust them as needed for your AWS settings and deployment strategy.

### 13. Retrieve CF Credentials and Log In

#### a. Get the Initial Admin Password from CredHub

```bash
credhub find -n cf_admin_password
credhub get -n /bosh-bbl-env-<your-env-name>/cf/cf_admin_password
```

#### b. Target the Cloud Foundry API and Log In

```bash
cf api https://api.sys.sabo.gremlin.rocks --skip-ssl-validation
cf create-space sabo
cf target -o "system" -s "sabo"
```

## BOSH CLI Environment Inspection Commands

Use these commands to check the state and configuration of your director before or after deploying Cloud Foundry:

- **List VMs:**

  ```bash
  bosh vms
  ```

- **Display Environment Information:**

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

## References

- [BOSH Bootloader Getting Started on AWS](https://cloudfoundry.github.io/bosh-bootloader/getting-started-aws/)
- [cf-deployment Deployment Guide](https://github.com/cloudfoundry/cf-deployment/blob/main/texts/deployment-guide.md)
- [BOSH CLI Documentation](https://bosh.io/docs/cli-v2/)


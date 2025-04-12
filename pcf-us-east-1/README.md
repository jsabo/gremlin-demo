# Deploying Cloud Foundry on AWS

## Deploy BOSH on AWS

### Install build deps
sudo apt update && sudo apt install build-essential zlib1g-dev libssl-dev libreadline-dev libffi-dev ruby-full -y

### Install terraform
curl -L -o terraform.zip https://releases.hashicorp.com/terraform/1.11.4/terraform_1.11.4_linux_amd64.zip
unzip -p terraform.zip terraform > terraform && chmod +x terraform
rm -f terraform.zip

### Install bosh-cli
curl -L -o bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v7.9.4/bosh-cli-7.9.4-linux-amd64 && chmod +x bosh

### Install bosh-bootloader
curl -L -o bbl https://github.com/cloudfoundry/bosh-bootloader/releases/download/v9.0.32/bbl-v9.0.32_linux_amd64 && chmod +x bbl
sudo mv bbl bosh terraform /usr/local/bin/

### Deploy
bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY --aws-region us-east-1 --iaas aws

### Login
eval "$(bbl print-env)"
export BOSH_ENVIRONMENT=$(bbl director-address)
bosh log-in

### Setup loadbalancers
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout sabo.gremlin.rocks.key \
  -out sabo.gremlin.rocks.crt \
  -subj "/CN=sabo.gremlin.rocks"

bbl plan --lb-type cf --lb-cert sabo.gremlin.rocks.crt --lb-key sabo.gremlin.rocks.key --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY --lb-domain sabo.gremlin.rocks

bbl up --aws-access-key-id $BBL_AWS_SECRET_ACCESS_KEY_ID --aws-secret-access-key $BBL_AWS_SECRET_ACCESS_KEY --aws-region us-east-1 --iaas aws

## Deploying Cloud Foundry

### Clone cf-deployment
git clone https://github.com/cloudfoundry/cf-deployment.git

### Upload Stemcells
export IAAS_INFO=aws-xen-hvm
export STEMCELL_VERSION=$(bosh interpolate cf-deployment/cf-deployment.yml --path=/stemcells/alias=default/version)
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-jammy-go_agent?v=${STEMCELL_VERSION}

### Deploy
export SYSTEM_DOMAIN=sys.sabo.gremlin.rocks
bosh alias-env bosh-1

bosh -e bosh-1 -d cf deploy cf-deployment/cf-deployment.yml -v system_domain=$SYSTEM_DOMAIN -o cf-deployment/operations/use-compiled-releases.yml -o cf-deployment/operations/experimental/fast-deploy-with-downtime-and-danger.yml -o cf-deployment/operations/aws.yml -o cf-deployment/operations/enable-privileged-container-support.yml -o cf-deployment/operations/scale-to-one-az.yml -n

### Login

credhub find -n cf_admin_password
credhub get -n /bosh-bbl-env-nicaragua-2025-01-25t09-18z/cf/cf_admin_password

cf api https://api.sys.sabo.gremlin.rocks --skip-ssl-validation
cf create-space sabo
cf target -o "system" -s "sabo"

## Reference

- https://cloudfoundry.github.io/bosh-bootloader/getting-started-aws/
- https://github.com/cloudfoundry/cf-deployment/blob/main/texts/deployment-guide.md

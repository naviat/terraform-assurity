# terraform-assurity

Demo for Assurity Consulting

# Terraform-Ubuntu_setup_motd

Terraform example to setup ubuntu server with motd update

# Pre-requisites:

1. Should have AWS key and secret available
2. Should have a key pair created in AWS and available locally.
3. Terraform must be installed

# How to run:

execute run .sh with parameters as follows:

```shell
Usage: run.sh arguments...
--aws-key       AWS key needed to connect to AWS
--aws-secret    AWS secret
--region        AWS region name for example "us-east-1"
--key-name      AWS key pair needed to connect over ssh into the instance, THIS MUST BE AVAILABLE IN ADVANCE
--key-path      Local path to the private key file for the key pair, this will be used by terraform to run scripts
```

Example:
```shell
$ ./run.sh --aws-key "<your aws key id>"  --aws-secret "<your aws secret key>" --region "<your region>" --key-name "<your key pair name in AWS>" --key-path "<your local key for key pair>"
```
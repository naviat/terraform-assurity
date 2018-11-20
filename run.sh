#!/bin/bash -e

PUBLIC_KEY=""
reject(){
    echo "ERROR: "$1
    exit 1
}

usage(){
cat - <<END
This script creates a ubuntu instance by triggering "terraform apply" which also updated motd file in /etc/motd
Usage: run.sh arguments...
--aws-key       AWS key needed to connect to AWS
--aws-secret    AWS secret
--region        AWS region name for example "us-east-1"
--key-name      AWS key pair needed to connect over ssh into the instance, THIS MUST BE AVAILABLE IN ADVANCE
--key-path      Local path to the pem key file for the key pair, this will be used by terraform to run scripts
END
exit 0
}

#Lets parse some args neede to pass to terraform
[[ $# -gt 0 ]] || reject "Insufficient arguments passed" 

# Check if any required arguments are missing.
checkargs() {
  any=
  for arg in $*
  do
    if [ -z "${!arg}" ]
    then
      echo "Error: --$arg is required" 1>&2
      any=1
    fi
  done
  if [ -n "$any" ]
  then
    reject "Mandatory args are missing"
    exit 1
  fi
}

# Parse arguments.
argspassed=
while getopts "h-:" opt
do
  argspassed=1
  case "${opt}" in
    -)
      val="${!OPTIND}"
      let "OPTIND++"
      case "${OPTARG}" in
        aws-key)
          AWS_KEY=$val ;;
        aws-secret)
          AWS_SECRET=$val ;;
        region)
          REGION=$val ;;
        key-name)
          KEY_NAME=$val ;;
        key-path)
          KEY_PATH=$val ;;
	help)
 	  usage ;;
      esac ;;
    h)
      usage ;;
  esac
done

# Check mandatory arguments.
checkargs AWS_KEY AWS_SECRET REGION KEY_NAME KEY_PATH

terraform apply -var aws_key="${AWS_KEY}" -var aws_secret="${aws_secret}" -var motd_path="${MOTD_PATH}" -var key_path="${KEY_PATH}" -var region="${REGION}" -var key_name="${KEY_NAME}" || reject "There were problems in running terraform, please see console log for details" 
cat << EOF
 "Please connect via ssh using ubuntu user Following is the ssh comamnd needed to connect:"
 ssh -i ${KEY_PATH} ubuntu@$(terraform output | cut -d '=' -f2 | tr -d ' ')
EOF
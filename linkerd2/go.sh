#!/bin/bash

if [[ "$#" -ne 1 ]]; then
  echo "Please supply the AWSPCA Role string as a command argument."
  echo "For example: ./go.sh arn:aws:iam::12345/role/blahblahblah_Role"
  exit 1
fi

AWSPCA_ROLE=$1

DOCKER_TRACE=1 $LD/bin/docker-build | grep 'Successfully tagged' | tr -s " " | cut -f 2 -d : | tail -n -1 > tmp.dat
cat tmp.dat | xargs ./docker_tag_and_push.sh

echo "killing old cluster"
kubectl delete -f ld_out.yaml

echo "writing out LD file"
#$LD/bin/linkerd install --identity-issuer-certificate-file ~/source/myCA/grampleberg/identity.crt --identity-issuer-key-file ~/source/myCA/grampleberg/identity.key  --identity-trust-anchors-file ~/source/myCA/certs/onetruecacert.pem --linkerd-cni-enabled > ld_in.yaml
$LD/bin/linkerd install --identity-issuer-certificate-file ~/source/myCA/grampleberg/identity.crt --identity-issuer-key-file ~/source/myCA/grampleberg/identity.key  --identity-trust-anchors-file ~/source/myCA/certs/onetruecacert.pem --linkerd-cni-enabled > ld_in.yaml

echo "copying ld_in to ld_out"
cp ld_in.yaml ld_out.yaml

echo "replacing all of the image bases"
sed -i -e 's/gcr.io\/linkerd-io/gitlab-registry.nordstrom.com\/gtm\/linkerd-sandbox/g' ld_out.yaml

echo "replacing imagepullpolicy"
sed -i -e 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Always/g' ld_out.yaml

echo "adding kube2iam stuff"
sed -i '' '6i\
\ \ annotations:
' ld_out.yaml

sed -i '' '7i\
\ \ \ \ kube2iam.beta.nordstrom.net/allowed-roles: [\"$AWSPCA_ROLE\"]
' ld_out.yaml

sed -i -e "1,// s/\[/\'\[/" ld_out.yaml
sed -i -e "1,// s/]/]\'/" ld_out.yaml

sed -i '' '109i\
\ \ \ \ \ \ \ \ kube2iam.beta.nordstrom.net/role: $AWSPCA_ROLE
' ld_out.yaml


kubectl apply -f ld_out.yaml

# A Notebook for useful Commands for AKS Environment

## Kubernetes Secret Handling

### Base64 decode/encode

```bash
> encode
base64 <<< "your string"
echo "your string" | base64
> decode
base64 -d <<< "your base64 encoded string"
echo "your base64 encoded string" | base64 -d
```

## SSL Certificate Handling

### Check Expiry Date on an application gateway certificate (host needs internet access)

```bash
watch -n 120 'echo | openssl s_client -servername mysite.eu -connect "$(dig +short mysite.eu)":443  2>/dev/null | openssl x509 -noout -dates'

> notBefore=Feb 16 00:00:00 2024 GMT
> notAfter=Mar 18 23:59:59 2025 GMT
```

### Convert a set of .crt/.pem files into .pfx 

if you have the private key only as a string/textfile, just put into a editor and save it as file type "All Types" with suffix .key

```bash
ls -ahl ./certificates

openssl pkcs12 -inkey ./privatekey.key -in ./one.crt -in ./two.crt -in ./three.pem -export -out mysite.de.pfx
```

### Update the Certificate in Kubernetes

<u>option 1 - for the non-CLI user:</u>
put the .crt/.pem files for the certificate chain into one file and then copy all contents into the Kubernetes -tls secret (in the application namespace). Use (Open)Lens for that and make sure toggle the Secret visibility (eye) so you paste in "non-base64" mode.

<u>option 2:</u>

```bash

> should be tested on a seperate secret

kubectl create secret tls gateway.heypharmacist.co.uk-tls \
    --cert=path/to/new/certificate.crt \
    --key=path/to/new/private.key \
    --dry-run=client -o yaml | kubectl apply -f -

```

## Cilium Scripts

### list Pods that are not managed by Cilium 

https://raw.githubusercontent.com/cilium/cilium/main/contrib/k8s/k8s-unmanaged.sh

```bash
./k8s-unmanaged.sh

namespace/pod1
namespace/pod2
```

## Helm Chart

### List currently applied values

```bash
> List Releases in Namespace
helm list -n <namespace>
> show values of a specific release
helm get values <release> -n <namespace>
```


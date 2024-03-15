# Deployment

## Overview

This document outlines the process for deploying our application stack on Kubernetes. The deployment procedure includes establishing the required infrastructure, configuring the applications according to best practices, and verifying that the stack is functional and ready for production use.

## Prerequisites

To successfully deploy the stack, the following prerequisites must be in place:

- **Ingress Controller**: An Ingress Controller such as Nginx is necessary to manage external access to the services in the cluster.
- **Cert-Manager**: This component automates the management and issuance of SSL certificates to secure communication.
- **InfluxDB ^1.8.10**: For production environments, it is advisable to configure a multi-node setup with a minimum of two nodes for redundancy and high availability.
- **PostgreSQL ^13.7.0**: A PostgreSQL database should be prepared to handle structured data storage requirements.

## Configuration

Configuration of the stack is facilitated through Helm charts. Each chart includes a `values.yaml` file where configuration parameters are set.

### Values Configuration

Copy the [values.yaml](../charts/stack/values.yaml) file to review and modify the configuration options. It is imperative to adjust only the entries marked with the `# CHANGEME` commentary.

#### Node Ports

Initially, determine the node ports required for external access to gRPC endpoints by listing currently utilized ports:

```sh
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}' | sort
```

#### Database Hostnames

Update the hostnames for PostgreSQL and InfluxDB services appropriately. For multiple InfluxDB nodes, delineate the `neodax.secrets.FINEX_INFLUX_HOST` as a comma-separated list of hosts.

#### Database Passwords

Assign unique, self-generated passwords for the databases. Clearport A & B and NeoDAX will have distinct database users, which are generated upon the initial deployment.

#### Clearport B Configuration

Clearport B primarily functions in responder mode and thus requires initial operator. Set the operator’s name in the `clearportB.responderMode.name` configuration field.

#### Component Domains

Specify unique domain names for each component in the `<component>.externalHostname` field to ensure distinct access points.

### Secrets Management

Create two Kubernetes secrets within the deployment namespace:

This secret should store the credentials for the root database user, which must possess the privileges required to create new users and databases.
```sh
kubectl create secret generic db-credentials \
  -n "<namespace>" \
  --from-literal DATABASE_ROOT_USER="<root_user>" \
  --from-literal DATABASE_ROOT_PASSWORD="<root_password>"
```

This secret should include details for the blockchain node, bundler, and the private key associated with the broker operator wallet.
```sh
kubectl create secret generic db-credentials \
  -n "<namespace>" \
  --from-literal BLOCKCHAIN_RPC="<node_ws_url>" \
  --from-literal USEROP_CLIENT_PROVIDER_URL="<node_rpc_url>" \
  --from-literal USEROP_CLIENT_BUNDLER_URL="<bundler_rpc_url>" \
  --from-literal SIGNER_LOCAL_PRIVATE_KEY="<broker_private_key>"
```

Ensure that these secrets are securely managed and that access to them is restricted according to the principles of least privilege and need-to-know basis. After setting up the necessary configurations and secrets, proceed with the Helm chart deployment to instantiate the stack on your Kubernetes cluster.

## Installation

First, add the Yellow Stack Helm repository to your local Helm installation:
```sh
helm repo add yellow-stack https://layer-3.github.io/stack
```

Next, install the stack chart with the following command:
```sh
helm install "<release>" yellow-stack/stack \
  -n "<namespace>" \
  -f "<path_to_values.yaml>"
```

Replace the placeholders with the desired release name, namespace, and the path to the modified `values.yaml` file. The deployment process will begin, and the stack components will be initialized according to the specified configuration.

## Verification

After the deployment process is complete, verify that the stack is operational by checking the status of the pods and TLS certificates:
```sh
kubectl get pods -n "<namespace>"
kubectl get cert -n "<namespace>"
```

If the pods are running and the certificates are issued, the stack is successfully deployed and ready for use. Proceed to test the functionality of the applications and verify that the stack is operational.

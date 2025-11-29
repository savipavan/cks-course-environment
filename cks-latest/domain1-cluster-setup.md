# Overview of CIS Benchmarks
CIS Bench marks are best-practice security guidelines developed by the center for Internet Security(CSI)
they provide setp-by-setp instructions on how to secure systems

tool: kube-bench

# lab setup
Ubuntu 24 LTS

# ETCD Security Guidelines
to secure etcd, we'll focus on three key areas.
- Plain text data storage:
  - by default, etcd stores data in plain text
  - install etcd-client : apt install etcd-client -y
  - First set API version: sh export ETCDCTL_API=3
    etcdctl     --endpoints=https://127.0.0.1:2379     --cacert=/etc/kubernetes/pki/etcd/ca.crt     --cert=/etc/kubernetes/pki/etcd/server.crt     --key=/etc/kubernetes/pki/etcd/server.key     endpoint health
  - etcdctl  --endpoints=https://127.0.0.1:2379    --cacert=/etc/kubernetes/pki/etcd/ca.crt     --cert=/etc/kubernetes/pki/etcd/server.crt     --key=/etc/kubernetes/pki/etcd/server.key     get / --prefix --keys-only

    netstat -ntlp # check the running port

    # put some data in etcd
  - etcdctl  --endpoints=https://127.0.0.1:2379    --cacert=/etc/kubernetes/pki/etcd/ca.crt     --cert=/etc/kubernetes/pki/etcd/server.crt     --key=/etc/kubernetes/pki/etcd/server.key   put course pavan
  # retive the data
- - etcdctl  --endpoints=https://127.0.0.1:2379    --cacert=/etc/kubernetes/pki/etcd/ca.crt     --cert=/etc/kubernetes/pki/etcd/server.crt     --key=/etc/kubernetes/pki/etcd/server.key   get course
After put some data in plain text, this can be viewable
cd /var/lib/etcd

- TLS encryption
The data in-transit between API server and ETCD can also be intercepted. you have to ensure that this data is also protected
# open one more tab
netstat -ntlp
run sh tcpdump -i lo -X port 2379

start etcd with certificate files

- Certificate based authentication
# 3-Authentication
Without authentication, any client can connect to etcd and modify data. it is important to have authentication in place for etcd.
# etcdctl put key2 "value2" error: username is empty

# etcdctl --user=root:password put key2 "value2" error: username is empty

types of Authenication
etcd supports various approaches to authenticate
We will take example of username/passwords and certificates.

# start etcd with certificate based authentication
etcd --listen-client-urls https://127.0.0.1:2379 --advertise-client-urls https://127.0.0.1:2379 --cert-file=etcd.crt --key-file=etcd.key --trusted-ca-file=ca.crt

## Configure ETCD Binaries - New
https://github.com/zealvora/certified-kubernetes-security-specialist
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/install-etcd.md

## Overview of Certificate Authority
Kubernetes components, such as the API server, kubelet, controller manager should communicate with each other over secure channel.

These components need a mechanism to verify each other's identity

Certificate authority:
- Certificate authority is an entity which issues digital certificates.
- Key part is that both the receiver and the sender trusts the CA.
Two important Use-Cases:
- There are two important use-case where CA certificate will be used.
  - To generate TLS certificates for secure communication.
  - To generating certificates for client/component for authentication

# verify the certicicate
openssl verify -CAfile k8s-ca.crt client.crt

openssl x509 -in client.crt -text -noout

## Configure ceritificate authority
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/configure-ca.md

## Workflow - Issuarance of Signed Certificates

# Understanding the workflow
For the entire workflow to work, there are three steps:
- Generate the CA certificate and Key
  - In this step, we generate client key and certificate signing request(CSR)
  
- Generate the Certificate signing request for components and clients
  - In this step, We send CSR to the certificate authority. CA will verify and sign it to provide final client certificate.
  
- Sign the CSR using CA creds to get the final certificate
  - The signed certificates can be used for client authentication as well as for secure communication over TLS.

https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/certificate-workflow.md
 

## etcd - transport Security with HTTPS
If the traffic between the API server and etcd is not encrypted, an attacker sniffing the network can easily fetch all of the data in plain text

we ca configure etcd to listen on HTTPS so that the communication between a client and etcd is encrypted and secured

step 1: generate certificate for etcd
we have to generate a certificate for the etcd component.
This certificate will be used for HTTPS communication.

important flags:
--cert-file-<path> # specifies the path to the server's SSL/TLS certificate file.
--key-file=<path> # Specifies the path to the private key file corresponding to the certificate.
--advertise-client-urls #Specifies the URLs that etcd should advertise to clients for client communication. Example: https://<IP>:2379
--listen-client-urls #Specifies the URLs on which etcd listens for client requests. Example. https://0.0.0.0:2379
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/etcd-https.md

# install tcmpdump and net-tools

## Overview of Mutual TLS Authentication
Mutual TLS(mTLS) is a security protocol that ensures both the client and the server verify each other's identities before establishing a connection.

Both the client and the server have digital certificates issues by a trusted certificate authority(CA)

Both the sender and receiver should have their certificates
These certificates must be signed by trusted certificate authority that both sender and receiver trusts.

Handshake process:
- the client connects to the server.
- the server presents its certificate to the client
- the client verifies the server's certificate.
- the client presents its certificate to the server.
- the server verifies the client's certificate
- if both verifications pass, a secure, encrypted connectiion is established


## Practical - Mutual TLS Authentication

# Workflow steps:
- Cerfificate authority
- Etcd certificate signed through the certificate authority
- client certificate signed through the certificate authority

Important Flags - etcd server
--client-cert-auth = Enables client certificate authentication - requires clients to provide a valid certificate signed by the trusted CA.
--trusted-ca-file = path to certificate authority certificate file - Etcd uses this file to verify the authenticity of client certificates.

https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/mutual-tls.md


## Integrating systemd with etcd

# Systemd to Manage etcd
Systemd simplifies process management, handling tasks like starting, stopping and restarting services, including automatically starting etcd on server reboot.

systemctl status etcd
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/etcd-systemd.md

## API Server Security Guidelines:
API Server Security

The Kubernetes API Server acts as the gateway for managing and interacting with a Kubernetes cluster.
When we interact with your kubernetes cluster using the kubectl, the request goes to API server component

etcd component setup
Our etcd is configured to require certificate-based authentication and operates over HTTPS for secure communication

Connecting API Server to ETCD
To connect API Server with etcd component, there are two essential steps that need to be performed.
1. Generate certificates for API Server from trusted certificate authority.
2. API Server should connect to etcd over HTTPS endpoint

Encryption providers:
- The API Server should encrypt sensitive data, such as k8s secrets before storing it it need

TLS Encryption:
- Since users and other components may connect to the API Server over potentially insecure networks, it is critical to ensure that all traffic is encrypted.
- API Server should listen on HTTPS endpoint.

Auditing:
- Auditing provides a security-relevant, chronological set of records documenting the sequence of actions in a cluster.

It is important to have an appropriate audit policy to capture relevant logs.

Other Security Configurations:
- Several additional security configurations should be implemented, which we will discuss in upcoming dedicated videos.

Some of these include:
- Admission Control
- Authorization Mode
- Authentication

## Configuring API Server
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/configure-apiserver.md

## Transport security for API Server
API Server security
# TLS Encryption
Since users and other components may connect to the API Server over potentially insecure networks, it is criticalto ensure that all traffic is encrypted.

API Server should listen on HTTPS endpoint
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/apiserver-https.md

## Access Control
When we request reaches the API, it goes through several stages from laptop --> Authentication --> Authorization --> Admission Controllers --> K8S object

Authentication:
there are multiple ways in which we can authenticate. Some of these include:
Authentication Modes
- x509 Client Certificates - Valid client certificates signed by trusted CA.
- Static Token File - Sets of bearer token mentioned in a file.

Authorization:
- After the request is authenticated as coming from a specific user, the request must be authorized.
Multiple authorization modules are supported.
- Authorization modes:
  - AlwaysDeny - Blocks all requests(used in tests)
  - AlwaysAllow - Allows all requests; use if you don't need authorization
  - RBAC - Allows you to create and store policies using the Kubernetes API.
  - Node - A special-purpose authorization mode that grants permissions to kubelets

Admission Controllers:
- An admission controller is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

Controllers that can intercept Kubernetes API requests, and modify or reject them based on custom logic

## Static Token File Authentication
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/token-authentication.md

## Downsides of TOken Authentication
- the tokens are stored in clear-text in a file on the apiserver
- Tokens cannot be revoked or rotated without restarting the apiserver
- Hence, it is recommended to not use this type of authentication

## Implementing x509 Client Authentication
A request is authenticated if the client certificate is signed by one of the certificate authorities that is configured in the API server
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/certificate-auth-k8s.md

## Downsides of X509 Client Authentication
- The private key is stored on an insecure media(local disk storage)
- Certificates are generally long-lived. Kubernetes does not support certificate revocation related area.
- Groups are associated with Organization in certificate. if you want to change the group, you will have to issue a new certificate.

## Authorization:

System Masters Group in Kubernetes
- There is a group named system:masters and any user that are part of this group have an unrestricted access to the Kubernetes API Server.
- Even if every cluster role and role is deleted from the cluster, users who are members of this group retain full access to the cluster

Important Pointers - Certificates
Within a certificate, there are two important fields:

Common Name(CN) and Organization(O)

openssl req -new -key alice.key -subj "/CN=alice/O=admins" -out alice.csr

the above commands create CSR for the username alice belonging to admins group.

## Encryption Provider 
Challenge with Plain Text Storage in ETCD
- Data like Kubernetes Secrets are stored in plain-text in ETCD.

Encryption Provider Configuration:
- The kube-apiserver process accepts an argument --encryption-provider-config that controls how API data is encrypted in etcd.
  https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/encryption-provider.md

Encryption Providers:
- Identity
- aescbc
- secretbox
- kms

Important Pointers:
- By default, the identity provider is used to protect secrets in etcd, which provides no encryption.
- You can make use of KMS provider for additional security.
- The older secrets would still be in an unencrypted form.

## Implementing Auditing
Auditing provides a security-relevant, chronological set of records documenting the sequence of actions in a cluster.

The cluster audits the activities generated by users. by applications that use the Kubernetes API, and by the control plane itself.

- What happend?
- When did it happen?
- Who initiated it?
- on what did it happen?
- from where was it initiated?
- to where was it going?

Audit policy: Audit policy defines rules about what events should be recorded and what data they should include.

Audit Levels:
- None : don't log event that match this rule.
- Metadata : Log request metadata(requesting user, timestamp, resource, verb, etc. but not request or response body)
- Request : Log event metadata and request body but not response body.
- RequestResponse: Log event metadata, request and response bodies.

Important Flags:
- audit-policy-file : Path to the file that defines the audit policy configuration.
- audit-log-path : Specifies the log file path that log backend uses to write audit events.
- audit-log-maxage : maximum number of days to retain old audit log files
- audit-log-maxbackup : maxium number of audit log files to retain
- audit-log-maxsize : maximum size in MB of audit log file before it gets rotated

https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/audit-logs.md

## Setting up kubeadmin cluster - NEW
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/kubeadm-install.md

## Taints and Tolerations
Taint is a property added to a node that repels certain pods

Toleration : in order to schdule into the worker node with taint, you need a special pass. 

# find node taint
kubectl describe node

# defaining a Taint
you can use the kubectl taint node command to add a taint to a node.
kubectl taint node node01 key=value:NoSchedule

A taint consists of a key, value(optional) and effect.

Effects in Taints:
NoSchdule : Prevents scheduling of new pods on the node unless they tolerate the taint
PreferNoSchdule : Tries to avoid scheduling new pods on the node, but does not enforce it strictly
NoExecute : Evicts existing pods and prevents new pods from being scheduled on the node.

## Kubelet security - New
Basics of Kubelet API
The Kubelet API provides a set of endpoints that allow users to interact with the kubelet to retrive information about the node, running pods, and container statuses.

curl -v -X GET https://localhost:10250/pods

curl -k https://localhost:10250/pods
# If kubelet is misconfigured, the kubelet API can be accessible to everyone over internet without authentication

Anonymous Authentication
- Anonymous authentication in kubernetes allows unauthenticated requests to the kubelet API.
- it is primarily used as a fallback mechanism when no other authentication method is provided

# kubelet Authorization mode:
kubelet supports different authorization modes to control which requests are allowed.

AlwaysAllow:
- security level - low
- use case: Dev and testing
- Authorization Mechanism : Allows all requests

WebHook
- security level - high(Centralized authorization)
- use case: prod, fine-grained access control
- Authorization Mechanism : Uses an external webhook to decide
  https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/kubelet-security.md


## Verify platform binaries
basics of hashing
Hashing is a one-way function that maps data of arbitrary size(often called the "message") to a bit array of a fixed size(message digest)

https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/verify-binaries.md

To verify the integrity of the archive, you can take a hash of the archive file and compare it with the hash value posted in the official website

## Revising Basics of Ingress

Challenge with Basic configuration
When we use a LoadBalancer Service Type, the load balancer forwards traffic to a NodePort associated with a single service.

Ideal approach:
In an ideal approach, you want a single load balancer to handle requests for multiple services and logic that can route traffic accordingly

Ingress acts as an entry point that routes traffic to specific services based on rules you define.

# Overview of Ingress with TLS

Challenge
A HTTP based connection to the ingress controller is not a secure.

TLS ensures secure communication between the client and the server.
You can secure the connection by setting up TLS at Ingress level.

Point to Note:
The certificate are stored in Kubernetes as Secrets, and the Ingress resource is configured to use these secrets for HTTPS traffic.


# Practical - Ingress with TLS
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/ingress-security.md

## Ingress Annotation - SSL Redirect
By default controller redicts HTTP clients to the HTTPS port 443 if TLS is enabled for that ingress
NGINX assumes that once TLS is defined in the Ingress, all traffic should be secure.

curl -I

https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-1-cluster-setup/ingress-ssl-annotation.md

## revising basics of network policies

By default, K8s allows all traffic between pods within a cluster. network policies help you lock down this open communication

Challenge:
If a application inside any pod gets compromised, attacker can essentially communicate with all other pods easily over the network

Ideal scenario:
you only want pods that have genuine requirement to connect to other pods to be able to communicate

Network policies are a mechanism for controlling network traffic flow in kubernetes clusters.

pod selector
namespace selector
ip block

Support for Network Policy:
- Not all Kubernetes network plugins(CNIs) support network policy
- The ability to enforce network policies is a feature that must be implemented by the CNI plugin
- Some Network Plugins like Calico, Cilium, etc supports Network Policy
- Some Network plugins like kubenet, Flannel does NOT support network Policy

- Most managed Kubernetes services(like AKS, EKS, GKE) come with a CNI that supports NetworkPolicy by default

## Structure of Network Policy

## Network Policies - Except, Port and Protocol

## Kubeadm Structure
The /etc/kubernetes directory is critical, as it holds all the essential manifest files and certificates needed for the functioning of your kubernetes cluster's components.

certificates - /etc/kuberntes/pki
kubeconfig - /etc/kuberntes/admin.conf
kubeconfig file - kubelet - A kubeconfig file for kubelet to use, /etc/kubernetes/kubelet.conf
This certificate have the following
CN system:node:<hostname-lowercases>

Static Pod manifests for control plane
/etc/kubernetes/manifests

All static pods get tier:control-plane and component:{component-name} labels

# Kubelet Configuration
kubelet is configured on the host system and is managed using systemd. Path to kubelet config file:/var/lib/kubelet/config.yaml

Mark Control Plane Node:
As soon as the control plane is available, kubeadm executes following actions:
1. Label the control-plane node with node-role,kubernetes.io/control-plane=""
2. Taints the node with node-role.kubernetes.io/control-plane:NoSchedule

## Kubeadm troubleshooting
you should be familiar with troubleshooting

# kubelet logs
we can check the kubelet logs using journalctl

journalctl -u kubelet -f

# Pod specific logs:
we can check Pod specific logs under /var/log directory.
ls /var/log/pods

# practicals
https://jpmc.udemy.com/labs/listing/?vertical=all&search=kubernetes


























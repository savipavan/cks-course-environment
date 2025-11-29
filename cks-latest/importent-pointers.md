review documentation
-----------
CIS Benchmarks:

ImagePolicyWebhook
AuditPolicy
***************
### Docker Security:
- Need to be aware of Docker Daemon Security + Dockerfile security best practices.
- Example Scenarios:
  - Analyze the Dockerfile and fix 5 security issues.
  - Disable Docker daemon to listen on 2375
  - Make Docker Daemon Secure
  - Remove user from docker group
**************
- Static Analyses on Kubernetes Manifest
  - you should be able to read a given kubernetes manifest file and fix any security related issues.
    - env. DB_Password
    - SecurityContext:
      - priviledged: true
      - allowPrivilegeEscalation: true
      - runAsUser: 0
      - capabilities:

- Network Policies + Cilium Network Policies
  - Be comfortable writing network policies + Cilium Network policy
  - for Cilium Network Policy:
    - Be aware of ingressDeny and egressDeny block
    - Be aware of the entities in Cilium Network Policies

- Pod security standards:
  - you need to have clear understanding of pod security standards, including how to implement and adjust PSS configurations for pods and deployments.
    - privileged
    - baseline
    - restricted

  - SecurityContext:
    - Privileged Pods
    - Capabilities
    - readOnlyRootFilesystem(Immutability)

- Kubernetes secrets
  - type of secrets
    - Opaque Secrets
    - TLS
    - Docker config secrets

BOM and SBOM
- you should know on how to create SBOM using bom tool based on requirements.
  - Identify image that has xyz 1.3.2 package and create SBOM for it.
  - Tools:
    - Trivy, Syft, Bom can generate SBOM
      -    trivy image -f spdx-json --output nginx-spdx.json nginx | jq
           cat nginx-spdx.json | jq
           trivy sbom nginx-spdx.json
    - bom:
      - bom generate spdx-json --image nginx --output nginx.spdx.json
      - bom generate spdx-json --image nginx@sha256:5c733364e9a8f7e6d7289ceaad623c6600479fe95c3ab5534f07bfd7416d9541 --output nginx.spdx.json
      - bom document outline nginx.spdx.json


Upgrading kubeadm clusters

Ingress with TLS
https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#deploying-an-app

https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/#lock-down-to-mutual-tls-by-namespace


ServiceAccount + Projected Volumes
- service accounts with auto mounting as disabled
  - automountServiceAccountToken: false

Be familiar with mounting volume resources like SA using Projected Volumes.

volumes:
- name: token-vol
  projected:
    sources:
    - serviceAccountToken:
      - audience: api
        expierationSeconds: 3600
        path: token

### falco(Keep it for last)
- be prepared to develop a Falco rule according to a given specification.
- if we encounter issues with Falco log generation, verify that syslog is enabled with debug priority. Alternatively, run Falco directly from the command line, bypassing systemd.

Be Familiar with Deployment Manifest
- Deployment manifests more then Pod manifests.

secret tls
remove user from dockergroup
istion sidecar inject
network policy
privileged
pod security standards
admissioncontroller
imagepolicywebhook
upgrade worker node
serviceaccount token
BOM
docker daemon config



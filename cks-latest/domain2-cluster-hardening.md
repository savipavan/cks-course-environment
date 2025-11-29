## Revision - Authentication

## Revision - Authorization

## RBAC
RBAC allows us to control what actions users and service accounts can perform on resources within your cluster

Role defines a set of permissions
Subjects can be user, groups, service account
ROleBinding ties the permisson defined in the role to subjects like users.

A Role always sets permissions within a particular namespace
A RoleBinding associates a role with suer, group or service account withi a specific namespace

## ClusterRole and ClusterRoleBinding
Similar to Role and RoleBinding, but the main difference is that the permissions granted by a clusterrole apply across all namespaces in the cluster. ClusterRoleBinding connects ClusterRole to Subjets

## Creating Token for RBAC Practicals
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-2-cluster-hardening/user-rbac.md

# Set environment variable
TOKEN=""
echo $TOKEN

windows
set TOKEN=
echo %TOKEN%

## Role and Rolebinding
https://github.com/zealvora/certified-kubernetes-security-specialist/blob/main/domain-2-cluster-hardening/role-rolebinding.md

## ClusterRole and ClusterRoleBinding

## Service Accounts

## Service Accounts - Points to Note:

When we create a cluster, kuberntes automatically creates a sservice account object namesd called 'default'

Each Service account in Kuberntes can be associated with certain permissions.
When POD uses the service account, it can inherit the permissions.

The default service accounts in each namespace get no permissions by default other than the default API discovery permissions that Kubernetes grants to all authenticated principals if role-based access control(RBAC) is enabled.

If we deploy a POD in a namespace, and we dont manually assign a ServiceAccount to the Pod, Kubernetes assigns the default ServiceAccount for that namespace to the Pod

## Service Accounts - new 
Challenge: When we createa a pod without specifying a service account, the pod is automatically assigned the default service account in the same namespace.
if the default service account is granted excessive permissions, all pods using it will inherit those privileges, potentially leading to security risks.

# Disabling Auto-Mount at the Service Account Level
We can opt out of automounting API credentials for a service account by setting automountServiceAccountToken: false on the service account

## Version Skew Policy
In Kubernetes, different components(such as the API server, kubelet, etc interact with each other across various versions.)

To ensure compatibility and stability, kubernetes follows a version skew policy that defines how versions of these components can differ while still maintaining a functional cluster.

# Upgrading Kubeadm Clusters:
It is important to upgrade minor versions sequentially(1.31 -> 1.32 -> 1.33 etc.)

We had to do this on both control plane and worker node

Find the latest patch release for Kubernetes using the OS package manager:
apt-cache madison kubeadm

kubeadm upgrade plan check which versions are available to upgrade to and validate whether your current cluster is upgradeable

kubeadm upgrade apply v1.32.2

the kubelet component is not upgraded during the kubeadm upgrade apply operation.
we have to manually upgrade kubelet

#Setup environment for upgrading clusters

### Overview of Project volumes
Projected volumes lets you combine several different volume sources into a single volume mount in your pod.

## Mounting Service accounts using projected Volumes







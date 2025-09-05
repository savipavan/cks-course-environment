# Provision VM in Digital Ocian

# **3) Commands — run these on every node (control-plane & workers)**

# 1) basic updates & required tools
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# 2) Disable swap (kubelet will fail if swap is on by default)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 3) Load kernel modules and sysctl required for container networking
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

### 4) Install & configure containerd (on every node)

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd

# Generate default config and set systemd cgroup (you may need to edit manually)
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Try to set SystemdCgroup to true (works for most containerd package configs)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml || true

# If the sed didn't find the string, open and set:
# Edit /etc/containerd/config.toml and under the runtime options set:
# [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#     SystemdCgroup = true
# (for containerd 2.x the section is plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options)

sudo systemctl restart containerd
sudo systemctl enable containerd


## 5) Add the Kubernetes v1.33 apt repository and install kube packages (every node)

# create keyrings dir
sudo mkdir -p /etc/apt/keyrings

# download the v1.33 signing key & add repo for v1.33
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# Now choose the exact patch package you want (you must pick an exact apt version string that appears for your architecture). First list available versions:

apt-cache madison kubeadm kubelet kubectl cri-tools


From the output, pick the exact version string (example form you may see: 1.33.4-00 — replace below with the exact one you saw).

# Example (replace VERSION with the exact version string from apt-cache madison)
VERSION="1.33.4-00"
sudo apt-get install -y kubelet=${VERSION} kubeadm=${VERSION} kubectl=${VERSION} cri-tools=${VERSION}
sudo apt-mark hold kubelet kubeadm kubectl cri-tools
sudo systemctl enable --now kubelet


6) Initialize control plane (run only on the control-plane node)
7) # Example: adjust pod-network-cidr to match the CNI you'll install (Calico default works with 192.168.0.0/16)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --upload-certs

Set up kubeconfig for your regular user:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


## 7) Install a Pod network (CNI) — Calico example (run on control plane after init)

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/calico.yaml

Verify CNI pods start:
kubectl get pods -n calico-system   # or -n kube-system depending on manifest
kubectl get nodes
kubectl get pods -A

8) Join worker nodes (on each worker)
# prints join command for workers (control-plane prints it earlier too)
kubeadm token create --print-join-command


sudo kubeadm join 203.0.113.10:6443 --token abcdef.0123456789abcdef \
--discovery-token-ca-cert-hash sha256:abcdef... 


kubectl get nodes


9) Required Kubernetes ports & firewall notes

Control plane requires inbound ports (default) such as 6443, 2379-2380 (etcd), 10250, 10251, 10252 etc. Workers require 10250, and NodePort range 30000-32767 for NodePort services. Make sure your Droplet’s cloud firewall and any host firewall (ufw) allow these.
Kubernetes
DigitalOcean Docs

Example ufw allow (control plane):

sudo ufw allow 22/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10251/tcp
sudo ufw allow 10252/tcp
# worker node few ports:
sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw reload


### Single file placed
./provision.sh


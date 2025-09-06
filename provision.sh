# WARNING: run only on a test droplet
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# kernel modules + sysctl
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# containerd
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml || true
sudo systemctl restart containerd

# add k8s v1.33 repo (example)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# pick exact version shown by apt-cache madison, example below is placeholder
VERSION="1.33.4-00"
sudo apt-get install -y kubelet=${VERSION} kubeadm=${VERSION} kubectl=${VERSION} cri-tools=1.33.0-1.1
sudo apt-mark hold kubelet kubeadm kubectl cri-tools
sudo systemctl enable --now kubelet

# init (single node)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --upload-certs

# user kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.3/manifests/calico.yaml

# Copyright 2026 Simon Emms <simon@simonemms.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Hetzner Cloud Firewall is stateful and only filters traffic arriving on the
# public interface. Traffic between servers on the private network is not
# filtered here, so k3s + etcd + Flannel inter-node ports do not need
# explicit allow rules.

resource "hcloud_firewall" "control_plane" {
  name = "${var.cluster_name}-control-plane"

  labels = {
    cluster = var.cluster_name
    role    = "control-plane"
  }

  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = var.allowed_ssh_cidrs
  }

  rule {
    description = "Kubernetes API"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = var.allowed_kube_api_cidrs
  }

  rule {
    description = "HTTP (Traefik ingress)"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTPS (Traefik ingress)"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "ICMP echo"
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  # MetalLB note: when introducing MetalLB in BGP or L2 mode, additional
  # ports may need to be opened here (e.g. 7946/tcp+udp for memberlist). Do
  # not pre-open them now - leave that change paired with the actual MetalLB
  # rollout.
}

resource "kubernetes_namespace" "cluster_autoscaler" {
  count = var.worker_pools == null ? 0 : 1

  metadata {
    name = "cluster-autoscaler"
  }

  depends_on = [helm_release.cilium]
}

resource "kubernetes_secret_v1" "cluster_autoscaler" {
  count = var.worker_pools == null ? 0 : 1

  metadata {
    name      = "hetzner"
    namespace = kubernetes_namespace.cluster_autoscaler[count.index].metadata[0].name
  }

  data = {
    HCLOUD_TOKEN          = var.hcloud_token
    HCLOUD_NETWORK        = var.hcloud_network_name
    HCLOUD_FIREWALL       = var.worker_pools.firewall_id
    HCLOUD_SSH_KEY        = var.worker_pools.ssh_key_id
    HCLOUD_CLUSTER_CONFIG = base64encode(jsonencode(var.worker_pools.config))
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = var.worker_pools == null ? 0 : 1

  chart           = "cluster-autoscaler"
  name            = "cluster-autoscaler"
  atomic          = true
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.cluster_autoscaler[count.index].metadata[0].name
  repository      = "https://kubernetes.github.io/autoscaler"
  reset_values    = true
  version         = var.cluster_autoscaler_version
  wait            = true

  set {
    name  = "cloudProvider"
    value = "hetzner"
  }

  set {
    name  = "envFromSecret"
    value = kubernetes_secret_v1.cluster_autoscaler[count.index].metadata[0].name
  }

  dynamic "set" {
    for_each = flatten([for i, g in var.worker_pools.pools : [
      for k, v in g : {
        name  = "autoscalingGroups[${i}].${k}"
        value = v
      }
    ]])
    iterator = each

    content {
      name  = each.value.name
      value = each.value.value
    }
  }

  set {
    name  = "podAnnotations.secret"
    value = sha512(yamlencode(kubernetes_secret_v1.cluster_autoscaler[count.index].data))
  }
}

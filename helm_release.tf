# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

locals {
  helm_stage = var.deployment_stage == "upgrade" ? "true" : "false"
}

resource "kubernetes_namespace" "argo-workflows" {
  metadata {
    name = "argo-workflows"
  }
}


resource "kubernetes_secret" "s3-credentials" {
  metadata {
    name = "s3-credentials"
    namespace = "argo-workflows"
  }
  data = {
    accesskey = var.s3-credentials.accesskey
    secretkey = var.s3-credentials.secretkey
  }
  depends_on = [kubernetes_namespace.argo-workflows]
}

resource "helm_release" "atlan-secure-agent" {
  name       = "atlan-secure-agent"
  repository = "oci://registry-1.docker.io/atlanhq"
  chart      = "workflow-offline-agent"
  version    = "0.1.0"
  namespace        = "argo-workflows"
  create_namespace = false
  recreate_pods    = true

  set = [
    {
      name  = "agent.name"
      value = var.agent_name
    },
    {
      name  = "agent.atlan.domain"
      value = var.atlan_domain
    },
    {
      name  = "agent.atlan.token"
      value = var.atlan_token
    },
    {
      name  = "argo-workflows.controller.workflowNamespaces"
      value = "{argo-workflows}"
    },
    {
      name  = "IsUpgrade"
      value = local.helm_stage
    }
  ]
  values = [
    templatefile("${path.module}/sec-agent-values.yaml", {
      region = var.region
      s3_bucket_name = var.s3_bucket_name
      s3-credentials = var.s3-credentials
      keep_crds = var.keep_crds
    })
  ]
  depends_on = [kubernetes_namespace.argo-workflows, kubernetes_secret.s3-credentials]
}



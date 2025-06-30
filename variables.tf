# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  type = string
  description = "The region the EKS cluster is deployed in"
}

variable "atlan_domain" {
  type = string
  description = "The domain of the Atlan instance"
}

variable "atlan_token" {
  type = string
  description = "An API token for the Atlan instance"
}

variable "agent_name" {
  type = string
  description = "The name of the secure agent"
  default = "secure-agent"
}

variable "s3-credentials" {
  type = object({
    accesskey = string
    secretkey = string
  })
  description = "The credentials for the S3 bucket"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "deployment_stage" {
  description = "The stage of the deployment"
  type        = string
  validation {
    condition     = var.deployment_stage == "install" || var.deployment_stage == "upgrade" || var.deployment_stage == "uninstall"
    error_message = "The deployment_stage value must be either \"install\" or \"upgrade\" or \"uninstall\"."
  }
}

variable "keep_crds" {
  description = "Whether to keep the CRDs"
  type        = bool
  default     = true
}
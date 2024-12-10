terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.11"
    }
  }
}

variable "description" {
  default     = "Monitoring of workspace resources"
  description = "Monitoring of workspace resources"
}

variable "threshold" {
  type        = number
  description = "The threshold for the monitoring, used for all resources unless overridden by *_threshold."
  default     = 90
}

variable "memory_threshold" {
  type        = number
  description = "The threshold for the memory monitoring."
  default     = 90
}

variable "disk_threshold" {
  type        = number
  description = "The threshold for the disk monitoring."
  default     = 90
}

variable "disks" {
  type        = list(string)
  description = "The disks to monitor."
  default     = ["/"]
}

variable "enabled" {
  type        = bool
  description = "Whether the monitoring is enabled."
  default     = true
}

variable "memory_enabled" {
  type        = bool
  description = "Whether the memory monitoring is enabled."
  default     = false
}

variable "disk_enabled" {
  type        = bool
  description = "Whether the disk monitoring is enabled."
  default     = true
}

variable "agent_id" {
  type        = string
  description = "The ID of the agent to monitor."
}

data "coder_monitoring" "monitoring" {
  name         = "monitoring"
  description  = var.description
  threshold    = var.threshold
  memory_threshold = var.memory_threshold
  disk_threshold = var.disk_threshold
  disks = var.disks
  enabled = var.enabled
  memory_enabled = var.memory_enabled
  disk_enabled = var.disk_enabled
  agent_id = var.agent_id
}
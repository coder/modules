terraform {
  required_version = ">= 1.0.25"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.0.2"
    }
  }
}

variable "threshold" {
  type        = number
  description = "The threshold for the monitoring, used for all resources unless overridden by *_threshold - expressed as a percentage."
  default     = 90
  validation {
    condition     = var.threshold >= 0 && var.threshold <= 100
    error_message = "The threshold must be between 0 and 100."
  }
}

variable "memory_threshold" {
  type        = number
  description = "The threshold for the memory monitoring - expressed as a percentage."
  default     = 90
  validation {
    condition     = var.memory_threshold >= 0 && var.memory_threshold <= 100
    error_message = "The memory_threshold must be between 0 and 100."
  }
}

variable "disk_threshold" {
  type        = number
  description = "The threshold for the disk monitoring - expressed as a percentage."
  default     = 90
  validation {
    condition     = var.disk_threshold >= 0 && var.disk_threshold <= 100
    error_message = "The disk_threshold must be between 0 and 100."
  }
}

variable "disks" {
  type        = list(string)
  description = "The disks to monitor. e.g. ['/', '/home']"
  default     = ["/"]
}

variable "enabled" {
  type        = bool
  description = "Whether the monitoring is enabled."
  default     = true
  validation {
    condition     = var.enabled == true || var.enabled == false
    error_message = "The enabled must be true or false."
  }
}

variable "memory_enabled" {
  type        = bool
  description = "Whether the memory monitoring is enabled."
  default     = true
  validation {
    condition     = var.memory_enabled == true || var.memory_enabled == false
    error_message = "The memory_enabled must be true or false."
  }
}

variable "disk_enabled" {
  type        = bool
  description = "Whether the disk monitoring is enabled."
  default     = true
  validation {
    condition     = var.disk_enabled == true || var.disk_enabled == false
    error_message = "The disk_enabled must be true or false."
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of the agent to monitor."
}

data "coder_monitoring" "monitoring" {
  threshold    = var.threshold
  memory_threshold = var.memory_threshold
  disk_threshold = var.disk_threshold
  disks = var.disks
  enabled = var.enabled
  memory_enabled = var.memory_enabled
  disk_enabled = var.disk_enabled
  agent_id = var.agent_id
}
terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
    }
  }
}

variable "display_name" {
  default     = "Exoscale instance type"
  description = "The display name of the parameter."
  type        = string
}

variable "description" {
  default     = "Select the exoscale instance type to use for the workspace. Check out the pricing page for more information: https://www.exoscale.com/pricing"
  description = "The description of the parameter."
  type        = string
}

variable "default" {
  default     = ""
  description = "The default instance type to use if no type is specified. One of [\"standard.micro\", \"standard.tiny\", \"standard.small\", \"standard.medium\", \"standard.large\", \"standard.extra\", \"standard.huge\", \"standard.mega\", \"standard.titan\", \"standard.jumbo\", \"standard.colossus\", \"cpu.extra\", \"cpu.huge\", \"cpu.mega\", \"cpu.titan\", \"memory.extra\", \"memory.huge\", \"memory.mega\", \"memory.titan\", \"storage.extra\", \"storage.huge\", \"storage.mega\", \"storage.titan\", \"storage.jumbo\", \"gpu.small\", \"gpu.medium\", \"gpu.large\", \"gpu.huge\", \"gpu2.small\", \"gpu2.medium\", \"gpu2.large\", \"gpu2.huge\", \"gpu3.small\", \"gpu3.medium\", \"gpu3.large\", \"gpu3.huge\"]"
  type        = string
}

variable "mutable" {
  default     = false
  description = "Whether the parameter can be changed after creation."
  type        = bool
}

variable "custom_names" {
  default     = {}
  description = "A map of custom display names for instance type IDs."
  type        = map(string)
}

variable "type_category" {
  default     = ["standard"]
  description = "A list of instance type categories the user is allowed to choose. One of [\"standard\", \"cpu\", \"memory\", \"storage\", \"gpu\"]"
  type        = list(string)
}

variable "exclude" {
  default     = []
  description = "A list of instance type IDs to exclude. One of [\"standard.micro\", \"standard.tiny\", \"standard.small\", \"standard.medium\", \"standard.large\", \"standard.extra\", \"standard.huge\", \"standard.mega\", \"standard.titan\", \"standard.jumbo\", \"standard.colossus\", \"cpu.extra\", \"cpu.huge\", \"cpu.mega\", \"cpu.titan\", \"memory.extra\", \"memory.huge\", \"memory.mega\", \"memory.titan\", \"storage.extra\", \"storage.huge\", \"storage.mega\", \"storage.titan\", \"storage.jumbo\", \"gpu.small\", \"gpu.medium\", \"gpu.large\", \"gpu.huge\", \"gpu2.small\", \"gpu2.medium\", \"gpu2.large\", \"gpu2.huge\", \"gpu3.small\", \"gpu3.medium\", \"gpu3.large\", \"gpu3.huge\"]"
  type        = list(string)
}

locals {
  # https://www.exoscale.com/pricing/

  standard_instances = [
    {
      value = "standard.micro",
      name = "Standard Micro | 512 MB RAM, 1 Core, 10 - 200 GB  Disk"
    },
    {
      value = "standard.tiny",
      name = "Standard Tiny | 1 GB RAM, 1 Core, 10 - 400 GB  Disk"
    },
    {
      value = "standard.small",
      name = "Standard Small | 2 GB RAM, 2 Cores, 10 - 400 GB  Disk"
    },
    {
      value = "standard.medium",
      name = "Standard Medium | 4 GB RAM, 2 Cores, 10 - 400 GB  Disk"
    },
    {
      value = "standard.large",
      name = "Standard Large | 8 GB RAM, 4 Cores, 10 - 400 GB  Disk"
    },
    {
      value = "standard.extra",
      name = "Standard Extra-Large | 16 GB RAM, 4 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "standard.huge",
      name = "Standard Huge | 32 GB RAM, 8 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "standard.mega",
      name = "Standard Mega | 64 GB RAM, 12 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "standard.titan",
      name = "Standard Titan | 128 GB RAM, 16 Cores, 10 - 1.6 TB  Disk"
    },
    {
      value = "standard.jumbo",
      name = "Standard Jumbo | 256 GB RAM, 24 Cores, 10 - 1.6 TB  Disk"
    },
    {
      value = "standard.colossus",
      name = "Standard Colossus | 320 GB RAM, 40 Cores, 10 - 1.6 TB  Disk"
    }
  ]
  cpu_instances = [
    {
      value = "cpu.extra",
      name = "CPU Extra-Large | 16 GB RAM, 8 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "cpu.huge",
      name = "CPU Huge | 32 GB RAM, 16 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "cpu.mega",
      name = "CPU Mega | 64 GB RAM, 32 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "cpu.titan",
      name = "CPU Titan | 128 GB RAM, 40 Cores, 0.1 - 1.6 TB  Disk"
    }
  ]
  memory_instances = [
    {
      value = "memory.extra",
      name = "Memory Extra-Large | 16 GB RAM, 2 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "memory.huge",
      name = "Memory Huge | 32 GB RAM, 4 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "memory.mega",
      name = "Memory Mega | 64 GB RAM, 8 Cores, 10 - 800 GB  Disk"
    },
    {
      value = "memory.titan",
      name = "Memory Titan | 128 GB RAM, 12 Cores, 0.1 - 1.6 TB  Disk"
    }
  ]
  storage_instances = [
    {
      value = "storage.extra",
      name = "Storage Extra-Large | 16 GB RAM, 4 Cores, 1 - 2 TB  Disk"
    },
    {
      value = "storage.huge",
      name = "Storage Huge | 32 GB RAM, 8 Cores, 2 - 3 TB  Disk"
    },
    {
      value = "storage.mega",
      name = "Storage Mega | 64 GB RAM, 12 Cores, 3 - 5 TB  Disk"
    },
    {
      value = "storage.titan",
      name = "Storage Titan | 128 GB RAM, 16 Cores, 5 - 10 TB  Disk"
    },
    {
      value = "storage.jumbo",
      name = "Storage Jumbo | 225 GB RAM, 24 Cores, 10 - 15 TB  Disk"
    }
  ]
  gpu_instances = [
    {
      value = "gpu.small",
      name = "GPU1 Small | 56 GB RAM, 12 Cores, 1 GPU, 100 - 800 GB  Disk"
    },
    {
      value = "gpu.medium",
      name = "GPU1 Medium | 90 GB RAM, 16 Cores, 2 GPU, 0.1 - 1.2 TB Disk"
    },
    {
      value = "gpu.large",
      name = "GPU1 Large | 120 GB RAM, 24 Cores, 3 GPU, 0.1 - 1.6 TB  Disk"
    },
    {
      value = "gpu.huge",
      name = "GPU1 Huge | 225 GB RAM, 48 Cores, 4 GPU, 0.1 - 1.6 TB  Disk"
    },
    {
      value = "gpu2.small",
      name = "GPU2 Small | 56 GB RAM, 12 Cores, 1 GPU, 100 - 800 GB  Disk"
    },
    {
      value = "gpu2.medium",
      name = "GPU2 Medium | 90 GB RAM, 16 Cores, 2 GPU, 0.1 - 1.2 TB Disk"
    },
    {
      value = "gpu2.large",
      name = "GPU2 Large | 120 GB RAM, 24 Cores, 3 GPU, 0.1 - 1.6 TB  Disk"
    },
    {
      value = "gpu2.huge",
      name = "GPU2 Huge | 225 GB RAM, 48 Cores, 4 GPU, 0.1 - 1.6 TB  Disk"
    },
    {
      value = "gpu3.small",
      name = "GPU3 Small | 56 GB RAM, 12 Cores, 1 GPU, 100 - 800 GB  Disk"
    },
    {
      value = "gpu3.medium",
      name = "GPU3 Medium | 120 GB RAM, 24 Cores, 2 GPU, 0.1 - 1.2 TB Disk"
    },
    {
      value = "gpu3.large",
      name = "GPU3 Large | 224 GB RAM, 48 Cores, 4 GPU, 0.1 - 1.6 TB  Disk"
    },
    {
      value = "gpu3.huge",
      name = "GPU3 Huge | 448 GB RAM, 96 Cores, 8 GPU, 0.1 - 1.6 TB  Disk"
    }
  ]
}

data "coder_parameter" "instance_type" {
  name         = "exoscale_instance_type"
  display_name = var.display_name
  description  = var.description
  default      = var.default == "" ? null : var.default
  mutable      = var.mutable
  dynamic "option" {
    for_each = { for k, v in concat(
                              contains(var.type_category, "standard") ? local.standard_instances : [],
                              contains(var.type_category, "cpu") ? local.cpu_instances : [],
                              contains(var.type_category, "memory") ? local.memory_instances : [],
                              contains(var.type_category, "storage") ? local.storage_instances : [],
                              contains(var.type_category, "gpu") ? local.gpu_instances : []
                            ) : k => v if !(contains(var.exclude, v.value)) }
    content {
      name  = try(var.custom_names[option.value.value], option.value.name)
      value = option.value.value
    }
  }
}

output "value" {
  value = data.coder_parameter.instance_type.value
}
output "name" {
  value = data.coder_parameter.instance_type.name
}

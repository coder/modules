---
display_name: Monitoring
description: Monitoring of workspace resources
maintainer_github: coder
verified: true
tags: [monitoring]
---

# Monitoring

This module adds monitoring of workspace resources.

```tf
module "monitoring" {
  source  = "registry.coder.com/modules/monitoring/coder"
  version = "1.0.0"
  agent_id = coder_agent.dev.id
}
```

## Examples

```tf
module "monitoring" {
  source  = "registry.coder.com/modules/monitoring/coder"
  version = "1.0.0"
  agent_id = coder_agent.dev.id
}
```

### Enable/Disable

You can customize the monitoring by setting the `enabled`, `memory_enabled`, and `disk_enabled` variables.

```tf
module "monitoring" {
  source  = "registry.coder.com/modules/monitoring/coder"
  version = "1.0.0"
  agent_id = coder_agent.dev.id
  enabled = false
  memory_enabled = true
  disk_enabled = false
}
```

### Customize Thresholds

You can customize the thresholds by setting the `threshold`, `memory_threshold`, and `disk_threshold` variables.

```tf
module "monitoring" {
  source  = "registry.coder.com/modules/monitoring/coder"
  version = "1.0.0"
  agent_id = coder_agent.dev.id
  threshold = 90
  memory_threshold = 95
  disk_threshold = 90
}
```

### Customize Disks

You can customize the disks by setting the `disks` variable.

```tf
module "monitoring" {
  source  = "registry.coder.com/modules/monitoring/coder"
  version = "1.0.0"
  agent_id = coder_agent.dev.id
  disks = ["/"]
}
```
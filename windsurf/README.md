# Windsurf IDE

Adds a Windsurf IDE application.

## Examples

```hcl
module "windsurf_ide" {
  source    = "github.com/coder/modules//windsurf"
  agent_id  = coder_agent.example.id
  folder    = "/home/coder/project"
}
```

Without a folder parameter:

```hcl
module "windsurf_ide" {
  source    = "github.com/coder/modules//windsurf"
  agent_id  = coder_agent.example.id
}
```

## Inputs/Outputs

| Input        | Description                                                                                                                                        | Type     | Default |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| agent_id     | The ID of a Coder agent.                                                                                                                           | string   |         |
| folder       | The folder to open in Windsurf IDE.                                                                                                                | string   | ""      |
| open_recent  | Open the most recent workspace or folder. Falls back to the folder if there is no recent workspace or folder to open.                              | bool     | false   |
| order        | The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name. | number   | null    |

| Output       | Description         | Type   |
| ------------ | ------------------- | ------ |
| windsurf_url | Windsurf IDE URL.   | string |
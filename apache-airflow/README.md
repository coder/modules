---
display_name: airflow
description: A module that adds Apache Airflow in your Coder template
icon: ../.icons/airflow.svg
maintainer_github: coder
partner_github: nataindata
verified: true
tags: [airflow, idea, web, helper]
---

# airflow

A module that adds Apache Airflow in your Coder template.

```tf
module "airflow" {
  source   = "registry.coder.com/modules/apache-airflow/coder"
  version  = "1.0.13"
  agent_id = coder_agent.main.id
}
```

![Airflow](../.images/airflow.png)

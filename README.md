# FIAP Cloud Gaming - Infrastructure

Infraestrutura como codigo (IaC) do projeto FIAP Cloud Gaming, utilizando **Terraform** para provisionar recursos no **Microsoft Azure**.

## Arquitetura

A plataforma roda inteiramente em **Azure Container Apps**, com cada microservico em seu proprio container. Os ambientes (dev e prod) compartilham os mesmos modulos Terraform, diferenciando-se apenas pela configuracao.

```
                        ┌─────────────────────────────────────────────┐
                        │         Azure Container Apps Environment     │
                        │                                              │
  Internet ──────────►  │  ┌──────────┐     ┌──────────────────────┐  │
                        │  │ Gateway  │────►│ Identity API          │  │
                        │  │  (YARP)  │────►│ Catalog API           │  │
                        │  │          │────►│ Payment API           │  │
                        │  └──────────┘     └──────────────────────┘  │
                        │                                              │
                        │  ┌──────────────────────────────────────┐   │
                        │  │ Infra: PostgreSQL x3 │ MongoDB │ Redis│   │
                        │  │        Elasticsearch │ RabbitMQ       │   │
                        │  └──────────────────────────────────────┘   │
                        │                                              │
                        │  ┌──────────────────────────────────────┐   │
                        │  │ Observabilidade: Grafana │ Loki │Jaeger│  │
                        │  └──────────────────────────────────────┘   │
                        │                                              │
                        │  ┌──────────────────────────────────────┐   │
                        │  │ Functions (Azure Functions runtime)   │   │
                        │  └──────────────────────────────────────┘   │
                        └─────────────────────────────────────────────┘
```

### Diferencas entre ambientes

| Recurso | Dev | Prod |
|---------|-----|------|
| PostgreSQL | Container Apps (containerizado) | Azure PostgreSQL Flexible Server (managed) |
| Rede | Rede gerenciada pelo Container Apps | VNet com subnets dedicadas + Private DNS |
| Replicas | `min_replicas = 1` | `min_replicas = 0` (scale-to-zero) |
| Secrets | Hardcoded no tfvars | Via GitHub Secrets (variáveis sensíveis) |
| Grafana/Jaeger | Externo (acesso publico) | Interno (acesso via VNet) |

## Estrutura do projeto

```
Infra/
├── .github/workflows/
│   ├── plan.yml          # Terraform plan em PRs (matrix: dev + prod)
│   ├── apply.yml         # Terraform apply/destroy manual (workflow_dispatch)
│   ├── grafana.yml       # Build e push da imagem custom do Grafana
│   └── setup.yml         # Bootstrap do remote state (Storage Account)
│
├── environments/
│   ├── dev/              # Ambiente de desenvolvimento
│   │   ├── main.tf       # Todos os Container Apps (infra + APIs)
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf  # Backend remoto (Azure Blob)
│   │   └── dev.tfvars
│   └── prod/             # Ambiente de producao
│       ├── main.tf       # PostgreSQL Flexible Server + Container Apps
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── prod.tfvars
│
├── modules/
│   ├── container-apps/   # Container Apps Environment + Log Analytics
│   ├── networking/       # VNet, subnets, NSG, Private DNS Zone
│   └── resource-group/   # Resource Group
│
├── grafana/              # Custom Grafana Docker image
│   ├── Dockerfile
│   └── provisioning/
│       ├── datasources/
│       │   └── datasources.yml    # Loki + Jaeger (env vars)
│       └── dashboards/
│           ├── dashboards.yml
│           ├── identity-api-dashboard.json
│           ├── catalog-api-dashboard.json
│           └── payment-api-dashboard.json
│
└── setup/                # Bootstrap: cria Storage Account para tfstate
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Pre-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.14.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Subscription Azure com permissoes de Contributor
- GitHub PAT com permissao `read:packages` (para pull de imagens do GHCR)

## Setup inicial

### 1. Bootstrap do remote state

Na primeira vez, execute o setup para criar o Storage Account que armazena o estado do Terraform:

```bash
cd setup
terraform init
terraform apply -var="subscription_id=SUA_SUBSCRIPTION_ID"
```

### 2. Configurar secrets no GitHub

O repositorio precisa dos seguintes secrets para os workflows:

| Secret | Descricao |
|--------|-----------|
| `ARM_CLIENT_ID` | Service Principal client ID |
| `ARM_CLIENT_SECRET` | Service Principal client secret |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure Tenant ID |
| `GHCR_TOKEN` | GitHub PAT para pull de imagens |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL (prod) |
| `JWT_SECRET` | Secret para assinatura JWT (prod) |
| `RABBITMQ_PASSWORD` | Senha do RabbitMQ (prod) |

### 3. Build da imagem custom do Grafana

A imagem custom precisa existir no GHCR antes do `terraform apply`. Na primeira vez, faça o push manual:

```bash
cd grafana
docker build -t ghcr.io/fiap-cloud-gaming/grafana-custom:latest .
docker login ghcr.io
docker push ghcr.io/fiap-cloud-gaming/grafana-custom:latest
```

Apos o primeiro push, atualizacoes sao automaticas via workflow `grafana.yml`.

## Uso

### Terraform plan (automatico em PRs)

Ao abrir um PR que altere `environments/**` ou `modules/**`, o workflow `plan.yml` roda automaticamente `terraform plan` para **dev** e **prod**, postando o resultado como comentario no PR.

### Terraform apply (manual)

Via GitHub Actions:

1. Vá em **Actions** > **apply**
2. Clique em **Run workflow**
3. Selecione o ambiente (`dev` ou `prod`) e a acao (`apply` ou `destroy`)

Via CLI local:

```bash
# Dev
cd environments/dev
terraform init
terraform apply -var-file="dev.tfvars" \
  -var="subscription_id=..." \
  -var="ghcr_token=..."

# Prod
cd environments/prod
terraform init
terraform apply -var-file="prod.tfvars" \
  -var="subscription_id=..." \
  -var="ghcr_token=..." \
  -var="postgres_password=..." \
  -var="jwt_secret=..." \
  -var="rabbitmq_password=..."
```

### Outputs

Apos o apply, o Terraform exibe as URLs de todos os servicos:

```
gateway_url      = "https://gateway-api.<domain>.brazilsouth.azurecontainerapps.io"
grafana_url      = "https://grafana.<domain>.brazilsouth.azurecontainerapps.io"
jaeger_url       = "https://jaeger.<domain>.brazilsouth.azurecontainerapps.io"
rabbitmq_url     = "https://rabbitmq.<domain>.brazilsouth.azurecontainerapps.io"
```

## Container Apps provisionados

| Container App | Imagem | CPU | Memoria | Porta |
|---------------|--------|-----|---------|-------|
| **gateway-api** | `ghcr.io/fiap-cloud-gaming/gateway-api` | 0.5 | 1Gi | 8080 |
| **identity-api** | `ghcr.io/fiap-cloud-gaming/identity-api` | 0.5 | 1Gi | 8080 |
| **catalog-api** | `ghcr.io/fiap-cloud-gaming/catalog-api` | 0.5 | 1Gi | 8080 |
| **payment-api** | `ghcr.io/fiap-cloud-gaming/payment-api` | 0.5 | 1Gi | 8080 |
| **functions** | `ghcr.io/fiap-cloud-gaming/functions` | 0.25 | 0.5Gi | - |
| **postgres-identity** | `postgres:18.1-alpine` | 0.5 | 1Gi | 5432 |
| **postgres-catalog** | `postgres:18.1-alpine` | 0.5 | 1Gi | 5432 |
| **postgres-payment** | `postgres:18.1-alpine` | 0.5 | 1Gi | 5432 |
| **mongo** | `mongo:latest` | 0.5 | 1Gi | 27017 |
| **redis** | `redis:latest` | 0.25 | 0.5Gi | 6379 |
| **elasticsearch** | `elasticsearch:8.17.0` | 1.0 | 2Gi | 9200 |
| **rabbitmq** | `rabbitmq:4.1-management-alpine` | 0.5 | 1Gi | 15672 |
| **grafana** | `ghcr.io/.../grafana-custom` | 0.25 | 0.5Gi | 3000 |
| **loki** | `grafana/loki:latest` | 0.25 | 0.5Gi | 3100 |
| **jaeger** | `jaegertracing/jaeger:latest` | 0.5 | 1Gi | 16686 |

> **Nota:** No ambiente **prod**, os 3 PostgreSQL containerizados sao substituidos por um unico **Azure PostgreSQL Flexible Server** com 3 databases, integrado via Private DNS Zone.

## Grafana custom image

O Grafana no Container Apps nao suporta volume mounts. Para contornar isso, utilizamos uma imagem Docker customizada que embute os arquivos de provisioning:

- **Datasources**: Loki e Jaeger, configurados via variaveis de ambiente (`$LOKI_URL`, `$JAEGER_URL`)
- **Dashboards**: Identity API, Catalog API e Payment API pre-configurados

A imagem e construida e publicada automaticamente no GHCR pelo workflow `grafana.yml` quando arquivos em `grafana/` sao alterados no branch `main`.

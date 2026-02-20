# FIAP Cloud Gaming - Infrastructure

Infraestrutura como codigo (IaC) para o projeto FIAP Cloud Gaming.

## Arquitetura

O projeto suporta dois modos de deploy para a Fase 3:

- **ACA (Azure Container Apps)**: servicos gerenciados, sem necessidade de administrar VMs
- **VM (Virtual Machine)**: VM Ubuntu com Docker Compose, todos os servicos em uma unica maquina

## Estrutura do Repositorio

```text
.github/workflows/
  setup.yml              # Bootstrap: state storage + imagem Grafana
  deploy.yml             # Deploy: terraform apply/destroy (target: aca | vm)

terraform/
  setup/                 # Storage Account para Terraform remote state
  modules/
    resource-group/      # Modulo: Azure Resource Group
    aca/                 # Modulo: Container Apps Environment + Log Analytics
  aca/                   # Deploy via Azure Container Apps
    modules/
      infra/             # PostgreSQL, MongoDB, Redis, Elasticsearch, RabbitMQ, Azurite
      apps/              # Identity, Catalog, Payment, Gateway, Functions
      observability/     # Jaeger, Loki, Grafana
  vm/                    # Deploy via VM + Docker Compose

grafana/                 # Imagem custom Grafana (dashboards + datasources)
```

## Pre-requisitos

- [Terraform](https://www.terraform.io/) >= 1.14
- [Azure CLI](https://docs.microsoft.com/cli/azure/)
- Conta Azure com Service Principal configurado
- GitHub Secrets configurados no repositorio

## GitHub Secrets

| Secret | Descricao |
|--------|-----------|
| `ARM_CLIENT_ID` | Client ID do Service Principal |
| `ARM_CLIENT_SECRET` | Client Secret do Service Principal |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure Tenant ID |
| `GHCR_TOKEN` | PAT para autenticacao no GitHub Container Registry |

## Como Usar

### 1. Setup inicial (uma vez)

Rodar o workflow **setup** no GitHub Actions:

- Cria o Storage Account para Terraform remote state
- Publica a imagem custom do Grafana no GHCR

### 2. Deploy

Rodar o workflow **deploy** no GitHub Actions:

- **target**: `aca` (Container Apps) ou `vm` (Virtual Machine)
- **action**: `apply` (criar) ou `destroy` (remover)

### Via CLI (local)

```bash
# Container Apps
cd terraform/aca
terraform init
terraform apply -var-file="dev.tfvars" \
  -var="subscription_id=<SUB_ID>" \
  -var="ghcr_token=<PAT>"

# VM
cd terraform/vm
terraform init
terraform apply -var-file="dev.tfvars" \
  -var="subscription_id=<SUB_ID>" \
  -var="ghcr_token=<PAT>"
```

## Servicos

| Servico | Imagem | Descricao |
|---------|--------|-----------|
| Gateway API | `ghcr.io/fiap-cloud-gaming/gateway-api` | API Gateway (YARP reverse proxy) |
| Identity API | `ghcr.io/fiap-cloud-gaming/identity-api` | Autenticacao e autorizacao (JWT) |
| Catalog API | `ghcr.io/fiap-cloud-gaming/catalog-api` | Catalogo de jogos |
| Payment API | `ghcr.io/fiap-cloud-gaming/payment-api` | Processamento de pagamentos |
| Functions | `ghcr.io/fiap-cloud-gaming/functions` | Azure Functions (serverless) |
| Grafana | `ghcr.io/fiap-cloud-gaming/grafana-custom` | Dashboards de monitoramento |

## Infraestrutura

| Componente | Imagem | Funcao |
|------------|--------|--------|
| PostgreSQL | `postgres:18.1-alpine` | Banco relacional (Identity, Catalog, Payment) |
| MongoDB | `mongo:latest` | Banco de documentos (Catalog) |
| Redis | `redis:latest` | Cache (Catalog) |
| Elasticsearch | `elasticsearch:9.0.2` | Busca e indexacao |
| RabbitMQ | `rabbitmq:4.1-management-alpine` | Mensageria assincrona |
| Azurite | `mcr.microsoft.com/azure-storage/azurite` | Emulador Azure Storage (Functions) |
| Jaeger | `jaegertracing/jaeger:latest` | Tracing distribuido (OpenTelemetry) |
| Loki | `grafana/loki:latest` | Agregacao de logs |
| Grafana | Custom | Visualizacao de metricas, logs e traces |

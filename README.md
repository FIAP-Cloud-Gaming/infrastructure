# FIAP Cloud Gaming - Infrastructure

Infraestrutura como codigo (IaC) para o projeto FIAP Cloud Gaming.

## Arquitetura

O projeto suporta tres modos de deploy:

- **ACA (Azure Container Apps)**: servicos gerenciados, sem necessidade de administrar VMs (Fase 3)
- **VM (Virtual Machine)**: VM Ubuntu com Docker Compose, todos os servicos em uma unica maquina (Fase 3)
- **AKS (Azure Kubernetes Service)**: cluster Kubernetes com auto-scaling, HPA e monitoramento (Fase 4)

## Estrutura do Repositorio

```text
.github/workflows/
  setup.yml              # Bootstrap: state storage + imagem Grafana
  deploy.yml             # Deploy: terraform + kubectl (target: aca | vm | aks)

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
  aks/                   # Deploy do cluster AKS

k8s/
  base/                  # Manifests Kubernetes (Kustomize base)
    secrets/             # GHCR secret, app secrets (JWT, senhas)
    infra/               # PostgreSQL, MongoDB, Redis, Elasticsearch, RabbitMQ, Azurite
    apps/                # Identity, Catalog, Payment, Gateway, Functions + ConfigMap
    observability/       # Jaeger, Loki, Grafana, Prometheus
    hpa/                 # HorizontalPodAutoscaler (Identity, Catalog, Payment)
    ingress/             # NGINX Ingress Controller
  overlays/
    dev/                 # Overlay de dev (1 replica por servico)

grafana/                 # Imagem custom Grafana (dashboards + datasources)
```

## Pre-requisitos

- [Terraform](https://www.terraform.io/) >= 1.14
- [Azure CLI](https://docs.microsoft.com/cli/azure/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (para AKS)
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

### 2. Deploy via Container Apps (Fase 3)

```bash
# Via GitHub Actions
# Workflow: deploy -> target: aca, action: apply

# Via CLI
cd terraform/aca
terraform init
terraform apply -var-file="dev.tfvars" \
  -var="subscription_id=<SUB_ID>" \
  -var="ghcr_token=<PAT>"
```

### 3. Deploy via VM (Fase 3)

```bash
# Via GitHub Actions
# Workflow: deploy -> target: vm, action: apply

# Via CLI
cd terraform/vm
terraform init
terraform apply -var-file="dev.tfvars" \
  -var="subscription_id=<SUB_ID>" \
  -var="ghcr_token=<PAT>"
```

### 4. Deploy via AKS (Fase 4)

O deploy AKS tem duas etapas: criar o cluster (Terraform) e aplicar os manifests (Kustomize).

#### Via GitHub Actions (recomendado)

```
Workflow: deploy -> target: aks, action: apply
```

O workflow automaticamente:
1. Cria o cluster AKS com Terraform
2. Instala o NGINX Ingress Controller
3. Cria o secret do GHCR
4. Aplica os manifests Kustomize (`k8s/overlays/dev/`)
5. Aguarda os deployments ficarem prontos

#### Via CLI (manual)

```bash
# Etapa 1: Criar o cluster AKS
cd terraform/aks
terraform init
terraform apply -var-file="dev.tfvars" \
  -var="subscription_id=<SUB_ID>" \
  -var="ghcr_token=<PAT>"

# Etapa 2: Obter credenciais do cluster
az aks get-credentials --resource-group fcg-dev-rg --name fcg-aks

# Etapa 3: Instalar NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml

# Etapa 4: Criar secret do GHCR
kubectl create namespace fcg
kubectl create secret docker-registry ghcr-secret \
  --namespace=fcg \
  --docker-server=ghcr.io \
  --docker-username=fiap-cloud-gaming \
  --docker-password=<GHCR_TOKEN>

# Etapa 5: Aplicar manifests
kubectl apply -k k8s/overlays/dev/

# Verificar
kubectl get pods -n fcg
kubectl get svc -n fcg
kubectl get hpa -n fcg
kubectl get ingress -n fcg
```

### 5. Destruir recursos

```bash
# Via GitHub Actions
# Workflow: deploy -> target: aca|vm|aks, action: destroy

# Via CLI (AKS - remover manifests antes do cluster)
kubectl delete -k k8s/overlays/dev/
cd terraform/aks && terraform destroy -var-file="dev.tfvars" \
  -var="subscription_id=<SUB_ID>" \
  -var="ghcr_token=<PAT>"
```

## Kubernetes - Detalhes (Fase 4)

### Auto Scaling (HPA)

Os microsservicos Identity, Catalog e Payment possuem HPA configurado:

| Servico | Min Replicas | Max Replicas | CPU Target | Memory Target |
|---------|-------------|-------------|-----------|--------------|
| Identity API | 1 | 5 | 70% | 80% |
| Catalog API | 1 | 5 | 70% | 80% |
| Payment API | 1 | 5 | 70% | 80% |

### Ingress

NGINX Ingress Controller expoe os servicos externamente:

| Path | Servico | Porta |
|------|---------|-------|
| `/` | gateway-api | 80 |
| `/grafana` | grafana | 3000 |
| `/prometheus` | prometheus | 9090 |
| `/jaeger` | jaeger | 16686 |

### Monitoramento

| Ferramenta | Funcao |
|-----------|--------|
| Prometheus | Metricas de infraestrutura (CPU, memoria, pods) |
| Grafana | Dashboards e visualizacao |
| Loki | Agregacao de logs centralizada |
| Jaeger | Distributed tracing (OpenTelemetry) |

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
| Elasticsearch | `elasticsearch:8.17.4` | Busca e indexacao |
| RabbitMQ | `rabbitmq:4.1-management-alpine` | Mensageria assincrona |
| Azurite | `mcr.microsoft.com/azure-storage/azurite` | Emulador Azure Storage (Functions) |
| Jaeger | `jaegertracing/jaeger:latest` | Tracing distribuido (OpenTelemetry) |
| Loki | `grafana/loki:latest` | Agregacao de logs |
| Prometheus | `prom/prometheus:latest` | Metricas de infraestrutura |
| Grafana | Custom | Visualizacao de metricas, logs e traces |

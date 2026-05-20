# Multi-Cloud Infrastructure Monitoring using Terraform, Prometheus & Grafana

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## 📌 Project Overview

This project demonstrates a **production-style multi-cloud infrastructure setup** that provisions virtual machines across three major cloud providers and implements a centralized monitoring stack with real-time Telegram alerting.

| Component | Technology | Details |
|---|---|---|
| Infrastructure as Code | Terraform | Single flat layout (`main.tf`) |
| Cloud — AWS | EC2 (`t2.micro`) | Region: `ap-south-1` |
| Cloud — Azure | Linux VM (`Standard_B2pts_v2`) | Region: `Southeast Asia` |
| Cloud — GCP | Compute Engine (`e2-medium`) | Region: `asia-south1` *(planned)* |
| Metrics Collection | Prometheus + Node Exporter | Scrapes all cloud VMs |
| Visualization | Grafana | Dashboards for CPU, RAM, disk, network |
| Alerting | Telegram Bot | Real-time alert notifications |
| Deployment | Docker & Docker Compose | `monitoring-stack/` folder |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│               Cloud VMs (Targets)               │
│                                                 │
│  AWS EC2 (ap-south-1)       ──┐                 │
│  Azure Linux VM (SE Asia)   ──┼──► Node Exporter│
│  GCP Compute Engine*        ──┘    (port 9100)  │
│  * planned / commented out                      │
└──────────────────────────┬──────────────────────┘
                           │  scrape metrics
                           ▼
               ┌───────────────────────┐
               │      Prometheus       │
               │  metrics storage &    │
               │  alert evaluation     │
               └──────────┬────────────┘
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
    ┌─────────────────┐    ┌──────────────────────┐
    │     Grafana     │    │    Alertmanager       │
    │  Dashboards &   │    │   Alert routing &     │
    │  Visualization  │    │   deduplication       │
    └─────────────────┘    └──────────┬───────────┘
                                      │
                                      ▼
                          ┌───────────────────────┐
                          │    Telegram Alerts     │
                          │   (real-time notify)   │
                          └───────────────────────┘
```

---

## ✨ Features

### Infrastructure Provisioning (Terraform)
- **AWS** — EC2 instance (`t2.micro`, AMI `ami-0f58b397bc5c1f2e8`) in `ap-south-1`
- **Azure** — Full network stack: Resource Group → VNet (`10.0.0.0/16`) → Subnet (`10.0.1.0/24`) → Static Public IP → NIC → Linux VM (Ubuntu 24.04 LTS ARM64) in `Southeast Asia`
- **GCP** — Compute Engine VM (`e2-medium`, Debian 11, zone `asia-south1-a`) — *resource block prepared, currently commented out*
- All three providers declared in a single `providers.tf` with pinned versions

### Monitoring & Observability
- **Prometheus** scrapes Node Exporter from all active cloud VMs
- **Node Exporter** exposes system-level metrics (CPU, memory, disk, network) on port `9100`
- **Grafana** dashboards for multi-cloud infrastructure visibility
- Entire monitoring stack containerized in `monitoring-stack/` via Docker Compose

### Real-Time Alerting via Telegram
| Alert | Condition |
|---|---|
| 🔴 High CPU Usage | > 85% sustained |
| 🟠 High Memory Usage | > 90% sustained |
| 🟡 Low Disk Space | < 10% free |
| 🔵 High Network Traffic | Configurable threshold |
| ⚫ VM Downtime | Instance unreachable |

---

## 📁 Repository Structure

```
Multicloud-Terraform-Project/
├── main.tf                  # AWS, Azure & GCP resource definitions
├── providers.tf             # Provider configs (AWS, AzureRM, Google)
├── variables.tf             # Input variable declarations
├── outputs.tf               # Output value declarations
├── terraform.tfvars         # Variable values (credentials / IDs)
├── monitoring-stack/        # Docker-based monitoring stack
│   ├── docker-compose.yml
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── alert_rules.yml
│   ├── grafana/
│   │   └── dashboards/
│   └── alertmanager/
│       └── alertmanager.yml
└── .gitignore
```

---

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- AWS CLI configured (`aws configure`)
- Azure CLI authenticated (`az login`)
- GCP CLI authenticated (`gcloud auth application-default login`)
- A Telegram Bot Token and Chat ID

### 1. Clone the Repository

```bash
git clone https://github.com/Petchimuthu19/Multicloud-Terraform-Project.git
cd Multicloud-Terraform-Project
```

### 2. Configure `terraform.tfvars`

Update `terraform.tfvars` with your credentials and resource details:

```hcl
# AWS
aws_region = "ap-south-1"

# Azure
azure_location = "Southeast Asia"

# GCP
gcp_project = "your-gcp-project-id"
gcp_region  = "asia-south1"
```

### 3. Initialize and Apply Terraform

```bash
terraform init
terraform plan
terraform apply
```

> **Note:** The GCP Compute Engine resource is currently commented out in `main.tf`. Uncomment the `google_compute_instance` block to include GCP in your deployment.

### 4. Update Prometheus Targets

Once VMs are provisioned, update `monitoring-stack/prometheus/prometheus.yml` with the public IPs output by Terraform:

```yaml
scrape_configs:
  - job_name: 'aws-ec2'
    static_configs:
      - targets: ['<AWS_PUBLIC_IP>:9100']

  - job_name: 'azure-vm'
    static_configs:
      - targets: ['<AZURE_PUBLIC_IP>:9100']

  - job_name: 'gcp-vm'
    static_configs:
      - targets: ['<GCP_PUBLIC_IP>:9100']
```

### 5. Configure Telegram Alerting

Edit `monitoring-stack/alertmanager/alertmanager.yml`:

```yaml
receivers:
  - name: 'telegram'
    telegram_configs:
      - bot_token: '<YOUR_TELEGRAM_BOT_TOKEN>'
        chat_id: <YOUR_CHAT_ID>
```

### 6. Launch the Monitoring Stack

```bash
cd monitoring-stack
docker compose up -d
```

| Service | URL |
|---|---|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |

> Default Grafana credentials: `admin / admin`

---

## ☁️ Provider & Resource Reference

### `providers.tf`

| Provider | Source | Version |
|---|---|---|
| AWS | `hashicorp/aws` | `~> 5.0` |
| AzureRM | `hashicorp/azurerm` | `~> 3.117` |
| Google | `hashicorp/google` | `~> 5.0` |

### `main.tf` — Resource Summary

**AWS**
```hcl
resource "aws_instance" "aws_vm" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  tags = { Name = "Terraform-AWS-VM" }
}
```

**Azure** (Resource Group → VNet → Subnet → Public IP → NIC → VM)
```hcl
resource "azurerm_linux_virtual_machine" "azure_vm" {
  name     = "terraform-azure-vm"
  size     = "Standard_B2pts_v2"
  location = "Southeast Asia"
  # Ubuntu 24.04 LTS ARM64
}
```

**GCP** *(commented out — uncomment to enable)*
```hcl
# resource "google_compute_instance" "gcp_vm" {
#   name         = "terraform-gcp-vm"
#   machine_type = "e2-medium"
#   zone         = "asia-south1-a"
#   # Debian 11
# }
```

---

## ⚠️ Security Notes

- The Azure VM in `main.tf` currently uses a hardcoded password (`Password@12345`). Replace this with an SSH key or a secret manager reference before production use.
- Never commit `terraform.tfvars` with real credentials to version control — it is listed in `.gitignore`.
- Ensure Node Exporter port `9100` is only accessible from the Prometheus server IP, not open to the public internet.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| **Terraform** | Infrastructure as Code — provisions all cloud VMs |
| **AWS EC2** | Virtual machine on Amazon Web Services (`ap-south-1`) |
| **Azure Linux VM** | Virtual machine on Microsoft Azure (`Southeast Asia`) |
| **GCP Compute Engine** | Virtual machine on Google Cloud (`asia-south1`) — planned |
| **Prometheus** | Metrics scraping, storage, and alert evaluation |
| **Node Exporter** | System metrics agent on each VM (port 9100) |
| **Grafana** | Dashboard visualization |
| **Alertmanager** | Alert routing and deduplication |
| **Telegram Bot** | Real-time alert delivery |
| **Docker Compose** | Container orchestration for the monitoring stack |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

> Built to demonstrate production-grade multi-cloud observability using open-source tooling.

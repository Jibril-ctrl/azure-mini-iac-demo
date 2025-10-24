# ☁️ Mini Enterprise on Azure with Terraform (Free Tier)
[![Terraform](https://img.shields.io/badge/Terraform-v1.5%2B-7B42BC?logo=terraform)](https://developer.hashicorp.com/terraform)
[![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoftazure)](https://azure.microsoft.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS Compatible](https://img.shields.io/badge/macOS-Compatible-lightgrey)]()

**Author:** Jibril Anifowoshe  
**Date:** October 2025  
**License:** MIT  

---

## 🚀 Overview

The **Mini Enterprise on Azure** project provisions a **secure, cloud-native foundation** using Terraform — the same way large organizations build their environments.  

It deploys:
- A **Resource Group** to organize assets  
- A **Virtual Network** and **Subnet** for private IP isolation  
- A **Network Security Group (NSG)** with sample firewall rules  
- A **Storage Account** + **Blob Container** for SIEM/log collection  

All resources run within **Azure Free Tier** — no compute, no cost.  
Perfect for DevOps demos, IaC learning, or security architecture walkthroughs.  

---

## ✨ Features

- 🧱 **Enterprise-grade IaC pattern** — modular, clean, and reusable.  
- 🔐 **Security-first defaults** — no public access, TLS 1.2 enforced.  
- 💾 **Storage versioning** — rollback or recover deleted blobs.  
- ⚙️ **Auto cleanup policy** — deletes logs older than 30 days.  
- 🧭 **Zero-cost footprint** — deploys entirely in free Azure resources.  
- 🔁 **Full lifecycle automation** — deploy, verify, and teardown.  

---

## 🧠 Architecture & Design

Terraform is used to define everything as code, ensuring consistency and traceability.

**Azure Components:**
1. **Resource Group** – Logical container (like a CloudFormation stack).  
2. **Virtual Network (VNet)** – Private address space for internal workloads.  
3. **Subnet** – Isolated segment for future compute or SIEM collectors.  
4. **Network Security Group (NSG)** – Acts as a firewall for traffic control.  
   - Port **22 (SSH)** and **80 (HTTP)** included for demonstration.  
   - In production, restrict to your IP or switch to **HTTPS (443)**.  
5. **Storage Account + Blob Container** – Secure store for logs or artifacts.  
   - Equivalent to **S3** in AWS terms.  
   - Private access, versioning on, 30-day cleanup rule enabled.  

---

## ⚙️ Prerequisites

### 🧩 Tools (macOS example)
```bash
brew install terraform
brew install azure-cli


🔐 Authenticate
az login

▶️ Usage

Deploy in three steps:
terraform init
terraform validate
terraform apply -auto-approve

To tear down:
terraform destroy -auto-approve


🧭 Repo Structure
azure-mini-iac-demo/
│
├── main.tf                      # Terraform blueprint (network + storage)
├── terraform.tfvars.example     # Editable variables
├── README.md                    # Documentation
├── LICENSE                      # MIT License
├── .gitignore                   # Terraform + macOS ignores
│
├── scripts/
│   ├── 01_init.sh               # terraform init
│   ├── 02_apply.sh              # terraform validate + apply
│   └── 99_destroy.sh            # terraform destroy
│
└── .vscode/
    ├── extensions.json          # HashiCorp Terraform extension
    └── settings.json            # Format-on-save + LSP


📘 Future Enhancements
	•	Add compute layer (VM or App Service)
	•	Integrate SIEM logging pipeline (e.g., Log Analytics workspace)
	•	Extend with Azure Monitor + Defender for Cloud
	•	Publish to Terraform Cloud for remote state management

⸻

⚖️ License

Licensed under the MIT License — see LICENSE.

© 2025 Jibril Anifowoshe
Designed for educational and professional demonstration purposes.
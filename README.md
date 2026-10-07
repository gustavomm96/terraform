# 🚀 Terraform Infrastructure as Code (IaC) Portfolio

Repository dedicated to the study, practice, and implementation of Infrastructure as Code (IaC) using **Terraform**. The main goal of this repository is to consolidate advanced concepts of automation, standardization, and cloud engineering best practices across multiple cloud providers.

---

## 🎯 Project Objective

This portfolio serves as a hands-on laboratory to:
- Automate the provisioning of cloud resources in a repeatable and secure manner.
- Apply concepts of infrastructure versioning, modularity, and state management.
- Demonstrate multi-cloud competency, evolving from single-provider implementations to agnostic and integrated architectures.

---

## ☁️ Providers & Technologies

The initial focus is concentrated on **Microsoft Azure**, with progressive expansion plans to cover major market players:

| Cloud Provider | Status | Description / Projects |
| :--- | :---: | :--- |
| **Microsoft Azure** | 🟢 In Progress | Provisioning basic to advanced resources (Resource Groups, Virtual Networks, Compute, etc.) |
| **Amazon Web Services (AWS)** | 🟢 In Progress | Provisioning basic to advanced resources (EC2, ALB, CloudFront, RDS Databases, Networks, etc.) |
| **Google Cloud Platform (GCP)** | 🔜 Coming Soon | *Planned for upcoming expansion stages.* |

---

## 📁 Repository Structure

The project organization is structured in a modular and scalable way, separating code by cloud provider and isolating each scenario within its respective directory:

```text
terraform/
├── azure/              # Projects focused on the Microsoft Azure ecosystem
│   ├── project1/       # [Project load balance http/2 Nginx vm receiving http requests from lb]
│   └── project2/       # [Future Azure projects]
├── aws/                # (Future) Projects in the Amazon Web Services ecosystem
└── gcp/                # (Future) Projects in the Google Cloud Platform ecosystem
Multi-Cloud Infrastructure Monitoring using Terraform, Prometheus & Grafana
Project Overview

This project demonstrates a production-style multi-cloud infrastructure setup using:

Amazon Web Services
Microsoft Azure
Google Cloud
Terraform
Prometheus
Grafana
Docker
Telegram Alerting

The project provisions infrastructure across multiple cloud providers and implements centralized monitoring with real-time alerting for CPU, memory, disk, and network metrics.

Architecture:

AWS EC2 VM ─┐
Azure VM ───┼──> Node Exporter
GCP VM ─────┘
                 ↓
            Prometheus
                 ↓
              Grafana
                 ↓
         Telegram Alerts
         
Features:

Multi-cloud infrastructure provisioning using Terraform
AWS EC2 instance deployment
Azure Linux VM deployment
GCP Compute Engine VM deployment
Centralized monitoring using Prometheus
Grafana dashboards for visualization
Node Exporter for system metrics
Telegram alerts for:
High CPU usage
High memory usage
Low disk space
High network traffic
VM downtime
Docker-based monitoring stack

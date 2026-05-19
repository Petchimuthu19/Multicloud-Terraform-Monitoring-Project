terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

provider "google" {
  project = "daring-acumen-484107-t4"
  region  = "asia-south1"
}

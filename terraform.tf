terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.14.1"
    }
  }

  backend "gcs" {
    bucket = "terraform-state-prd"
    prefix = "terraform/state"
  }

}

provider "google" {
  project = "named-icon-445521-k5"
  region  = "us-central1"
}

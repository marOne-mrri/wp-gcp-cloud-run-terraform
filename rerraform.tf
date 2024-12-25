terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.14.1"
    }
  }

  backend "gcs" {
    bucket = "tf-state-prod"
    prefix = "terraform/state"
  }

}

provider "google" {
  project = "my-project-id"
  region  = "us-central1"
}

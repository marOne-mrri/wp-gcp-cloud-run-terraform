resource "google_cloud_run_v2_service" "wordpress_service" {
  name                = "wordpress"
  location            = "us-central1"
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"
  custom_audiences    = []
  template {
    containers {
      image = "wordpress:latest"

      env {
        name  = "WORDPRESS_DB_HOST"
        value = google_sql_database_instance.wp_db_instance.self_link
      }

      env {
        name  = "WORDPRESS_DB_USER"
        value = google_sql_user.wp_db_user.name
      }

      env {
        name  = "WORDPRESS_DB_PASSWORD"
        value = google_sql_user.wp_db_user.password
      }

      env {
        name  = "WORDPRESS_DB_NAME"
        value = google_sql_database.wp_database.name
      }

      ports {
        container_port = 80
      }

      resources {
        limits = {
          "memory" = "1Gi"
          "cpu"    = "1"
        }

        cpu_idle = true
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.wp_db_instance.connection_name]
      }
    }
  }
}

data "google_iam_policy" "all_users" {
  binding {
    role = "roles/viewer"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  name        = google_cloud_run_v2_service.wordpress_service.name
  policy_data = data.google_iam_policy.admin.policy_data
}

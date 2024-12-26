resource "google_cloud_run_v2_service" "wordpress_service" {
  name                = "wordpress"
  location            = "us-central1"
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

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
        name       = "mysql"
        mount_path = "/mysql"
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }

    volumes {
      name = "mysql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.wp_db_instance.connection_name]
      }
    }
  }
}



# WORDPRESS_DB_HOST: db
# WORDPRESS_DB_USER: wp_user
# WORDPRESS_DB_PASSWORD: wp_pass
# WORDPRESS_DB_NAME: wp_db
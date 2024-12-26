resource "google_sql_database_instance" "wp_db_instance" {
  name             = "my-database-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    edition               = "ENTERPRISE"
    disk_autoresize_limit = "20"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.my-network.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }

  deletion_protection = true
}

resource "google_sql_database" "wp_database" {
  name     = "wordpress"
  instance = google_sql_database_instance.wp_db_instance.name
}

resource "google_sql_user" "wp_db_user" {
  name     = "admin"
  instance = google_sql_database_instance.wp_db_instance.name
  password = "changeme"
}

data "google_compute_network" "my-network" {
  name = "default"
}

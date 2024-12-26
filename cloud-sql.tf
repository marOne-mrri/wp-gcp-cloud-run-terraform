resource "google_sql_database_instance" "wp_db_instance" {
  provider = google-beta

  name             = "wp-db-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
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
      private_network                               = data.google_compute_network.my_network.self_link
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

data "google_compute_network" "my_network" {
  name = "default"
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.my_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = data.google_compute_network.my_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "wp_db_instance" {
  name             = "my-database-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = true
}

resource "google_sql_database" "wp_database" {
  name     = "wordpress"
  instance = google_sql_database_instance.wp_db_instance.name
}

resource "google_sql_user" "wp_db_users" {
  name     = "admin"
  instance = google_sql_database_instance.wp_db_instance.name
  password = "changeme"
}

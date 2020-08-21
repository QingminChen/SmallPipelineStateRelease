provider "google" {
  project = "dataprod-cluster-testing-1"
  region  = "us-central1"
  zone    = "us-central1-f"
  credentials = file("dataprod-cluster-testing-1-7444c4c90649.json")
}

data "google_composer_image_versions" "all" {
}

resource "google_pubsub_topic" "create_destroy_topic" {
  name = "notify_destory_topic"
}

resource "google_pubsub_topic" "create_destroy_topic" {
  name = "notify_destory_topic"
}






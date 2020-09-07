provider "google" {
  project = "dataprod-cluster-testing-1"
  region  = "us-central1"
  zone    = "us-central1-f"
  credentials = file("dataprod-cluster-testing-1-7444c4c90649.json")
}

resource "google_storage_bucket" "create-source-code-bucket" {
  name = "integrate-source-code-small-for-testing"
  location = "us-central1"
  project = "dataprod-cluster-testing-1"
  storage_class = "STANDARD"
  bucket_policy_only = true
  force_destroy = true
}

resource "google_storage_bucket" "restore_state_bucket" {
  name = "terraform_state_colletion_small"
  location = "us-central1"
  project = "dataprod-cluster-testing-1"
  storage_class = "STANDARD"
  bucket_policy_only = true
  force_destroy = true
}

//the following way couldn't upload the completed state file, it doesn't the case we need
resource "google_storage_bucket_object" "upload-code-file" {     //used
  name   = "codes/"
  content = "Not really a directory, but it's empty"
  bucket = trimprefix("${var.root-small-deploy-source-code-bucket}","gs://")
  //bucket = "integrate-source-code-small-for-testing"
  content_type = "text/x-sh"
  provisioner "local-exec" {
    command = "gsutil cp -r /Users/chenqingmin/Codes/Github_Tools_Workspace/SmallPipelineStateRelease/destory.zip ${var.root-small-deploy-source-code-bucket}/codes/"        //used
    //command = "gsutil cp -r ${var.root-terraform-project-home-folder}/main.tf ${var.root-small-deploy-source-code-bucket}/codes/"
  }
  depends_on = [null_resource.auth_gcloud]
}

resource "null_resource" "pakcgae-destory-zip-file" {     //used
  provisioner "local-exec" {
    command = "zip -j destory.zip ./modules/destroy_resources/*"
  }
  depends_on = [null_resource.auth_gcloud]
}

resource "null_resource" "auth_gcloud" {   //used
  provisioner "local-exec" {
    command = "gcloud auth activate-service-account 742690957765-compute@developer.gserviceaccount.com --key-file=${var.root-terraform-project-home-folder}/dataprod-cluster-testing-1-7444c4c90649.json --project=dataprod-cluster-testing-1"
    //command = "gcloud auth activate-service-account 742690957765-compute@developer.gserviceaccount.com --key-file=/Users/chenqingmin/Codes/terraform_test_project_temp_small_2/dataprod-cluster-testing-1-7444c4c90649.json --project=dataprod-cluster-testing-1"
  }
  depends_on = [google_storage_bucket.create-source-code-bucket]
}


resource "google_cloudfunctions_function" "create_deploy_cloud_function" {
  name                  = "cloud-function-test-1"
  project               = "dataprod-cluster-testing-1"
  description           = "Trigger for destroying"
  available_memory_mb   = 128
  source_archive_bucket = trimprefix("${var.root-small-deploy-source-code-bucket}","gs://")
  source_archive_object = "codes/destory.zip"
  timeout               = 300
  entry_point           = "notify_topic_subscriber"
  //trigger_http          = false
  runtime               = "python37"
  event_trigger         {
      event_type            ="google.pubsub.topic.publish"
      resource              ="projects/dataprod-cluster-testing-1/topics/notify_destory_topic"
  }
//  source_repository     {
//      url              ="../destroy_resources"
//  }

  service_account_email = "742690957765-compute@developer.gserviceaccount.com"

  depends_on = [google_pubsub_topic.create_topic]

}

resource "google_pubsub_topic" "create_topic" {
  name = "notify_destory_topic"
  project = "dataprod-cluster-testing-1"

  message_storage_policy {
    allowed_persistence_regions = [
      "us-central1"
    ]
  }
  depends_on = [null_resource.auth_gcloud]
}


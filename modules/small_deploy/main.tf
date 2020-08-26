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
    command = "gsutil cp -r /Users/chenqingmin/Codes/terraform_test_project_temp_small_2/main.tf ${var.root-small-deploy-source-code-bucket}/codes/"        //used
    //command = "gsutil cp -r ${var.root-terraform-project-home-folder}/main.tf ${var.root-small-deploy-source-code-bucket}/codes/"
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


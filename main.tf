provider "google" {
  project = "dataprod-cluster-testing-1"
  region  = "us-central1"
  zone    = "us-central1-f"
  credentials = file("dataprod-cluster-testing-1-7444c4c90649.json")
}


//terraform {
//    required_providers {
//        # HashiCorp's dns provider
//        google = {
//            source = "hashicorp/google"
//            version = "~> 3.37.0"
//        }
//        # A hypothetical alternative dns provider
//        mydns = {
//            source = "hashicorp/null"
//            version = "~> 2.1.2"
//        }
//    }
//}

data "google_composer_image_versions" "all" {
}

module "small_deploy" {
  source = "./modules/small_deploy"

  root-terraform-project-home-folder = "${var.azure-pipeline-input-terraform-project-home-folder}"
  root-small-deploy-source-code-bucket = "${module.small_deploy.source-code-bucket}"

}


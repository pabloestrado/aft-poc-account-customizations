provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      managed_by = "AFT"
    }
  }
}

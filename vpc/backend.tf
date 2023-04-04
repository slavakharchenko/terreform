terraform {
  backend "s3" {
    bucket = "training-tfstate-slavakharchenko"
    key    = "state/training-vpc.state"
    region = "eu-central-1"
  }
}

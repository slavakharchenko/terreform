terraform {
  backend "s3" {
    bucket = "training-tfstate-slavakharchenko"
    key    = "state/training-ec2.state"
    region = "eu-central-1"
  }
}

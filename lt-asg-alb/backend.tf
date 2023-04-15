terraform {
  backend "s3" {
    bucket = "training-tfstate-slavakharchenko"
    key    = "state/launch-template-autoscaling-balancer.state"
    region = "eu-central-1"
  }
}

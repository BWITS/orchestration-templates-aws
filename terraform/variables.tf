variable "key_name" {
  description = "Exist AWS key pair"
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "ap-southeast-2"
}

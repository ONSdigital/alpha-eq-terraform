variable "heroku_email_account"  {
    description = "Your Heroku email you use to login with."
}
variable "heroku_api_key" {
     description = "Your heroku api key."
}
variable "env" {
     description = "The environment you wish to use."
}

variable "aws_secret_key" {
    description = "Amazon Web Service Secret Key."
}

variable "aws_access_key"  {
    description = "Amazon Web Service Access Key;"
}

variable "aws_key_pair" {
    description = "Amazon Web Service Key Pair;"
    default="digital-eq-keypair"
}

variable "aws_instance_type" {
    description = "Amazon instance type to spin up"
}

# eq-terraform

Terraform project that creates the infrastructure for the EQ project alpha.

## Setting up Terraform

1. Install terraform(terraform.io) and add the binary to your shell path.

2. Ensure that you have signed up for a heroku account and have generated an API
key.

3. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace your heroku
key in the file, adding your email address that you use to login with.

4. Run `terraform plan -var 'env=testdeploy'` to check the output of terraform.

5. Run `terraform apply -var 'env=testdeploy'` to create your infrastructure
environment.

*Note* Yor heroku account will need a credit card attached in order to install the database add-on, but you will not be billed.  Also you will need to have run `heroku local` at least once for one of the projects before the heroku deployment will succeed. This is needed to set up the local heroku authentication machanism.
*Note* To destroy an environment, run `terraform destroy -var 'env=testdeploy'`


*Note* AWS error
If you see this error, then it is most likely a timing issue with Role/Policy propagation. Run terraform apply again and it should then succeed
Error applying plan:

1 error(s) occurred:

* aws_ecs_service.eq-survey-runner: InvalidParameterException: Unable to assume role and validate the listeners configured on your load balancer.  Please verify the role being passed has the proper permissions.
	status code: 400, request id: []

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
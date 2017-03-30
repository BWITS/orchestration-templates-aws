# plan

terraform plan -var-file=np.tfvars -out=./plan

# apply

terraform apply -input=false ./plan

# destroy

terraform destroy -var-file=np.tfvars

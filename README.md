# terraform-aws-cognito
Mapping of AWS Cognito settings mapping to Terraform

If you want to use Terraform for AWS Cognito setup however, if you couldn’t find any tutorial or instructions on how to do so with Cognito settings mapping to Terraform’s aws module. You can find the settings of AWS Cognito mapped to Terraform modules [here](https://chandan02.medium.com/mapping-of-aws-cognito-options-to-terraform-aabf7ecd651b).

## cognito.tf
It contains all the required terraform mapping to AWS Cognito settings. 

## iam, pinpoint, routes53.tf
These files contain very basic settings required for some of the conifgurations used in `cognito.tf`

## Requirements

| Name      | Version    |
| --------- | ---------- |
| terraform | ~> 1.0.0 |
| aws       | ~> 3.0    |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | ~> 3.0 |

## Reference
[Mapping of AWS Cognito options to Terraform](https://chandan02.medium.com/mapping-of-aws-cognito-options-to-terraform-aabf7ecd651b)
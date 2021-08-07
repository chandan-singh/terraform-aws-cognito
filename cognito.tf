## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool
## https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateUserPool.html
resource "aws_cognito_user_pool" "pool" {
  name = "pool"

  username_attributes = ["email"] # ["email", "phone_number"] # Conflicts with alias_attributes
  username_configuration {
    case_sensitive = false
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false # false for "sub"
    required                 = false # true for "sub"
    string_attribute_constraints {   # if it is a string
      min_length = 7                 # 10 for "birthdate"
      max_length = 127               # 10 for "birthdate"
    }
  }

  password_policy {
    minimum_length                   = 8
    require_numbers                  = true
    require_symbols                  = false
    require_lowercase                = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
    # # In case of allow_admin_create_user_only is true
    # invite_message_template { 
    #   email_message = ""
    #   email_subject = ""
    #   sms_message   = ""
    # }
  }

  mfa_configuration = "OFF" # "ON" MFA is required for all users to sign in; requires at least one of sms_configuration or software_token_mfa_configuration to be configured or "OPTIONAL" MFA Will be required only for individual users who have MFA Enabled

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    # recovery_mechanism {
    #   name     = "verified_phone_number"
    #   priority = 2
    # }
  }

  auto_verified_attributes = ["email"]

  #   sms_configuration {
  #     external_id    = "..."
  #     sns_caller_arn = "..."
  #   }

  user_pool_add_ons {
    advanced_security_mode = "OFF" # "AUDIT", "ENFORCED"
  }

  email_configuration {
    # configuration_set = "<Email configuration set name from SES>"
    # source_arn = "<SES ARN>"
    # from_email_address = "chandan s <chandans@example.com>"
    # reply_to_email_address = "contact@example.com"
    email_sending_account = "COGNITO_DEFAULT" # "DEVELOPER" for SES account
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE" # "CONFIRM_WITH_LINK"
    # email_message = ""
    # email_message_by_link = ""
    # email_subject = ""
    # email_subject_by_link = ""
    # sms_message = ""
  }

  tags {
    Environment = "SampleEnvironment"
  }

  #   device_configuration {
  #       challenge_required_on_new_device = ""
  #       device_only_remembered_on_user_prompt = true # false equates to "Always" remember, true is "User Opt In," and not using a device_configuration block is "No."
  #   }

  ## Miscellaneous
  ## ----------------------------------------------------
  ### SMS Configuration
  #   sms_authentication_message = "Your code is {####}"

  #   sms_configuration {
  #     external_id    = "example"
  #     sns_caller_arn = aws_iam_role.example.arn
  #   }

  #   software_token_mfa_configuration {
  #     enabled = true
  #   }

  ### Lambda Configuration
  #   lambda_config {
  #     create_auth_challenge = "<ARN of Lambda>"
  #     custom_message        = "<message>"

  #     custom_email_sender {
  #       lambda_arn     = "<arn>"
  #       lambda_version = "<version>"
  #     }

  #     custom_sms_sender {
  #       lambda_arn     = "<arn>"
  #       lambda_version = "<version>"
  #     }

  #     define_auth_challenge          = "<arn>"
  #     kms_key_id                     = "<kms arn>"
  #     post_authentication            = "<arn>"
  #     post_confirmation              = "<arn>"
  #     pre_authentication             = "<arn>"
  #     pre_sign_up                    = "<arn>"
  #     pre_token_generation           = "<arn>"
  #     user_migration                 = "<arn>"
  #     verify_auth_challenge_response = "<arn>"
  #   }

  ### Schema
  #   schema {
  #     name                     = "<name>"
  #     attribute_data_type      = "<appropriate type>"
  #     developer_only_attribute = false
  #     mutable                  = true  # false for "sub"
  #     required                 = false # true for "sub"
  #     string_attribute_constraints {   # if it is a string
  #       min_length = 0                 # 10 for "birthdate"
  #       max_length = 2048              # 10 for "birthdate"
  #     }
  #   }

  ### Alias
  #   alias_attributes = ["phone_number", "email", "preferred_username"] # Conflicts with username_attributes

  ### Email additional options
  #   email_verification_subject = "<subject>" # Conflicts with verification_message_template configuration block email_subject argument
  #   email_verification_message = "<msg>"     # Conflicts with verification_message_template configuration block email_message argument

}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client
## https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateUserPoolClient.html
resource "aws_cognito_user_pool_client" "client" {
  name = "pool_client"

  user_pool_id = aws_cognito_user_pool.pool.id

  token_validity_units {
    refresh_token = "days" # "seconds", "minutes", "hours", "days"
    access_token  = "minutes"
    id_token      = "hours"
  }

  refresh_token_validity = 30 # 30 days
  access_token_validity  = 60 # 60 minutes
  id_token_validity      = 1  # 1 hour

  generate_secret = true

  prevent_user_existence_errors = "ENABLED" # "LEGACY", "ENABLED"

  explicit_auth_flows     = ["ALLOW_CUSTOM_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"] # "ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"
  enable_token_revocation = true


  read_attributes  = ["address", "birthdate", "email", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  write_attributes = ["address", "birthdate", "email", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]

  supported_identity_providers = ["COGNITO"] # "COGNITO", "Facebook", "SignInWithApple", "Google", "LoginWithAmazon"

  callback_urls        = ["https://example.com/"]
  default_redirect_uri = "https://example.com/" # URL must be one of the URL in callback_urls
  logout_urls          = ["https://example.com/logout"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"] # "code", "implicit", "client_credentials"]
  allowed_oauth_scopes                 = ["email", "profile"] # "phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"

  ### Pinpoint
  #   analytics_configuration {
  #     application_id   = aws_pinpoint_app.test.application_id
  #     external_id      = "some_id"
  #     role_arn         = aws_iam_role.test.arn
  #     user_data_shared = true
  #   }
}

## aws_cognito_user_pool_domain
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain
## https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateUserPoolDomain.html

# resource "aws_cognito_user_pool_domain" "main" {
#   domain       = "example-domain"
#   user_pool_id = aws_cognito_user_pool.pool.id
#   #   certificate_arn = aws_acm_certificate.cert.arn # For custom domain
# }

## aws_cognito_user_pool_ui_customization
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_ui_customization
## https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_SetUICustomization.html

# resource "aws_cognito_user_pool_ui_customization" "example" {
#   css        = ".label-customizable {font-weight: 400;}"
#   image_file = filebase64("logo.png")

#   # Refer to the aws_cognito_user_pool_domain resource's
#   # user_pool_id attribute to ensure it is in an 'Active' state
#   user_pool_id = aws_cognito_user_pool_domain.example.user_pool_id
# }

## aws_cognito_identity_provider
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider
### https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateIdentityProvider.html

# resource "aws_cognito_identity_provider" "example_provider" {
#   user_pool_id = aws_cognito_user_pool.pool.id
#   ## https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_IdentityProviderType.html
#   provider_name = "Google"
#   provider_type = "Google" # https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateIdentityProvider.html#CognitoUserPools-CreateIdentityProvider-request-ProviderType

#   provider_details = { # https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateIdentityProvider.html#CognitoUserPools-CreateIdentityProvider-request-ProviderDetails
#     client_id        = "your client_id"
#     client_secret    = "your client_secret"
#     authorize_scopes = "email"
#   }

#   attribute_mapping = {
#     email    = "email"
#     username = "sub"
#   }
# }


## aws_cognito_resource_server

# resource "aws_cognito_resource_server" "resource" {
#   identifier = "https://example.com"
#   name       = "example"

#   scope {
#     scope_name        = "sample-scope"
#     scope_description = "a Sample Scope Description"
#   }

#   user_pool_id = aws_cognito_user_pool.pool.id
# }

## aws_cognito_user_group
# resource "aws_cognito_user_group" "main" {
#   name         = "user-group"
#   user_pool_id = aws_cognito_user_pool.pool.id
#   description  = "Managed by Terraform"
#   precedence   = 42
#   role_arn     = aws_iam_role.group_role.arn
# }

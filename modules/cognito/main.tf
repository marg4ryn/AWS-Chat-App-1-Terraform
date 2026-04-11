resource "aws_cognito_user_pool" "pool" {
  name = "chatapp-user-pool"

  password_policy {
    minimum_length    = 8
    require_uppercase = false
    require_numbers   = false
    require_symbols   = false
  }

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "chatapp-client"
  user_pool_id = aws_cognito_user_pool.pool.id

    explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
    ]

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 7

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

output "user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "issuer_uri" {
  value = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.pool.id}"
}
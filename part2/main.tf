/*
DSML3850: Cloud Computing
Instructor: Thyago Mota
Student(s): Victoria Lassner
*/

provider "aws" {
  region = var.region
}

/* ---------------------- *
 * Security Configuration *
 * ---------------------- */

// creates a role to allow the lambda function to interact with AWS services
resource "aws_iam_role" "prj_02_lambda_role" {
  name = "prj_02_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

// attaches the AWSLambdaBasicExecutionRole to the role created above
resource "aws_iam_role_policy_attachment" "prj_02_lambda_policy_attachment" {
  role       = aws_iam_role.prj_02_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// allows API gateway to invoke the Lambda function
resource "aws_lambda_permission" "prj_02_api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.prj_02_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.prj_02_api.execution_arn}/*/*"
}

// retrieve dynamodb table keys
data "aws_dynamodb_table" "prj_02_keys" {
  name = "AuthenticationKeys"
}

// retrieve dynamodb table keys
data "aws_dynamodb_table" "prj_02_incidents" {
  name = "Incidents"
}

// allows the lambda function to access the dynamodb table
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name   = "lambda_dynamodb_policy"
  role   = aws_iam_role.prj_02_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [ 
          data.aws_dynamodb_table.prj_02_keys.arn, 
          data.aws_dynamodb_table.prj_02_incidents.arn
        ]
      }
    ]
  })
}

/* ---------------------- *
 * Services Configuration *
 * ---------------------- */

// TODO: API gateway creation
resource "aws_api_gateway_rest_api" "prj_02_api" {
  name        = "prj_02_api"
  description = "API Gateway for project 02"
}

// creates the API's root endpoint
// Not needed for root endpoint!
# resource "aws_api_gateway_resource" "prj_02_api_root_endpoint" {
#   rest_api_id = aws_api_gateway_rest_api.prj_02_api.id
#   parent_id   = aws_api_gateway_rest_api.prj_02_api.root_resource_id
#   path_part   = "/"
# }

// TODO: create the API's root endpoint method
resource "aws_api_gateway_method" "prj_02_api_root_endpoint_method" {
  rest_api_id   = aws_api_gateway_rest_api.prj_02_api.id
  resource_id   = aws_api_gateway_rest_api.prj_02_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

// TODO: integrate the API's root endpoint with the Lambda function
resource "aws_api_gateway_integration" "prj_02_api_root_endpoint_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.prj_02_api.id
  resource_id             = aws_api_gateway_rest_api.prj_02_api.root_resource_id
  http_method             = aws_api_gateway_method.prj_02_api_root_endpoint_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.prj_02_lambda.invoke_arn
}

// TODO: create the lambda function service
resource "aws_lambda_function" "prj_02_lambda" {
  function_name = "prj_02_lambda"
  role          = aws_iam_role.prj_02_lambda_role.arn
  runtime = "python3.11"
  handler = "prj_02_lambda.lambda_handler"
  filename = "${path.module}/prj_02_lambda.py.zip"

  timeout       = 30
}

// TODO: deploy the API
resource "aws_api_gateway_deployment" "prj_02_api_deployment" {
  depends_on = [aws_api_gateway_integration.prj_02_api_root_endpoint_lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.prj_02_api.id
}

// TODO: stage the API
resource "aws_api_gateway_stage" "prj_02_api_stage" {
  stage_name = "prod"
  rest_api_id   = aws_api_gateway_rest_api.prj_02_api.id
  deployment_id = aws_api_gateway_deployment.prj_02_api_deployment.id
}
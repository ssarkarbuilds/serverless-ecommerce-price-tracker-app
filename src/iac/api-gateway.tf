resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "Add Item API"
  description = "Add new item and target price to the tracker"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-south-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-south-1:862727727627:function:price_tracker/invocations"
}

resource "aws_api_gateway_deployment" "apig_deployment" {
  depends_on = [
    aws_api_gateway_resource.proxy,
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "dev"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apig_to_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "price_tracker"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:<aws_region>:<aws_account_number>:${aws_api_gateway_rest_api.rest_api.id}/*/*/*"
}
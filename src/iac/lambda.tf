data "archive_file" "python_lambda_package" {  
  type = "zip"  
  source_dir = "../lambda" 
  output_path = "price_tracker_lambda_source.zip"
}

resource "aws_lambda_function" "price_tracker" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  depends_on = [
    data.archive_file.python_lambda_package
  ]
  filename         = data.archive_file.python_lambda_package.output_path
  function_name    = "price_tracker"
  role             = aws_iam_role.lambda_role.arn
  handler          = "price_tracker.lambda_handler"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  runtime          = "python3.6"
  timeout          = "60"
}
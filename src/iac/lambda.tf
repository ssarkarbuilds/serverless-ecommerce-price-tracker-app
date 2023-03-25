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
  runtime          = "python3.9"
  timeout          = "10"
}

resource "aws_cloudwatch_event_rule" "every_one_hour" {
    name = "ScheduledEventRule"
    description = "Fires every one hour"
    schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "check_price_target" {
    rule = aws_cloudwatch_event_rule.every_one_hour.name
    target_id = "price_tracker"
    arn = aws_lambda_function.price_tracker.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_price_checker" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.price_tracker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_one_hour.arn
}
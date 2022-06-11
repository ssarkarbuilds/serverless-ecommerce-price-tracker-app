#assume role
resource "aws_iam_role" "lambda_role" {
    name = "price_tracker_lambda_role"
    path = "/"
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "LambdaExecutionRole"
        }
    ]
    })
}

#create a policy for the role
resource "aws_iam_policy" "lambda_policy" {
    name = "price-tracker-lambda-execution-policy"
    description = "Permission required by the lambda function"
    policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:*:*"
            ]
        },
        {
            "Sid": "AllowPublishToMyTopic",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws:sns:*:*:*"
        },
        {
            "Sid": "AllowReadWriteOnDynamoTable",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "arn:aws:dynamodb:*:*:*"
        }
    ]
    })
}

# Attached IAM Role and the new created Policy
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
    role       = aws_iam_role.lambda_role.id
    policy_arn = aws_iam_policy.lambda_policy.arn
}
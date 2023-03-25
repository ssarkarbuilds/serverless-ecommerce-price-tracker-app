resource "aws_sns_topic" "topic" {
  name = "price-drop-notification"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = "<your_email_address>"
}
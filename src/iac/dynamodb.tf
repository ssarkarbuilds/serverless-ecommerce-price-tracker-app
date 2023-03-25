resource "aws_dynamodb_table" "price_tracker_table" {
  name           = "PriceTracker"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

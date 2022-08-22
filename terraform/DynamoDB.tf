resource "aws_dynamodb_table_item" "dynamodb-t-item" {
  table_name = aws_dynamodb_table.dynamodb.name
  hash_key   = aws_dynamodb_table.dynamodb.hash_key

  item = <<ITEM
{
  "id": {"N": "1"},
  "name": {"S": "name"},
  "price": {"N": "60000"},
  "description": {"S": "최-신 2021년 달력"}
}
ITEM
}

resource "aws_dynamodb_table" "dynamodb" {
  name           = "product"
  hash_key       = "id"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "N"
  }
}
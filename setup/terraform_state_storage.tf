# s3 bucket to store terraform state file
resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "terraform-remote-state-storage-s3"
  acl    = "private"

  tags = {
    name      = "Terraform Storage"
    dedicated = "infra"
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# create a dynamodb table for locking the state file.
# this is important when sharing the same state file across users
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    name = "DynamoDB Terraform State Lock Table"
    dedicated = "infra"
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "terraform_storage_state_access" {
    statement  {
        effect = "Allow"

        actions = [
            "s3:ListBucket"
        ]

        resources = [
            aws_s3_bucket.terraform_state_storage.arn
        ]
    }

    statement {
        effect = "Allow"

        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]

        resources = [
            "${aws_s3_bucket.terraform_state_storage.arn}/terraform.tfstate"
        ]
    }
}

resource "aws_iam_policy" "terraform_storage_state_access" {
    name = "terraform_storage_state_access"
    policy = data.aws_iam_policy_document.terraform_storage_state_access.json
}

resource "aws_iam_user_policy_attachment" "terraform_storage_state_attachment" {
  user       = "terraform"
  policy_arn = aws_iam_policy.terraform_storage_state_access.arn
}


data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [
      "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    ]
  }
}

resource "aws_iam_policy" "dynamodb_access" {
    name = "dynamodb_access"
    policy = data.aws_iam_policy_document.dynamodb_access.json
}

resource "aws_iam_user_policy_attachment" "dynamodb_attachment" {
  user       = local.terraform_user
  policy_arn = aws_iam_policy.dynamodb_access.arn
}
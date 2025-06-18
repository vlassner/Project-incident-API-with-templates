/*
DSML3850: Cloud Computing
Instructor: Thyago Mota
Student(s): 
*/

provider "aws" {
  region = var.region
}

/* ---------------------- *
 * Services Configuration *
 * ---------------------- */

// TODO: create a dynamodb table to hold the authentication keys
resource "aws_dynamodb_table" "prj_02_dynamodb_keys_table" {
  name = "AuthenticationKeys"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "key_id"

  attribute {
    name = "key_id"
    type = "S"
  }

  tags = {
    Name = "Auth Keys Table"
  }

}


// TODO: create a dynamodb table to hold the incidents
resource "aws_dynamodb_table" "prj_02_dynamodb_incidents_table" {
  name = "Incidents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "slug"

  attribute {
    name = "slug"
    type = "S"
  }

  tags = {
    Name = "Incidents Table"
  }

}
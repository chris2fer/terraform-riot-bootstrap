variable "region" {
  type = string
  description = "The target AWS region where we will deploy"
  default = "us-west-2"
}

variable "environment" {
  type = string
  description = "The specific stack name for a deployment"
  default = "dev"
}  

### DDB ###
###########

variable "ddb_table_name" {
  default       = "riot-ingest"
} 
variable "ddb_table_billing_mode" {
  default       = "PROVISIONED"
  type          = string
  description   = ""
}
variable "ddb_table_read_capacity" {
  default       = 5
  type          = number
  description   = ""
}
variable "ddb_table_write_capacity" {
  default       = 5
  type          = number
  description   = ""
}
variable "ddb_table_hash_key" {
  default       = "UserId"
  type          = string
  description   = ""
}
variable "ddb_table_range_key" {
  default       = "GameTitle"
  type          = string
  description   = ""
}
variable "ddb_table_attributes" {
  default = [
    {
      name = "UserId"
      type = "S"
    },
    {
      name = "GameTitle"
      type = "S"
    },
    {
      name = "TopScore"
      type = "N"
    }
  ]
  type = list(object({
    name = string
    type = string
  }))
}
variable "ddb_table_ttl" {
  default = []
  type = list(object({
    attribute_name  = string
    enabled         = bool
  }))
}


#### S3 ####
############

variable "s3_bucket_kms_key_arn" {
  default     = ""
  type        = string
  description = "The KMS Key Arn for S3 Bucket Server-Side Encryption."
}

variable "s3_bucket_prefix" {
  default = ""
  type = string
  description = ""
}

##### LAMBDA #####
##################

variable "sls_func_api_name" {
  default = "riot-api"
  type = string
  description = ""
}
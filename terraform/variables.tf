variable "project_name" {
  description = "The name of the Supabase project."
  type        = string
  default     = "NexusCore"
}

variable "organization_id" {
  description = "The ID of the Supabase organization."
  type        = string
}

variable "db_password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region to deploy the Supabase project in."
  type        = string
  default     = "us-east-1"
}

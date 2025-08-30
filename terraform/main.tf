terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }
}

provider "supabase" {
  # You can find your access token in your Supabase account dashboard
  # https://supabase.com/dashboard/account/tokens
  # It's recommended to set this as an environment variable
  # export SUPABASE_ACCESS_TOKEN="your_token"
}

resource "supabase_project" "nexuscore" {
  provider     = supabase
  name         = var.project_name
  organization_id = var.organization_id
  db_pass      = var.db_password
  region       = var.region
}

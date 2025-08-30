output "project_id" {
  value = supabase_project.nexuscore.id
}

output "project_url" {
  value = "https://${supabase_project.nexuscore.ref}.supabase.co"
}

output "project_anon_key" {
  value = supabase_project.nexuscore.anon_key
  sensitive = true
}

output "project_service_role_key" {
  value = supabase_project.nexuscore.service_role_key
  sensitive = true
}

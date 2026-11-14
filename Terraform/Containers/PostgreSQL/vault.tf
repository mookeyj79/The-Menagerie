data "vault_generic_secret" "postgresql" {
  count = var.use_vault ? 1 : 0
  path = "secret/internal_services/postgresql"
}

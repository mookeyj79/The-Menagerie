external_url "http://gitlab.mikewashere.lan"

# Disable bundled services (external PG/Redis)
postgresql['enable'] = false
redis['enable'] = false

# PostgreSQL (external)
gitlab_rails['db_adapter']  = "postgresql"
gitlab_rails['db_encoding'] = "unicode"
gitlab_rails['db_host']     = "db1.mikewashere.lan"
gitlab_rails['db_port']     = 5432
gitlab_rails['db_database'] = "gitlab"
gitlab_rails['db_username'] = File.read("/var/secrets/postgresql_username").strip
gitlab_rails['db_password'] = File.read("/var/secrets/postgresql_password").strip
# TLS if used:
# gitlab_rails['db_sslmode']     = "require"
# gitlab_rails['db_sslrootcert'] = "/etc/gitlab/ssl/pg-ca.pem"

# Redis (external, ACL)
redis_url = "redis://#{File.read('/var/secrets/redis_username').strip}:#{File.read('/var/secrets/redis_password').strip}@db1.mikewashere.lan:6379/0"
gitlab_rails['redis_url'] = redis_url
sidekiq['redis_url']      = redis_url

# Timezone & logging
gitlab_rails['time_zone'] = 'Etc/UTC'

# NGINX security hardening (still using internal NGINX)
nginx['hsts_max_age'] = 31536000
nginx['hsts_include_subdomains'] = true
nginx['ssl_protocols'] = "TLSv1.2 TLSv1.3"
nginx['ssl_ciphers'] = "HIGH:!aNULL:!MD5:!3DES:!RC4"
nginx['proxy_read_timeout'] = 3600
nginx['client_max_body_size'] = "1g"

# SSH
gitlab_rails['gitlab_shell_ssh_port'] = 2222
gitlab_sshd['kex_algorithms'] = %w(curve25519-sha256)
gitlab_sshd['ciphers']        = %w(chacha20-poly1305@openssh.com aes256-gcm@openssh.com)
gitlab_sshd['macs']           = %w(umac-128-etm@openssh.com)

# Sidekiq & Puma sizing (adjust to host cores/RAM)
puma['worker_processes'] = [2, 8].min  # e.g., 2 workers; tune to cores
sidekiq['max_concurrency'] = 20        # tune to CPU/RAM

# Gitaly (I/O performance)
gitaly['concurrency'] = [
  { 'rpc' => "/gitaly.SmartHTTPService/PostUploadPack", 'max_per_repo' => 2 },
  { 'rpc' => "/gitaly.SSHService/SSHUploadPack",        'max_per_repo' => 2 }
]

# Backups
gitlab_rails['backup_keep_time'] = 604800
gitlab_rails['backup_archive_permissions'] = 0640
gitlab_rails['manage_backup_path'] = true

# Rate limiting (protect login/API)
gitlab_rails['rack_attack_git_basic_auth'] = {
  'enabled' => true,
  'ip_whitelist' => ["127.0.0.1"]
}
gitlab_rails['throttle_unauthenticated_api_enabled'] = true
gitlab_rails['throttle_unauthenticated_api_requests_per_period'] = 720
gitlab_rails['throttle_unauthenticated_api_period_in_seconds'] = 3600

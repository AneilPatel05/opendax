# frozen_string_literal: true
class Vault

  def vault_secrets_path
    "config/vault-secrets.yml"
  end

  def exec(command)
    `docker-compose exec vault sh -c '#{command}'`
  end

  def unseal(keys)
    keys.each { |key| exec("vault operator unseal #{key}")}
  end

  def login(root_token)
    exec("vault login #{root_token}")
  end

  def secrets( command, endpoints, options="")
    endpoints.each { |endpoint| exec("vault secrets #{command} #{options} #{endpoint}") }
  end

  def save_output(vault_init_output)
    File.write(vault_secrets_path, YAML.dump(vault_init_output))
  end

  def init
    vault_init_output = YAML.safe_load(exec('vault operator init -format yaml --recovery-shares=3 --recovery-threshold=2'))
    vault_root_token = vault_init_output["root_token"]
    unseal_keys = vault_init_output["unseal_keys_b64"][0,3]
    unseal(unseal_keys)
    login(vault_root_token)
    secrets("enable", ["totp", "transit"])
    secrets("disable", ["secret"])
    secrets("enable", ["kv"], "-path=secret -version=1")
    save_output(vault_init_output)
  end
end

vault = Vault.new
vault.init

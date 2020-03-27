
require_relative '../opendax/vault'

namespace :vault do
  desc 'Initialize, unseal and set secrets for Vault'
  task :setup do
    vault = Opendax::Vault.new
    vault_root_token = vault.setup
    # TODO: Update config/app.yml and update vault root token
    # @config["vault"]["token"] = vault_root_token
    # File.open(CONFIG_PATH, 'w') { |f| YAML.dump(@config, f) }
  end
end

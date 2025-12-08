# Disable welcome message per https://www.nushell.sh/book/configuration.html#remove-welcome-message
$env.config.show_banner = false

# Set theme
source ($nu.default-config-dir | path join "themes/catppuccin/themes/catppuccin_mocha.nu")

# Varied completions
source ($nu.default-config-dir | path join "nu_scripts/custom-completions/docker/docker-completions.nu")
source ($nu.default-config-dir | path join "nu_scripts/custom-completions/git/git-completions.nu")
source ($nu.default-config-dir | path join "nu_scripts/custom-completions/nix/nix-completions.nu")

# Starship initialization per https://starship.rs/guide/
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

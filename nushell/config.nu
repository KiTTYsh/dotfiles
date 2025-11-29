# Disable welcome message per https://www.nushell.sh/book/configuration.html#remove-welcome-message
$env.config.show_banner = false

# Starship initialization per https://starship.rs/guide/
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

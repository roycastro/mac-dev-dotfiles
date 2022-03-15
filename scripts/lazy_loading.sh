# If parameter $1 exists as a binary in the path this a function is registered to be executed the first time the parameter $0 is called as binary.
# Once called it automatically unregisters itself and executes the command passed in the parameter $2.
register_lazy_loads() {
  local binary=$1
  local lazy_command=$2

  if [ $commands[$binary] ]; then

    local function_body="
    function $binary() {
      # Remove this function, subsequent calls will execute binary directly
      unfunction \$0
      # Lazy command execution
      $lazy_command

      # check if a parameter was passed
      if [ \$# -gt 0 ]; then
        # Execute binary
        \$0 ''\$@
      else
        echo 'Lazy Function Loaded for '\$0
      fi

    }
    "
    eval "$function_body"
  fi

}

register_lazy_loads "yc" "source $(brew --prefix)/Caskroom/yandex-cloud-cli/latest/yandex-cloud-cli/completion.zsh.inc"
register_lazy_loads "kubectl" "source <(kubectl completion zsh)"
register_lazy_loads "node" "source $(brew --prefix nvm)/nvm.sh"

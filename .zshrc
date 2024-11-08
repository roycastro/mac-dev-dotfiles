#
# .zshrc
#
# @author Roy Castro
#

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# Enable plugins.
plugins=(git brew ansible battery cp doctl extract history npm oc pm2 zsh-navigation-tools docker docker-compose gcloud terraform )
source $ZSH/oh-my-zsh.sh

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# Refer to the following link for more information on this command: https://github.com/pyenv/pyenv/issues/784#issuecomment-826444110
eval "$(pyenv init --path --no-rehash)"

# Custom $PATH with extra locations.
export PATH=/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/go/bin:/usr/local/git/bin:$HOME/.composer/vendor/bin:$(pyenv root)/shims:$PATH

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

# Alias BAT as default cat.
alias cat=bat

# Custom Profile Modifications                                                                                                                                
if [ -f ~/.profile_customizations ]                                                                                                                             
then                                                                                                                                                    
  source ~/.profile_customizations                                                                                                                               
fi                                                                                                                                                      
# End Custom Profile Modifications  

# Lazy Loaded Binaries                                                                                                                                
if [ -f ~/.dotfiles/configs/scripts/lazy_loading.sh ]                                                                                                                             
then                                                                                                                                                    
  source ~/.dotfiles/configs/scripts/lazy_loading.sh                                                                                                                               
fi                                                                                                                                                      
# End Lazy Loaded Binaries  

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Git aliases.
alias gs='git status'
alias gc='git commit'
alias gp='git pull --rebase'
alias gcam='git commit -am'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Completions.
autoload -Uz compinit && compinit
# source "$(brew --prefix)/Caskroom/yandex-cloud-cli/latest/yandex-cloud-cli/completion.zsh.inc"
# source <(kubectl completion zsh)
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

# Allow Composer to use almost as much RAM as Chrome.
export COMPOSER_MEMORY_LIMIT=-1

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export TNS_ADMIN="$HOME/"

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Open tmux session if it exists, otherwise create a new one.
function openTmux() {
 local session=$1
 if [[ ! "$session" ]] ; then
  session=$(tmux list-sessions -F \#S | gum filter --placeholder "Pick session...")
  if [ $? -ne 0 ]; then
   return 0 
  fi 
 fi

 if tmux has-session -t "$session" 2>/dev/null; then
   tmux attach-session -t $session || tmux switch-client -t $session
 else
   tmux new-session -s "$1"
 fi
}

export FZF_TMUX=1
export FZF_TMUX_OPTS='-p80%,60%'
export FZF_DEFAULT_OPTS='--bind '?:toggle-preview' --preview-window down:20:hidden:wrap  --preview "cat {}" --color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672'
export FZF_DEFAULT_COMMAND="fd --strip-cwd-prefix --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf-tmux "$@" -p80%,60% --preview 'tree -C {} | head -200' ;;
    ssh)          fzf-tmux "$@" -p80%,60% --preview '~/.dotfiles/configs/scripts/ip_host_info.sh {} | head -200' ;;
    *)            fzf-tmux "$@" -p80%,60% ;;
  esac
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ~/.config/zsh/plugins.zsh
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use

zstyle ':zsh-eza:config' autocd yes
zi ice has'eza'
zi light z-shell/zsh-eza

# Librerías y plugins de Oh My Zsh (OMZ)
zinit snippet OMZL::git.zsh
zinit snippet OMZL::key-bindings.zsh

zinit ice atload"unalias grv" lucid wait"0"
zinit snippet OMZP::git

zinit ice wait"0" lucid
zinit snippet OMZP::colored-man-pages

zinit ice wait"0" lucid
zinit snippet OMZP::docker

# Autocompletados desde URLs directas
zinit ice as"completion" lucid wait"0"
zinit snippet https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/docker/completions/_docker

zinit ice as"completion" lucid wait"0"
zinit snippet https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza

# Autocompletado nativo para Chezmoi
zinit ice as"completion" has"chezmoi" id-as"chezmoi" nocompile \
    atclone"chezmoi completion zsh > _chezmoi" atpull"%atclone"
zinit light zdharma-continuum/null

# Inicialización de Starship
zinit ice has"starship" id-as"starship-init" nocompile \
    atclone"starship init zsh > init.zsh; starship completions zsh > _starship" \
    atpull"%atclone" src"init.zsh"
zinit light zdharma-continuum/null
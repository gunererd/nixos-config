set -U fish_greeting
set -g fish_term24bit 1

set -gx NVM_DIR $HOME/.nvm
bass source $NVM_DIR/nvm.sh

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux FLYCTL_INSTALL /home/hippo/.fly
set -Ux VISUAL hx
set -Ux EDITOR hx

set -x JAVA_HOME /usr/lib/jvm/java-17-openjdk
set -x PATH $JAVA_HOME/bin $PATH

set -Ux HELIX_RUNTIME /home/hippo/Repositories/helix/runtime

set -Ux fish_user_paths /home/hippo/.emacs.d/bin /home/hippo/.config/emacs/bin /home/hippo/go/bin /home/hippo/.dprint $FLYCTL_INSTALL/bin $fish_user_paths ~/.config/zide/bin

alias l="eza -la"
alias lg="lazygit -ucf ~/.config/lazygit/config.yml"
alias vim="nvim"
alias helix="hx"
alias b="btop"
alias tm="task-master"
alias n="nnn -deAUH"

# function nn
#     zellij action new-tab
#     zellij action new-pane --direction right
#     zellij action write-chars "cd $PWD && nnn"(echo -e "\r")
#     zellij action focus-previous-pane
#     zellij action write-chars "cd $PWD && nnn"(echo -e "\r")
# end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if test -s "$tmp"
        set cwd (cat -- "$tmp")
        if test -n "$cwd" -a "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
    end
    rm -f -- "$tmp"
end

zoxide init --cmd cd fish | source

function z
    cd (zoxide query -i)
end

set -x STARSHIP_CONFIG ~/.config/starship/starship.toml
starship init fish | source

thefuck --alias | source

function notify
    set input $argv[1]
    if not test -z $input
        zellij pipe "zjstatus::notify::$input"
    end
end

direnv hook fish | source

# uv
fish_add_path "/home/hippo/.local/bin"

atuin init fish --disable-up-arrow | source

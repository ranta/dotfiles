alias ll='ls -la | sort -r | awk '\''NF==9 { if ($1~/^d/) { printf $1 "/" $2 "/" $3 "/" $4 "/" $5 "/" $6 " " $7 "/" $8 " " "\033[1;34m" $9 "\033[0m" "\n" } else { printf $1 "/" $2 "/" $3 "/" $4 "/" $5 "/" $6 " " $7 "/" $8 " " "\033[1;32m" $9 "\033[0m" "\n" } }'\'' | column -t -s"/"'

alias b='cd ..'
alias bb='cd ../..'
alias bbb='cd ../../..'
alias bbbb='cd ../../../..'

alias F='open .'  # Open Finder in the current directory.

alias cp='cp -v'
alias mv='mv -v'
alias grep='GREP_COLOR="1;91" grep --color'

alias cls='printf "\033c"'

flushdns () {
    # https://support.apple.com/en-ca/HT202516
    sudo killall -HUP mDNSResponder && echo 'DNS cache cleared'
}

# Python & Django
alias pip='pip3'
alias update='pip install --disable-pip-version-check -r requirements.txt && pip install --disable-pip-version-check -r requirements-dev.txt && pip install psycopg2'
alias ff='isort . && black . && flake8'  # Format file :)

alias pmm='python manage.py migrate'
alias runserver='python manage.py runserver 0.0.0.0:8000'

# Translations
alias mm='python ../../manage.py shuup_makemessages'
alias cm='python ../../manage.py compilemessages'

# Shuup
setup_project_old () {
    (
        # Run in a subshell to not close the current shell on error.
        set -e

        mkdir -p "$HOME/Github/$2/app"
        git clone "git@github.com:ranta/$2.git" "$HOME/Github/$2/app"
        cd "$HOME/Github/$2/app"
        git remote add upstream "git@github.com:shuup/$2.git"

        createdb "$1"
        
        pyenv virtualenv 3.6.12 "$1"
        cd ..
        pyenv local "$1"
        cd app

        sed -e "s/<db_name>/$1/" -e 's/root:root/postgres:/' .env.template > .env
        echo "EMAIL_URL=consolemail://" >> .env

        pip install --disable-pip-version-check --upgrade prequ setuptools wheel psycopg2 autoflake
        [ -f requirements.txt ] && pip install --disable-pip-version-check -r requirements.txt
        [ -f requirements-dev.txt ] && pip install --disable-pip-version-check -r requirements-dev.txt
        [ -f requirements-test.txt ] && pip install --disable-pip-version-check -r requirements-test.txt

        python setup.py build_resources

        python manage.py migrate
    ) && cd "$HOME/Github/$2/app"
}
cloneaddon () {
    (
        # Run in a subshell to not close the current shell on error.
        set -e

        mkdir -p "$HOME/Github/$1"
        git clone "git@github.com:ranta/$1.git" "$HOME/Github/$1"
        cd "$HOME/Github/$1"
        git remote add upstream "git@github.com:shuup/$1.git"

    )
}

# Git
gub () {
    # Update the curent branch to the latest primary remote HEAD.
    local status
    local remote
    local head
    local current

    git pull 2> /dev/null
    status="$(git status --porcelain --ignore-submodules)"
    [ -n "$status" ] && git stash push --include-untracked
    git fetch --all --tags --prune
    remote=$(git remote | grep -E '(upstream|origin)' | tail -1)
    head=$(git remote show "$remote" | awk '/HEAD branch/ {print $NF}')
    current="$(git rev-parse --abbrev-ref HEAD)"
    if [ "$current" != "$head" ]; then
        git switch "$head"
        git rebase "${remote}/${head}"
        git switch -
        git rebase "$head"
    else
        git rebase "${remote}/${head}"
    fi
    if [ -n "$status" ]; then
        git stash pop
    fi
}
gps () {
    # Push the current branch.
    git push --follow-tags "$@" || { [ "$?" -eq 128 ] && git push --follow-tags --set-upstream origin HEAD; }
}
gff () {
    # Fast-forward to upstream/master
    git rebase "upstream/master"
}

# ngrok
alias ngrok='ngrok http 8000'

# Brew
brew () {
    if [[ "$*" == "up" ]]; then
        command brew update && brew upgrade && brew upgrade --cask
    elif [[ "$*" == "dump" ]]; then
        command brew bundle dump --force --no-restart --file ~/dotfiles/brew/Brewfile
    elif [[ "$*" == "load" ]]; then
        command brew bundle --file=~/dotfiles/brew/Brewfile
    else
        command brew "$@"
    fi
}

# Android development
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Colored man pages and `less`'s help.
export LESS_TERMCAP_mb=$_blue   # mb = start blink
export LESS_TERMCAP_md=$_orange # md = start bold
export LESS_TERMCAP_me=$_reset  # me = stop bold, blink, and underline
export LESS_TERMCAP_se=$_reset  # se = stop standout
export LESS_TERMCAP_so=$_base03$(tput setab 12) # so = start standout (e.g. search matches)
export LESS_TERMCAP_ue=$_reset  # ue = stop underline
export LESS_TERMCAP_us=$_green  # us = start underline

# FZF
export FZF_IGNORES=Applications,Library,Movies,Music,Pictures,Qt,node_modules,venv,.DS_Store,.Trash,.cache,.git,.mypy_cache,.npm,.pyenv,.pytest_cache,.stack,.temp,__pycache__
export FZF_DEFAULT_COMMAND='command fd --hidden --no-ignore --exclude "{$FZF_IGNORES}" .'
export FZF_ALT_C_COMMAND='command fd --type d --type l --hidden --no-ignore --exclude "{$FZF_IGNORES}" .'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER='*'

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Poetry
export PATH="$HOME/.poetry/bin:$PATH"

poetry () {
    if [[ "$1" == "install" ]]; then
        command poetry install --no-root "${@:2}"
    else
        command poetry "$@"
    fi
}

# Pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv_list () {
    local versions
    versions="$(pyenv install --list)"
    for version in 6 7 8
    do
         echo "${versions}" | grep -E "^\s+3\.${version}" | tail -1
    done
    for version in 9 10
    do
         echo "${versions}" | grep -E "^\s+3\.${version}"
    done
}

export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

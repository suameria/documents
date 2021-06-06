# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd .. ; ll'
alias c='clear'
alias laradock='cd /vagrant/laradockch'

# Docker Command
alias dce='docker-compose exec'
alias dup='docker-compose up -d'
alias dps='docker-compose ps'
alias stop='cd /vagrant/laradockch ; docker-compose stop'
alias run='cd /vagrant/laradockch ; docker-compose up -d workspace nginx php-fpm mysql dynamodb redis mailhog'
alias workspace='cd /vagrant/laradockch ; docker-compose exec workspace bash'
alias nginx='cd /vagrant/laradockch ; docker-compose exec nginx bash'
alias mysql='cd /vagrant/laradockch ; docker-compose exec mysql bash'
alias phpfpm='cd /vagrant/laradockch ; docker-compose exec php-fpm bash'
alias dynamodb='cd /vagrant/laradockch ; docker-compose exec dynamodb bash'

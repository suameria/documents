Wordpress導入手順

mkdir {project-name}

cd {project-name}

vi Vagrantfile

vi docker-compose.yml

mkdir wordpress

vagrant up

vagrant ssh

vi .bashrc

```text
alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd .. ; ll'
alias c='clear'
alias laradock='cd /vagrant/laradock'

# Docker Command
alias dce='docker-compose exec'
alias dup='docker-compose up -d'
alias dps='docker-compose ps'
alias mamolp='cd /vagrant/mamosearchlp/wordpress'
alias stop='cd /vagrant/mamosearchlp/wordpress ; docker-compose stop'
alias run='cd /vagrant/mamosearchlp/wordpress ; docker-compose up -d'
alias db='cd /vagrant/mamosearchlp/wordpress ; docker-compose exec db bash'
alias wordpress='cd /vagrant/mamosearchlp/wordpress ; docker-compose exec wordpress bash'
```

run



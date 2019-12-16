# Nucleo Website

## Rodando o projeto

Requisitos: ruby, rails

### Setup

```
bundle install

rake db:create
rake db:migrate
rake db:seed

rake localizable:setup
```

## Para Conectar ##

```
ssh root@174.138.92.213
```


```
su - deploy-nucleo
```

Credentials at: https://trello.com/c/p7vBbCV1/101-digital-ocean-droplet-nucleo-websites
```

# Para verificar espaço livre #

```
# Para listar o disco principal
df -h | grep /dev/vda1

# Para listar todos os discos
df -h
```


# Para salvar o log e historico de entrevistas #

1 - On Server
```
mkdir "logs-$(date +"%Y-%m-%d")"
cd "logs-$(date +"%Y-%m-%d")"

mkdir nucleo
cd nucleo
cp /home/deploy-nucleo/nucleo-website/shared/log/* ./ -R
cd ..
mkdir lucas
cd lucas
cp /home/deploy-lucas/lucas-website/shared/log/* ./ -R
cd ..
mkdir gauss
cd gauss
cp /home/deploy-gauss/gauss-website/shared/log/* ./ -R
cd ..
cd ..
tar -czvf "logs-$(date +"%Y-%m-%d").tar.gz" ./"logs-$(date +"%Y-%m-%d")"
```

2 - Locally
```
scp root@45.55.211.201:/root/"logs-$(date +"%Y-%m-%d").tar.gz" ./log/"logs-$(date +"%Y-%m-%d").tar.gz"
tar -xzvf log/"logs-$(date +"%Y-%m-%d").tar.gz" -C log
```

3 - Back on Server
```
sudo rm /home/deploy-nucleo/nucleo-website/shared/log/*.log -f
sudo rm /home/deploy-lucas/lucas-website/shared/log/*.log -f
sudo rm /home/deploy-gauss/gauss-website/shared/log/*.log -f
rm -rf "logs-$(date +"%Y-%m-%d")"
rm "logs-$(date +"%Y-%m-%d").tar.gz"

sudo kill -9 $(sudo lsof | grep deleted | grep shared/log | sed -r 's/[^ ]* ([0-9]*).*/\1/g' | sed '/^$/d' | uniq)
```

4 - Locally (to restart server)
```
cap production deploy
cd log/"logs-$(date +"%Y-%m-%d")"
```
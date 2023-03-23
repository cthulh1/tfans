# Terraform + ansible конфиг

## Описание

Terraform манифест создает указанное в tfvars количество vps(digitalocean) и dns-записей(aws), создает пользователя, задает пароль root и отправляет public key для удаленного доступа и генерирует ansible файл inventory.yml. Ansible playbook.yml устанавливает и настраивает nginx на удаленных хостах и проводит tls-сертификацию.

## Требования

- Отредактируйте файл terraform.tfvars.sample и заполните значения переменных.

## Пример запуска playbook

ansible-playbook playbook.yml --ask-vault-pass

## Автор

- Аронов Александр <aronov.alexx@gmail.com>
 
 
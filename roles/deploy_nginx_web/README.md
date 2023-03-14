# Ansible роль: deploy_nginx_vhs_web

## Описание

Эта роль позволяет установить Nginx и загрузить index.html на основе шаблонов на заданное количество удаленных машин.

## Требования

- Убедитесь, что у вас есть права доступа для запуска роли на удаленных хостах.

## Параметры

| Параметр | Описание | Значения |
| --- | --- | --- |
| `html_path` | Путь к корневой директории сайта. | `/var/www/html/{{ item.value.html_path }}/` |
| `nginx_sr` | Путь к шаблону конфигурации Nginx. | `templates/nginx.conf.j2` |
| `vh_name` | Путь к шаблону конфигурации virtualhost. | `templates/virtualhost.conf.j2` |
| `http_port` | HTTP порт для виртуального хоста. | {{ item.value.vh_port }} |


## Автор

- Аронов Александр <aronov.alexx@gmail.com>

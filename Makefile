all: build

build:
	docker builder build -t closehandle/php:7.4-fpm --network host 7.4
	docker builder build -t closehandle/php:8.0-fpm --network host 8.0
	docker builder build -t closehandle/php:8.1-fpm --network host 8.1
	docker builder build -t closehandle/php:8.2-fpm --network host 8.2
	docker builder build -t closehandle/php:8.3-fpm --network host 8.3

clean:
	docker system prune -af
	docker volume prune -af

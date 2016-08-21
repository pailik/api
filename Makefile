IMAGES = kubikvest/api
CONTAINERS = kubikvest

build: composer
	@docker build -t kubikvest/api .

composer:
	@docker run --rm -v $(CURDIR):/data imega/composer install --ignore-platform-reqs --no-interaction

start:
	@docker run -d --name "kubikvest_db" imega/mysql

	@docker run --rm \
		--link kubikvest_db:kubikvest_db \
		imega/mysql-client \
		mysqladmin --silent --host=kubikvest_db --wait=5 ping

	@docker run --rm \
		-v $(CURDIR)/sql:/sql \
		--link kubikvest_db:kubikvest_db \
		imega/mysql-client \
		mysql --host=teleport_db -e "source /sql/kubikvest.sql"

	@docker run -d \
		--name "kubikvest" \
		-v $(CURDIR):/app \
		-p 9005:9095 \
		kubikvest/api \
		php-fpm -F \
			-d error_reporting=E_ALL \
			-d log_errors=On \
			-d error_log=/dev/stdout \
			-d display_errors=On \
			-d always_populate_raw_post_data=-1

	@docker run -d \
		--name "kubikvest_nginx" \
		--link kubikvest:kubikvest \
		-p 80:80 \
		-v $(CURDIR)/sites-enabled:/etc/nginx/sites-enabled \
		leanlabs/nginx

stop:
	-docker stop $(CONTAINERS)

clean: stop
	-docker rm -fv $(CONTAINERS)

destroy: clean
	-docker rmi -f $(IMAGES)

.PHONY: build

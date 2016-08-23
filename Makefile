include vars.mk

IMAGES = kubikvest/api
CONTAINERS = kubikvest_db kubikvest kubikvest_nginx

build: composer
	@docker build -t kubikvest/api .

composer:
	@docker run --rm -v $(CURDIR):/data imega/composer install --ignore-platform-reqs --no-interaction

start: build
	@docker run -d --name "kubikvest_db" imega/mysql

	@docker run --rm \
		--link kubikvest_db:kubikvest_db \
		imega/mysql-client \
		mysqladmin --silent --host=kubikvest_db --wait=5 ping

	@docker run --rm \
		-v $(CURDIR)/sql:/sql \
		--link kubikvest_db:kubikvest_db \
		imega/mysql-client \
		mysql --host=kubikvest_db -e "source /sql/kubikvest.sql"

	@docker run -d \
		--name "kubikvest" \
		--link "mock_server_vk:vk-server" \
		-v $(CURDIR):/app \
		-e VK_CLIENT_ID=$(VK_CLIENT_ID) \
		-e VK_CLIENT_SECRET=$(VK_CLIENT_SECRET) \
		-e VK_REDIRECT_URI=$(VK_REDIRECT_URI) \
		-e URI_OAUTH_VK=$(URI_OAUTH_VK) \
		kubikvest/api \
		php-fpm -F \
			-d ENV[VK_CLIENT_ID]=1122 \
			-d error_reporting=E_ALL \
			-d log_errors=On \
			-d error_log=/dev/stdout \
			-d display_errors=On \
			-d always_populate_raw_post_data=-1

	@docker run -d \
		--name "kubikvest_nginx" \
		--link kubikvest:service \
		-v $(CURDIR):/app \
		-p 8300:80 \
		-v $(CURDIR)/sites-enabled:/etc/nginx/sites-enabled \
		leanlabs/nginx

test: build
	cd tests/mock-servers/vk;make start

	@docker run -d --name "kubikvest_db" imega/mysql

	@docker run --rm \
		--link kubikvest_db:kubikvest_db \
		imega/mysql-client \
		mysqladmin --silent --host=kubikvest_db --wait=5 ping

	@docker run --rm \
		-v $(CURDIR)/sql:/sql \
		--link kubikvest_db:kubikvest_db \
		imega/mysql-client \
		mysql --host=kubikvest_db -e "source /sql/kubikvest.sql"

	@docker run -d \
		--name "kubikvest" \
		--link "mock_server_vk:vk-server" \
		--link kubikvest_db:kubikvest_db \
		-v $(CURDIR):/app \
		-e VK_CLIENT_ID=$(VK_CLIENT_ID) \
		-e VK_CLIENT_SECRET=$(VK_CLIENT_SECRET) \
		-e VK_REDIRECT_URI=$(VK_REDIRECT_URI) \
		-e URI_OAUTH_VK=$(URI_OAUTH_VK) \
		-e URL=$(URL) \
		-e KEY=$(KEY) \
		kubikvest/api \
		php-fpm -F \
			-d ENV[VK_CLIENT_ID]=1122 \
			-d error_reporting=E_ALL \
			-d log_errors=On \
			-d error_log=/dev/stdout \
			-d display_errors=On \
			-d always_populate_raw_post_data=-1

	@docker run -d \
		--name "kubikvest_nginx" \
		--link kubikvest:service \
		-v $(CURDIR):/app \
		-p 8300:80 \
		-v $(CURDIR)/sites-enabled:/etc/nginx/sites-enabled \
		leanlabs/nginx

stop:
	-docker stop $(CONTAINERS)

clean: stop
	-docker rm -fv $(CONTAINERS)

destroy: clean
	cd tests/mock-servers/vk;make destroy
	-docker rmi -f $(IMAGES)

.PHONY: build

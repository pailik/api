NAME = kubikvest/mock_server_vk
TAG = 1.0.0
CONTAINER = mock_server_vk

build:
	@docker build -t $(NAME) .

start: build
	@docker run -d --name mock_server_vk $(NAME)

test: start
	@docker run --rm -t -v $(CURDIR)/tests:/tests \
		--link mock_server_vk:vk-server \
		alpine sh -c 'apk add --update bash curl && tests/index.sh vk-server'

stop:
	@docker stop $(CONTAINER)

clean: stop
	@docker rm -fv $(CONTAINER)

destroy: clean
	@docker rmi -f $(NAME)

.PHONY: build tests

CONTAINER?=$(shell basename $(CURDIR))-php-1
BUILDCHAIN?=$(shell basename $(CURDIR))-vite-1

.PHONY: build clean composer craft dev npm nuke ssh up

build: up
	docker exec -it ${BUILDCHAIN} npm run build
clean:
	rm -f cms/composer.lock
	rm -rf cms/vendor/
	rm -f buildchain/package-lock.json
	rm -rf buildchain/node_modules/
composer: up
	docker exec -it ${CONTAINER} su-exec www-data composer \
		$(filter-out $@,$(MAKECMDGOALS))
craft: up
	docker exec -it ${CONTAINER} su-exec www-data php craft \
		$(filter-out $@,$(MAKECMDGOALS))
dev: up
npm: up
	docker exec -it ${BUILDCHAIN} npm \
		$(filter-out $@,$(MAKECMDGOALS))
nuke: clean
	docker-compose down -v
	docker-compose up --build --force-recreate
ssh:
	docker exec -it ${CONTAINER} su-exec www-data /bin/sh
up:
	if [ ! "$$(docker ps -q -f name=${CONTAINER})" ]; then \
		cp -n cms/example.env cms/.env; \
		docker-compose up; \
    fi
%:
	@:
# ref: https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line

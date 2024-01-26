PHONY: debug test
docker_cmd := docker run --rm -it -v "./templates:/templates" -v "./flows:/flows" -v "./.env:/.env" --add-host=host.docker.internal:host-gateway jeffail/benthos:edge --env-file "./.env"

debug:
	@${docker_cmd} --log.level=DEBUG -t "templates/*.yaml" -c $(FILE)

run:
	@{docker_cmd} --log.level=DEBUG -t "templates/*.yaml" -c $(FILE)

lint:
	@{docker_cmd} --log.level=DEBUG -t "templates/*.yaml" -c $(FILE) lint

test:
	@{docker_cmd} --log.level=DEBUG -t "templates/*.yaml" test --log TRACE $(FILE)

blobl:
	@docker run --rm -it -p "24195:24195" -v "./.env:/.env" --add-host=host.docker.internal:host-gateway jeffail/benthos:edge --env-file "./.env" blobl server -n -p 24195 --host 0.0.0.0
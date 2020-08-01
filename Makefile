all: docker-push

.PHONY: docker-build
docker-build:
	docker build -t cbarraco/insta-env:latest .

.PHONY: docker-push
docker-push: docker-build
	docker push cbarraco/insta-env:latest

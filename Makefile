TAG := $(shell date +%Y%m%d_%H%M%S)

.PHONY:
init: down volume pull build up
down:
	docker compose down
volume:
	docker volume prune -f
pull:
	docker compose pull
build:
	docker compose build
up:
	docker compose up -d
	docker ps -a
ps:
	docker compose ps
lint:
	docker compose run --rm functions yarn --cwd functions lint
test:
	docker compose run --rm functions yarn test:e2e
fixtures:
	docker compose run --rm functions yarn fixtures
terraform.init:
	@if [ -d "./infra/.terraform" ]; then \
		echo "Terraform is initialized."; \
	else \
		echo "Terraform is not initialized."; \
		terraform -chdir=infra init; \
	fi
terraform.apply:
	terraform -chdir=infra apply -auto-approve
terraform.output:
	terraform -chdir=infra output
terraform.output.environment:
	@export $(shell terraform -chdir=infra output -json | jq -r 'to_entries|map("\(.key | ascii_upcase)=\(.value.value)")|.[]' | xargs)
terraform.fmt:
	terraform -chdir=infra fmt -check
terraform.diff:
	terraform -chdir=infra fmt -diff
terraform.validate:
	terraform -chdir=infra validate
api.docker.build:
	docker buildx build --platform linux/amd64 -t $(PROJECT_NAME) ./api
api.docker.run:
	docker run --platform linux/amd64 -p 9000:8080 $(PROJECT_NAME):latest
api.docker.tag: api.docker.build
	docker tag $(PROJECT_NAME):latest $(ECR_DEFAULT_REPOSITORY_URL):latest
api.docker.push: api.docker.tag
	docker push $(ECR_DEFAULT_REPOSITORY_URL):latest
aws.lambda.publish:
	aws lambda publish-version --function-name $(PROJECT_NAME)
aws.lambda.update:
	aws lambda update-function-code --function-name $(PROJECT_NAME) --image-uri $(ECR_DEFAULT_REPOSITORY_URL):latest --architecture x86_64
aws.apigw.deploy:
	aws apigateway create-deployment --rest-api-id $(API_GATEWAY_ID) --stage-name $(ENVIRONMENT)
aws.cognito.auth:
	aws cognito-idp initiate-auth --client-id $(COGNITO_USER_POOL_CLIENT_ID) --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$(ADMIN_DEFAULT_USER),PASSWORD=$(DEFAULT_USER_PASSWORD) --query 'AuthenticationResult.IdToken' --output text
http.rest:
	@TOKEN=$$(make --silent aws.cognito.auth) && \
	http POST $(BASE_URL)/rest Authorization:$$TOKEN
http.graphql:
	@TOKEN=$$(make --silent aws.cognito.auth) && \
	http POST "$(BASE_URL)/graphql" Authorization:$$TOKEN <<< '{"query": "{ hello }"}'
deploy: terraform.init terraform.apply api.docker.push aws.lambda.update aws.apigw.deploy
chrome.attach.debug: up
	google-chrome --remote-debugging-port=9222 --user-data-dir=remote-debug-profile
topic.hello_app:
	docker compose exec kafka kafka-topics --create --topic hello-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092
start_app:
	poetry run python src/app.py worker --web-port=9876
topic.hello_app.separator:
	docker compose exec kafka kafka-topics --create --topic hello-topic-separator --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

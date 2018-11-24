CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
EXAMPLE_DIR = $(sort $(dir $(wildcard examples/*/)))


help:
	@echo "lint       Static source code analysis"
	@echo "test       Integration tests"

lint:
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Terraform fmt"
	@echo "################################################################################"
	@if docker run -it --rm -v "$(CURRENT_DIR)/terraform:/t:ro" hashicorp/terraform:light \
		fmt -check=true -diff=true -write=false -list=true /t; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo

test:
	@# Test Initialization of all Terraform projects
	@$(foreach example,\
		$(EXAMPLE_DIR),\
		echo "################################################################################"; \
		echo "# Terraform init: $(example)"; \
		echo "################################################################################"; \
		docker run -it --rm -v "$(CURRENT_DIR):/t" hashicorp/terraform:light \
			init -verify-plugins=true -lock=false -input=false -get-plugins=true -get=true /t/$(example); \
		echo; \
	)

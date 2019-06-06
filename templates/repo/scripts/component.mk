# Auto-generated by fogg. Do not edit
# Make improvements in fogg, so that everyone can benefit.

SELF_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

include $(SELF_DIR)/common.mk

all:

check: lint check-plan

fmt: terraform
	$(sh_command) -c 'for f in $(TF); do printf .; terraform fmt $$f; done'; \
	echo

lint: terraform-validate lint-terraform-fmt lint-tflint

lint-tflint: init
	if (( $$TFLINT_ENABLED )); then \
    $(sh_command) -c 'tflint' || exit $$?; \
	fi \

terraform-validate: terraform init
	$(sh_command) -c 'terraform validate'

lint-terraform-fmt: terraform
	$(sh_command) -c 'for f in $(TF); do printf .; terraform fmt --check=true --diff=true $$f || exit $$? ; done'

get: ssh-forward terraform
	$(terraform_command) get --update=true

plan: terraform fmt get init ssh-forward
	$(terraform_command) plan

apply: FOGG_DOCKER_FLAGS = -it
apply: terraform fmt get init ssh-forward
	$(terraform_command) apply -auto-approve=$(AUTO_APPROVE)

docs:
	echo

clean:
	-rm -rfv .terraform/modules
	-rm -rfv .terraform/plugins

test:

init: terraform ssh-forward
	$(terraform_command) init -input=false

check-plan: terraform init get ssh-forward
	$(terraform_command) plan -detailed-exitcode; \
	ERR=$$?; \
	if [ $$ERR -eq 0 ] ; then \
		echo "Success"; \
	elif [ $$ERR -eq 1 ] ; then \
		echo "Error in plan execution."; \
		exit 1; \
	elif [ $$ERR -eq 2 ] ; then \
		echo "Diff";  \
	fi

ssh-forward:
ifdef USE_DOCKER
	bash $(REPO_ROOT)/scripts/docker-ssh-forward.sh
endif

run: FOGG_DOCKER_FLAGS = -it
run:
	$(terraform_command) $(CMD)

.PHONY: all apply clean docs fmt get lint plan run ssh-forward test

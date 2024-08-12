.PHONY: test

help: # display Makefile commands
	@awk 'BEGIN { FS = ":.*#"; print "Usage:  make <target>\n\nTargets:" } \
  /^[-_[:alpha:]]+:.?*#/ { printf "  %-15s%s\n", $$1, $$2 }' $(MAKEFILE_LIST)

#######################
# Local development commands
#######################

run: # runs server on localhost
	bin/rails server

console: # runs console
	bin/rails console

test: # Run tests
	bin/rails test

coverage: test # Run tests and open coverage report in default web browser
	open coverage/index.html

#######################
# Documentation commands
#######################

annotate: # update Rails models documentation header
	bundle exec annotate --models

docserver: # runs local documentation server
	rm -rf .yardoc # Clears cache as it's sketchy af
	yard server --reload

#######################
# Dependency commands
#######################

install: # Install dependencies
	bundle install

outdated: # List outdated dependencies
	bundle outdated

####################################
# Code quality and safety commands
####################################

lint:
	bundle exec rubocop

lint-models:
	bundle exec rubocop app/models

lint-controllers:
	bundle exec rubocop app/controllers

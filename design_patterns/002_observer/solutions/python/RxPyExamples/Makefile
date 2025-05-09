.PHONY:	upgrade_setuptools install install_dev test settings help
.SILENT: coverage


# -----------------------------------------------------------------------------
# Dependency installation Makefile rules
# -----------------------------------------------------------------------------
main:
	python ./src/main.py

main2:
	python ./src/main2.py


# -----------------------------------------------------------------------------
# Dependency installation Makefile rules
# -----------------------------------------------------------------------------
upgrade_pip:
	pip install --upgrade pip

install:
	pip install --requirement requirements.txt

install_test:
	pip install --requirement requirements_test.txt

install_all: upgrade_pip
	pip install --requirement requirements_all.txt


# -----------------------------------------------------------------------------
# Running tests Makefile rules
# -----------------------------------------------------------------------------
test:
	python -m unittest discover --start-directory tests

test_v:
	python -m unittest discover --start-directory tests --verbose

test_ff:
	python -m unittest discover --start-directory tests --failfast

test_vff:
	python -m unittest discover --start-directory tests --verbose --failfast

%:
	@:

test_1:
	python -m unittest "tests.$(filter-out $@,$(MAKECMDGOALS))"

coverage:
	coverage run --source ./src --omit ./tests/*  -m unittest discover --start-directory tests
	@echo
	coverage report
	coverage xml


# -----------------------------------------------------------------------------
# Clean up Makefile rules
# -----------------------------------------------------------------------------
clean:
	@echo "deleting python and test artifacts:"
	@echo "___________________"
	find . -name "__pycache__" -type d -prune -exec rm -r {} \;
	rm -rf .serverless
	rm .coverage coverage.xml


# -----------------------------------------------------------------------------
# Display info Makefile rules
# -----------------------------------------------------------------------------
settings:
	@echo "HOME             = ${HOME}"
	@echo "PWD              = ${PWD}"
	@echo "SHELL            = ${SHELL}"

help:
	@echo "Targets:"
	@echo "--------------------------------------------------------------------------------"
	@echo "  main               - run main application"
	@echo "--------------------------------------------------------------------------------"
	@echo "  install            - installs required packages"
	@echo "  install_test       - installs required packages for testting"
	@echo "  install_all        - installs required packages for development"
	@echo "--------------------------------------------------------------------------------"
	@echo "  test               - runs test"
	@echo "  test_v             - runs test with verbose messaging"
	@echo "  test_ff            - runs test fast fail"
	@echo "  test_vff           - runs test fast fail with verbose messaging"
	@echo "  test_1 <file.class.test> - runs a single test"
	@echo "  coverage           - runs test, produces coverage and displays it"
	@echo "  clean              - cleans some auto generated build files"
	@echo "--------------------------------------------------------------------------------"
	@echo "  settings           - outputs current settings"
	@echo "  help               - outputs this info"

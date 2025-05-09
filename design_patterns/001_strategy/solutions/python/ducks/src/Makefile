.PHONY:	upgrade_setuptools install install_dev test settings help
.SILENT: coverage

upgrade_setuptools:
	python -m pip install --upgrade pip setuptools

# install: upgrade_setuptools
# 	pip install --requirement requirements.txt

main:
	python main.py

# test:
# 	python -m unittest discover --start-directory .

# test_ff:
# 	python -m unittest discover --start-directory . --failfast

# test_verbose:
# 	python -m unittest discover --start-directory . --verbose

# coverage:
# 	coverage run --source ../ --omit="./*,../examples.py" -m unittest discover --start-directory .
# 	@echo
# 	coverage report
# 	coverage xml

settings:
	@echo "HOME             = ${HOME}"
	@echo "PWD              = ${PWD}"
	@echo "SHELL            = ${SHELL}"

help:
	@echo "Targets:"
	@echo "-----------------------------------------------------------------------------"
	@echo "  install      - installs required packages"
	@echo "  test         - runs all tests"
	@echo "  test_ff      - runs all tests and stops at 1st failed test"
	@echo "  test_verbose - runs all tests with verbose messaging"
	@echo "  coverage     - runs test, produces coverage and displays it"
	@echo "-----------------------------------------------------------------------------"
	@echo "  settings     - outputs current settings"
	@echo "  help         - outputs this info"

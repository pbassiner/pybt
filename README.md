# pybt
An opinionated Python build tool (backed by pipenv).

## Disclaimer
This is just for personal convenience. It's not intended to be a general purpose build tool nor replace anything from the Python ecosystem.

## Description
The purpose of this build tool is to ease the development process of a Python project using the CLI by allowing to chain multiple commands. It is implemented in `Bash`, with the help of [argbash](https://github.com/matejak/argbash).

## Installation
Just download the executable [bin/pybt](bin/pybt) and put it anywhere in your executable path.

## Usage
Running `pybt` (or `pybt -h`) will display the usage instructions:
```
Welcome to pybt, an opinionated Python build tool (backed by pipenv)
Usage: pybt [-p|--project <arg>] [-d|--(no-)dev] [-r|--(no-)report] [-e|--(no-)errors] [--tests-selector <arg>] [--test-report <arg>] [--lint-config <arg>] [--lint-report <arg>] [-z|--package-name <arg>] [-t|--package-target <arg>] [-h|--help] <commands-1> [<commands-2>] ... [<commands-n>] ...
	<commands>: 
		clean: Remove the virtualenv
		init: Install the dependencies in the virtualenv
		test: Run the tests
		lint: Run the linter
		package: Package the source code and its dependencies into a zip file
	-p,--project: Project path (default is current path) (default: '.')
	-d,--dev,--no-dev: 'init' command should install development dependencies as well (default off) (off by default)
	-r,--report,--no-report: generate reports (applies only to 'test' and 'lint' commands, default off) (off by default)
	-e,--errors,--no-errors: lint errors only (default off) (off by default)
	--tests-selector: 'test' command will be applied using the provided tests-selector (no default)
	--test-report: test report file path (default test-report-xml) (default: 'test-report.xml')
	--lint-config: lint config file path (default .pylintrc) (default: '.pylintrc')
	--lint-report: lint report file path (default pylint.log) (default: 'pylint.log')
	-z,--package-name: package zip file name (defaults to project directory name) (no default)
	-t,--package-target: package target file path (default /tmp) (default: ''/tmp'')
	-h,--help: Prints help
```
For instance, run `pybt clean init -d test lint package` to install the dependencies, run the tests and the linter, and generate the package as a zip file.

**Important**: Only [pytest](https://github.com/pytest-dev/pytest/) and [pylint](https://github.com/PyCQA/pylint/) are supported as testing and linting libraries.

# License
[MIT License](LICENSE)
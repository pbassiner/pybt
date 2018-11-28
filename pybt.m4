#!/usr/bin/env bash
#
# ARG_POSITIONAL_INF([commands], ["$'\nclean: Remove the virtualenv\ninit: Install the dependencies in the virtualenv\ntest: Run the tests\nlint: Run the linter\npackage: Package the source code and its dependencies into a zip file'"], 1)
# ARG_OPTIONAL_SINGLE([project], [p], [Project path (default is current path)], ".")
# ARG_OPTIONAL_BOOLEAN([dev], [d], ['init' command should install development dependencies as well (default off)])
# ARG_OPTIONAL_BOOLEAN([report], [r], [generate reports (applies only to 'test' and 'lint' commands, default off)])
# ARG_OPTIONAL_BOOLEAN([errors], [e], [lint errors only (default off)])
# ARG_OPTIONAL_SINGLE([tests-selector], , ['test' command will be applied using the provided tests-selector])
# ARG_OPTIONAL_SINGLE([test-report], , [test report file path (default test-report-xml)], "test-report.xml")
# ARG_OPTIONAL_SINGLE([lint-config], , [lint config file path (default .pylintrc)], ".pylintrc")
# ARG_OPTIONAL_SINGLE([lint-report], , [lint report file path (default pylint.log)], "pylint.log")
# ARG_OPTIONAL_SINGLE([package-name], [z], [package zip file name (defaults to project directory name)])
# ARG_OPTIONAL_SINGLE([package-target], [t], [package target file path (default /tmp)], '/tmp')
# ARG_HELP([Welcome to pybt, an opinionated Python build tool (backed by pipenv)])
# ARGBASH_GO

# [ <-- needed because of Argbash

set -e

clean() {
	echo "Running clean command"
	pipenv --rm | true
}

init() {
	MSG="Running init command"
	ARGS=""

	DEV_DEPS=$1
	if [ "${DEV_DEPS}" == "on" ]; then
		MSG="$MSG including development dependencies"
		ARGS="$ARGS -d"
	fi

	echo "${MSG}"
	pipenv install ${ARGS}
}

test() {
	MSG="Running test command"
	ARGS=""

	TESTS_SELECTOR=$1
	if [ -n "${TESTS_SELECTOR}" ]; then
		MSG="$MSG with selector \"${TESTS_SELECTOR}\""
		ARGS="$ARGS -m \"${TESTS_SELECTOR}\""
	fi

	TEST_REPORT=$2
	if [ "${TEST_REPORT}" == "on" ]; then
		TEST_REPORT_PATH=$3
		if [ -n "${TEST_REPORT_PATH}" ]; then
			MSG="$MSG with reporting enabled (file: ${TEST_REPORT_PATH})"
			ARGS="$ARGS --junitxml=${TEST_REPORT_PATH}"
		fi
	fi

	echo "${MSG}"
	eval "pipenv run python -m pytest ${ARGS}"
}

lint() {
	MSG="Running lint command"
	ARGS=""

	ERRORS_ONLY=$1
	if [ "${ERRORS_ONLY}" == "on" ]; then
		MSG="$MSG checking for errors only"
		ARGS="$ARGS -E"
	fi

	LINT_CONFIG_PATH=$2
	if [ -n "${LINT_CONFIG_PATH}" ]; then
		MSG="$MSG (using lint config file: ${LINT_CONFIG_PATH})"
		ARGS="$ARGS --rcfile=${LINT_CONFIG_PATH}"
	fi

	LINT_REPORT=$3
	if [ "${LINT_REPORT}" == "on" ]; then
		LINT_REPORT_PATH=$4
		if [ -n "${LINT_REPORT_PATH}" ]; then
			MSG="$MSG with reporting enabled (file: ${LINT_REPORT_PATH})"
			ARGS="$ARGS -f parseable"
			OUTPUT="${LINT_REPORT_PATH}"
		fi
	else
		OUTPUT="/dev/null"
	fi

	echo "${MSG}"
	pipenv run python -m pylint ${ARGS} `find . -type f -name "*.py" | sort | tr '\n' ' '` |& tee ${OUTPUT}
}

package() {
	PACKAGE_NAME=$1
	if [ -n "${PACKAGE_NAME}" ]; then
		FILE_NAME="${PACKAGE_NAME}"
	else
		FILE_NAME="${PWD##*/}"
	fi

	PACKAGE_TARGET=$2
	if [ -n "${PACKAGE_TARGET}" ]; then
		TMP_PATH="${PACKAGE_TARGET}"
	fi

	echo "Packaging as ${FILE_NAME}"

	rm -f ${TMP_PATH}/${FILE_NAME}.zip

	zip -q -r ${TMP_PATH}/${FILE_NAME}.zip * --exclude '*/__pycache__/*' '*/.*' 'test/*' '*/test/*' 'tests/*' '*/tests/*'

	cd `pipenv run python -c 'import sys; print(sys.path[-1])'`
	zip -q -r ${TMP_PATH}/${FILE_NAME}.zip . --exclude '*/__pycache__/*'

	echo "Package ${FILE_NAME} zip file available at ${TMP_PATH}/${FILE_NAME}.zip"
}

PROJECT_DIR="${_arg_project}"
if [ ! -d "${PROJECT_DIR}" ]; then
	echo "Directory not found at ${PROJECT_DIR}"
	exit 1
fi

cd "${PROJECT_DIR}"
BASE_PATH=`pwd`
if [ ! -f "Pipfile" ]; then
	echo "Pipfile not found at ${BASE_PATH}/Pipfile"
	exit 1
fi

echo "Running commands for project at ${BASE_PATH}"

for command in "${_arg_commands[@]}"
do
	case "${command}" in
			clean)
	            clean
	            ;;

			init)
	            init "${_arg_dev}"
	            ;;

			test)
	            test "${_arg_tests_selector}" "${_arg_report}" "${_arg_test_report}"
	            ;;

	        lint)
	            lint "${_arg_errors}" "${_arg_lint_config}" "${_arg_report}" "${_arg_lint_report}"
	            ;;

	        package)
				package "${_arg_package_name}" "${_arg_package_target}"
				;;

	        *)
	            echo "Unrecognized command $command"
	            print_help
	            exit 1

	esac
done


# ] <-- needed because of Argbash

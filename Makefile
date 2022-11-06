# You can set this to 1 to see all commands that are being run
VERBOSE ?= 0

ifeq ($(VERBOSE),1)
export Q :=
export Q_CMAKE :=
export VERBOSE := 1
else
export Q := @
export Q_CMAKE := -- --quiet

export VERBOSE := 0
endif

###########################
# Generator Configuration #
###########################

BUILD_DIR ?= ./build/

# If already successfully configured as Ninja
ifneq ("$(wildcard $(BUILD_DIR)/build.ninja)","")
	CMAKE_GENERATOR = Ninja
# Or if successfully configured as Unix Makefiles
else ifneq ("$(wildcard $(BUILD_DIR)/Makefile)","")
	CMAKE_GENERATOR = Unix Makefiles
# Else if not yet configured
else
	# Ninja unless otherwise specified
	CMAKE_GENERATOR ?= Ninja
endif

export CMAKE_GENERATOR

ifeq ($(CMAKE_GENERATOR),Ninja)
	CONFIGURED_BUILD_DEP = $(BUILD_DIR)/build.ninja
else ifeq ($(CMAKE_GENERATOR),Unix Makefiles)
	CONFIGURED_BUILD_DEP = $(BUILD_DIR)/Makefile
endif


###########
# Options #
###########

OPTIONS ?=
INTERNAL_OPTIONS =

CPM_CACHE ?= $(HOME)/CPM_Cache
ifneq ($(CPM_CACHE),)
		INTERNAL_OPTIONS += -DCPM_SOURCE_CACHE=$(CPM_CACHE)
endif

LTO ?= 0
ifeq ($(LTO),1)
		INTERNAL_OPTIONS += -DENABLE_LTO=ON
endif

CROSS ?=
ifneq ($(CROSS),)
		INTERNAL_OPTIONS += -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/cross/$(CROSS).cmake
endif

NATIVE ?=
ifneq ($(NATIVE),)
		INTERNAL_OPTIONS += -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/native/$(NATIVE).cmake
endif

BUILD_TYPE ?=
ifneq ($(BUILD_TYPE),)
		INTERNAL_OPTIONS += -DCMAKE_BUILD_TYPE=$(BUILD_TYPE)
endif

SANITIZER ?=
ifneq ($(SANITIZER),)
		INTERNAL_OPTIONS += -DUSE_SANITIZER=$(SANITIZER)
endif

###########
# Targets #
###########

all: default

.PHONY: default
default: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) $(Q_CMAKE)

.PHONY: test
test: default
		$(Q) cd $(BUILD_DIR); ctest

.PHONY: test-clear-results
test-clear-results: default
		$(Q) cmake --build $(BUILD_DIR) --target test-clear-results $(Q_CMAKE)

.PHONY: docs
docs: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target docs $(Q_CMAKE)

.PHONY: package
package: default
		$(Q) cmake --build $(BUILD_DIR) --target package $(Q_CMAKE)
		$(Q) cmake --build $(BUILD_DIR) --target package_source $(Q_CMAKE)

.PHONY: cppcheck
cppcheck: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target cppcheck $(Q_CMAKE)

.PHONY: cppcheck-xml
cppcheck-xml: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target cppcheck-xml $(Q_CMAKE)

.PHONY: complexity
complexity: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target complexity $(Q_CMAKE)

.PHONY: complexity-xml
complexity-xml: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target complexity-xml $(Q_CMAKE)

.PHONY: complexity-full
complexity-full: | $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target complexity-full $(Q_CMAKE)

.PHONY: tidy
tidy: $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target tidy $(Q_CMAKE)

.PHONY: format
format: $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target format $(Q_CMAKE)

.PHONY: format-patch
format-patch: $(CONFIGURED_BUILD_DEP)
		$(Q) cmake --build $(BUILD_DIR) --target format-patch $(Q_CMAKE)

.PHONY: scan-build
scan-build:
		$(Q) scan-build cmake -B $(BUILD_DIR)/scan-build $(OPTIONS) $(INTERNAL_OPTIONS)
		$(Q) cmake --build $(BUILD_DIR)/scan-build $(Q_CMAKE)

.PHONY: coverage
coverage:
		$(Q) cmake -B $(BUILD_DIR)/coverage -DCMAKE_BUILD_TYPE=Debug -DENABLE_COVERAGE_ANALYSIS=ON $(OPTIONS) $(INTERNAL_OPTIONS)
		$(Q) cmake --build $(BUILD_DIR)/coverage $(Q_CMAKE)
		$(Q) cd $(BUILD_DIR)/coverage; ctest
		$(Q) cmake --build $(BUILD_DIR)/coverage --target coverage $(Q_CMAKE)

# Runs whenever the build has not been configured successfully
$(CONFIGURED_BUILD_DEP):
		$(Q) cmake -B $(BUILD_DIR) $(OPTIONS) $(INTERNAL_OPTIONS)

# Manually reconfigure a target, esp. with new options
.PHONY: reconfig
reconfig:
		$(Q) cmake -B $(BUILD_DIR) $(OPTIONS) $(INTERNAL_OPTIONS)

# Run clean command in build directory
.PHONY: clean
clean:
		$(Q) if [ -d "$(BUILD_DIR)" ]; then cmake --build $(BUILD_DIR) --target clean $(Q_CMAKE)

# Remove all build artifacts, including build directory
.PHONY: distclean
distclean:
		$(Q) rm -rf $(BUILD_DIR)

.PHONY: help
help:
		@echo "usage: make [OPTIONS] <target>"
		@echo "  Options:"
		@echo "    > VERBOSE Show verbose output for Make rules. Default 0. Enable with 1."
		@echo "    > BUILD_DIR Directory for build results, relative to proj root. Default build."
		@echo "    > OPTIONS Configuration options to pass to a build. Default empty."
		@echo "    > LTO Enable LTO builds. Default 0. Enable with 1."
		@echo "    > CROSS Enable a Cross-compilation build. "
		@echo "             Pass the cross-compilation toolchain name without a path or extension."
		@echo "             Example: make CROSS=cortex-m3"
		@echo "             For supported toolchains, see cmake/toolchains/cross/"
		@echo "    > CPM_CACHE Specify the path to the CPM source cache."
		@echo "             Set the variable to an empty value to disable the cache."
		@echo "    > BUILD_TYPE Specify the build type (default: RelWithDebInfo)"
		@echo "             Options: Debug Release MinSizeRel RelWithDebInfo"
		@echo "    > NATIVE Use an alternate toolchain on your build machine."
		@echo "             Pass the toolchain name without a path or extension."
		@echo "             Example: make NATIVE=gcc-9"
		@echo "             For supported toolchains, see cmake/toolchains/native/"
		@echo "    > SANITIZER Compile with support for a Clang/GCC Sanitizer.."
		@echo "             Options: none (default), address, thread, undefined,"
		@echo "             leak, and 'address;undefined' as a combined option"
		@echo "Targets:"
		@echo "  default: Builds all default targets build system knows about"
		@echo "  test: Build and run unit test program"
		@echo "  test-clear-results: Remove XML file generated by unit test program"
		@echo "  docs: Generate documentation"
		@echo "  package: Build the project, generate the docs, and create a release package"
		@echo "  clean: cleans build artifacts, keeping build files in place"
		@echo "  distclean: removes the configured build output directory"
		@echo "  reconfig: Reconfigure an existing build output folder with new settings"
		@echo "  Code Formatting Targets:"
		@echo "    format: runs clang-format on codebase"
		@echo "    format-patch: generates a patch file with formatting changes"
		@echo "  Static Analysis Targets:"
		@echo "    cppcheck: runs cppcheck"
		@echo "    cppcheck-xml: runs cppcheck and generates an XML report (for build servers)"
		@echo "    scan-build: runs clang static analysis"
		@echo "    complexity: runs complexity analysis with lizard, only prints violations"
		@echo "    complexity-full: runs complexity analysis with lizard, prints full report"
		@echo "    complexity-xml: runs complexity analysis with lizard, generates XML report"
		@echo "        (for build servers"
		@echo "    coverage: runs code coverage analysis and generates and HTML & XML reports"
		@echo "    tidy: runs clang-tidy linter"


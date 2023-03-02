NAME = rgx

CC = gcc
CFLAGS = $(WFLAGS) $(OPTIM) $(IFLAGS)
LFLAGS = -L$(LIB_DIR) -l$(NAME) -ltyrant

IFLAGS = -I$(INCLUDE_DIR)
WFLAGS = -Wall -Wextra -pedantic -std=c99

BUILD_DIR = build

OBJ_DIR = $(BUILD_DIR)/obj
LIB_DIR = $(BUILD_DIR)/lib
BIN_DIR = $(BUILD_DIR)/bin
INCLUDE_DIR = $(BUILD_DIR)/include
HEADER_DIR = $(INCLUDE_DIR)/$(NAME)

LIBRARIES = $(LIB_DIR)/lib$(NAME).a
BINARIES = $(BIN_DIR)/test

.PHONY: default
default: release

.PHONY: release
release: DEBUG= -DNDEBUG
release: OPTIM = -O3
release: deps-warning dirs headers $(LIBRARIES) $(BINARIES)

.PHONY: debug
debug: DEBUG = -fsanitize=address,undefined
debug: OPTIM = -g
debug: deps-warning dirs headers $(LIBRARY) $(BINARIES)

.PHONY: deps-warning
deps-warning:
	$(info ============================================================================)
	$(info Don't forget to build any dependencies that aren't installed on your system.)
	$(info ============================================================================)

# tests

$(BIN_DIR)/test: $(OBJ_DIR)/test.o $(LIB_DIR)/lib$(NAME).a
	$(CC) -o $@ $< $(LFLAGS) $(DEBUG) $(DEFINES)

$(OBJ_DIR)/test.o: tests/test.c
	$(CC) -c -o $@ $< $(CFLAGS) $(DEBUG) $(DEFINES)

# library

LIB_HEADERS = src/*.h
LIB_OBJS = $(OBJ_DIR)/$(NAME).o

$(LIB_DIR)/lib$(NAME).a: $(LIB_OBJS)
	ar crs $@ $^

$(OBJ_DIR)/$(NAME).o: src/$(NAME).c $(LIB_HEADERS)
	$(CC) -c -o $@ $< $(CFLAGS) $(DEBUG) $(DEFINES)

# headers

.PHONY: headers
headers: $(HEADER_DIR)

$(HEADER_DIR): $(LIB_HEADERS)
	mkdir -p $@
	cp -u $< $@/
	touch $@

# deps

.PHONY: deps
deps: tyrant

.PHONY: tyrant
tyrant:
	make -C tyrant BUILD_DIR=../build

# dirs

.PHONY: dirs
dirs: $(OBJ_DIR)/ $(LIB_DIR)/ $(BIN_DIR)/ $(INCLUDE_DIR)/

%/:
	mkdir -p $@

# clean

.PHONY: clean
clean:
	rm -rf build/*

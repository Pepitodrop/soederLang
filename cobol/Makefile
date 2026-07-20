COBC ?= cobc
COBFLAGS ?= -x -free -Wall
BIN_DIR := bin
SRC_DIR := src

.PHONY: all clean test

all: $(BIN_DIR)/soeder-core $(BIN_DIR)/soeder-api

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(BIN_DIR)/soeder-core: $(SRC_DIR)/soeder-core.cob | $(BIN_DIR)
	$(COBC) $(COBFLAGS) -o $@ $<

$(BIN_DIR)/soeder-api: $(SRC_DIR)/soeder-api.cob | $(BIN_DIR)
	$(COBC) $(COBFLAGS) -o $@ $<

test: all
	printf 'SAG 42.\nSTOPP.\n' | $(BIN_DIR)/soeder-core | grep -F '42'
	REQUEST_METHOD=GET PATH_INFO=/api/health $(BIN_DIR)/soeder-api | grep -F '"runtime":"GnuCOBOL"'
	printf '{"source":"SAG 42.\\nSTOPP.\\n"}\n' | REQUEST_METHOD=POST PATH_INFO=/api/execute $(BIN_DIR)/soeder-api | grep -F '"output":["42"]'

clean:
	rm -rf $(BIN_DIR)

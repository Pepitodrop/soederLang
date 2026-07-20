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
	printf '01 X ZAHL WERT 10.\nADDIERE 5 ZU X.\nSUBTRAHIERE 3 VON X.\nMULTIPLIZIERE 2 MIT X.\nDIVIDIERE 4 DURCH X.\nSAG X.\nSTOPP.\n' | $(BIN_DIR)/soeder-core | grep -F '6'
	printf '01 X ZAHL WERT 0.\nLOOP:\nADDIERE 1 ZU X.\nWENN X KLEINER 5 SPRINGE ZU LOOP.\nSAG X.\nSTOPP.\n' | $(BIN_DIR)/soeder-core | grep -F '5'
	printf '01 X ZAHL WERT 1.\nFUNKTION DOPPEL.\nMULTIPLIZIERE 2 MIT X.\nZURUECK.\nHAUPTPROGRAMM.\nRUF DOPPEL AUF.\nRUF DOPPEL AUF.\nSAG X.\nSTOPP.\n' | $(BIN_DIR)/soeder-core | grep -F '4'
	printf '01 X ZAHL WERT 0.\nFUNKTION REKURSIV.\nADDIERE 1 ZU X.\nWENN X KLEINER 5 SPRINGE ZU AGAIN.\nZURUECK.\nAGAIN:\nRUF REKURSIV AUF.\nZURUECK.\nHAUPTPROGRAMM.\nRUF REKURSIV AUF.\nSAG X.\nSTOPP.\n' | $(BIN_DIR)/soeder-core | grep -F '5'
	printf '01 PTR ZAHL WERT 0.\n01 OUT ZAHL WERT 0.\nRESERVIERE 3 IN PTR.\nSCHREIBE 77 NACH SPEICHER PTR.\nLIES SPEICHER PTR IN OUT.\nSAG OUT.\nSTOPP.\n' | $(BIN_DIR)/soeder-core | grep -F '77'
	! printf '01 PTR ZAHL WERT 0.\n01 OUT ZAHL WERT 0.\nLIES SPEICHER 1 IN OUT.\n' | $(BIN_DIR)/soeder-core >/dev/null 2>&1
	! printf 'RUF FEHLT AUF.\n' | $(BIN_DIR)/soeder-core >/dev/null 2>&1
	! printf '01 X ZAHL WERT 5.\nDIVIDIERE 0 DURCH X.\n' | $(BIN_DIR)/soeder-core >/dev/null 2>&1
	REQUEST_METHOD=GET PATH_INFO=/api/health $(BIN_DIR)/soeder-api | grep -F '"runtime":"GnuCOBOL"'
	printf '{"source":"SAG 42.\\nSTOPP.\\n"}\n' | REQUEST_METHOD=POST PATH_INFO=/api/execute $(BIN_DIR)/soeder-api | grep -F '"output":["42"]'

clean:
	rm -rf $(BIN_DIR)

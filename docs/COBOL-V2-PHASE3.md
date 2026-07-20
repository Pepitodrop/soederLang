# COBOL v2 Phase 3

The GnuCOBOL runtime now supports program-level functions and checked numeric heap memory.

## Functions

```text
FUNKTION NAME.
  ...
  ZURUECK.

HAUPTPROGRAMM.
  RUF NAME AUF.
```

Calls use a bounded return stack with a maximum depth of 100. Nested calls and recursion are supported. Unknown functions, stack overflow, and `ZURUECK` outside a call are runtime errors.

## Heap

```text
RESERVIERE size IN ADDRESS.
SCHREIBE value NACH SPEICHER address.
LIES SPEICHER address IN TARGET.
```

The heap contains 10,000 signed integer cells. Allocation returns a one-based base address. Allocation size, address range, target type, and the global heap limit are validated before access.

The browser remains a presentation client; language execution remains owned by GnuCOBOL.

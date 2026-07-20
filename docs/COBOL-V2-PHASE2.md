# COBOL v2 Phase 2 — control flow

The GnuCOBOL runtime now buffers source lines before execution, indexes labels, and executes through an instruction pointer.

Supported control-flow syntax:

```text
LABEL:
SPRINGE ZU LABEL.
WENN VARIABLE GLEICH value SPRINGE ZU LABEL.
WENN VARIABLE UNGLEICH value SPRINGE ZU LABEL.
WENN VARIABLE KLEINER value SPRINGE ZU LABEL.
WENN VARIABLE GROESSER value SPRINGE ZU LABEL.
```

`GLEICH` and `UNGLEICH` support values of the same type. `KLEINER` and `GROESSER` require numeric values. Unknown and duplicate labels are errors. The runtime enforces a 100,000-instruction limit to stop accidental infinite loops.

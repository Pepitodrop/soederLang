# Turing completeness of SöderLang

SöderLang's core execution model can simulate a deterministic two-counter Minsky machine. Two-counter machines are computationally universal, so this construction establishes practical Turing completeness subject to the finite resources of the host computer.

## Required primitives

The language provides:

1. Arbitrarily repeatable labelled control flow through `LABEL:`, `SPRINGE ZU LABEL.`, and conditional jumps.
2. Integer variables through `ZAHL` declarations.
3. Counter increment through `ADDIERE 1 ZU COUNTER.`.
4. Counter decrement through `SUBTRAHIERE 1 VON COUNTER.`.
5. Zero testing through `WENN COUNTER GLEICH 0 SPRINGE ZU ZERO-BRANCH.`.
6. Unbounded execution in the abstract machine. The implementation uses a configurable instruction limit to protect real processes.

## Instruction translation

A Minsky-machine increment instruction

```text
INC C1; GOTO L2
```

is represented as:

```text
L1:
  ADDIERE 1 ZU C1.
  SPRINGE ZU L2.
```

A conditional decrement instruction

```text
IF C1 = 0 GOTO LZERO ELSE DEC C1; GOTO LNONZERO
```

is represented as:

```text
L1:
  WENN C1 GLEICH 0 SPRINGE ZU LZERO.
  SUBTRAHIERE 1 VON C1.
  SPRINGE ZU LNONZERO.
```

A halt instruction is represented by `STOPP.`.

Because every instruction of a two-counter Minsky machine has a direct finite translation, every computation expressible by that universal machine can be expressed in SöderLang.

## Heap and functions

The `RESERVIERE`, `SCHREIBE ... NACH SPEICHER`, and `LIES SPEICHER ... IN` instructions provide indexed mutable storage. `FUNKTION`, `RUF ... AUF`, and `ZURUECK` add call frames and recursion. These facilities are not required for the two-counter proof, but make general-purpose programs substantially easier to express.

## Practical qualification

No physical implementation has literally infinite time or memory. SöderLang therefore enforces configurable `maxSteps` and `maxHeap` limits. Removing or raising those limits changes resource availability, not the expressiveness of the language model.

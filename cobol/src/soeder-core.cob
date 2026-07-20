       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOEDER-CORE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SOURCE-STREAM ASSIGN TO KEYBOARD
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD SOURCE-STREAM.
       01 SOURCE-LINE                    PIC X(4096).

       WORKING-STORAGE SECTION.
       01 WS-EOF                         PIC X VALUE "N".
       01 WS-HALTED                      PIC X VALUE "N".
       01 WS-LINE-COUNT                  PIC 9(4) COMP VALUE ZERO.
       01 WS-IP                          PIC 9(4) COMP VALUE 1.
       01 WS-NEXT-IP                     PIC 9(4) COMP VALUE 1.
       01 WS-MAIN-IP                     PIC 9(4) COMP VALUE 1.
       01 WS-INSTRUCTION-COUNT           PIC 9(7) COMP VALUE ZERO.
       01 WS-INSTRUCTION-LIMIT           PIC 9(7) COMP VALUE 100000.
       01 WS-LINE                        PIC X(4096) VALUE SPACES.
       01 WS-LENGTH                      PIC 9(5) COMP VALUE ZERO.
       01 WS-T1                          PIC X(256) VALUE SPACES.
       01 WS-T2                          PIC X(256) VALUE SPACES.
       01 WS-T3                          PIC X(256) VALUE SPACES.
       01 WS-T4                          PIC X(256) VALUE SPACES.
       01 WS-T5                          PIC X(256) VALUE SPACES.
       01 WS-T6                          PIC X(256) VALUE SPACES.
       01 WS-T7                          PIC X(256) VALUE SPACES.
       01 WS-OPERATION                   PIC X(12) VALUE SPACES.
       01 WS-NAME                        PIC X(64) VALUE SPACES.
       01 WS-LABEL-NAME                  PIC X(64) VALUE SPACES.
       01 WS-FUNCTION-NAME               PIC X(64) VALUE SPACES.
       01 WS-VALUE-TOKEN                 PIC X(2048) VALUE SPACES.
       01 WS-VALUE-TYPE                  PIC X VALUE SPACE.
       01 WS-NUMBER                      PIC S9(18) VALUE ZERO.
       01 WS-TEXT                        PIC X(2048) VALUE SPACES.
       01 WS-TARGET-INDEX                PIC 9(4) COMP VALUE ZERO.
       01 WS-I                           PIC 9(4) COMP VALUE ZERO.
       01 WS-FOUND                       PIC X VALUE "N".
       01 WS-CONDITION                   PIC X VALUE "N".
       01 WS-LEFT-TYPE                   PIC X VALUE SPACE.
       01 WS-LEFT-NUMBER                 PIC S9(18) VALUE ZERO.
       01 WS-LEFT-TEXT                   PIC X(2048) VALUE SPACES.
       01 WS-ERROR                       PIC X(1024) VALUE SPACES.
       01 WS-DISPLAY-NUMBER              PIC -9(18) VALUE ZERO.
       01 WS-CALL-DEPTH                  PIC 9(3) COMP VALUE ZERO.
       01 WS-CALL-LIMIT                  PIC 9(3) COMP VALUE 100.
       01 WS-HEAP-NEXT                   PIC 9(5) COMP VALUE 1.
       01 WS-HEAP-LIMIT                  PIC 9(5) COMP VALUE 10000.
       01 WS-ADDRESS                     PIC 9(5) COMP VALUE ZERO.
       01 WS-SIZE                        PIC 9(5) COMP VALUE ZERO.
       01 WS-HEAP-END                    PIC 9(5) COMP VALUE ZERO.

       01 SOURCE-TABLE.
          05 SOURCE-ENTRY OCCURS 1000 TIMES.
             10 STORED-LINE              PIC X(4096) VALUE SPACES.

       01 LABEL-TABLE.
          05 LABEL-ENTRY OCCURS 250 TIMES.
             10 LABEL-USED               PIC X VALUE "N".
             10 LABEL-NAME               PIC X(64) VALUE SPACES.
             10 LABEL-IP                 PIC 9(4) COMP VALUE ZERO.

       01 FUNCTION-TABLE.
          05 FUNCTION-ENTRY OCCURS 100 TIMES.
             10 FUNCTION-USED            PIC X VALUE "N".
             10 FUNCTION-NAME            PIC X(64) VALUE SPACES.
             10 FUNCTION-IP              PIC 9(4) COMP VALUE ZERO.

       01 CALL-STACK.
          05 RETURN-IP OCCURS 100 TIMES  PIC 9(4) COMP VALUE ZERO.

       01 VARIABLE-TABLE.
          05 VAR-ENTRY OCCURS 100 TIMES.
             10 VAR-USED                 PIC X VALUE "N".
             10 VAR-NAME                 PIC X(64) VALUE SPACES.
             10 VAR-TYPE                 PIC X VALUE SPACE.
             10 VAR-NUMBER               PIC S9(18) VALUE ZERO.
             10 VAR-TEXT                 PIC X(2048) VALUE SPACES.

       01 HEAP-TABLE.
          05 HEAP-CELL OCCURS 10000 TIMES PIC S9(18) VALUE ZERO.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM LOAD-SOURCE
           IF WS-HALTED NOT = "Y"
               PERFORM INDEX-PROGRAM
           END-IF
           IF WS-HALTED NOT = "Y"
               PERFORM EXECUTE-PROGRAM
           END-IF
           GOBACK.

       LOAD-SOURCE.
           OPEN INPUT SOURCE-STREAM
           PERFORM UNTIL WS-EOF = "Y"
               READ SOURCE-STREAM
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       IF WS-LINE-COUNT >= 1000
                           MOVE "Programm enthaelt zu viele Zeilen" TO WS-ERROR
                           PERFORM FAIL-WITH-ERROR
                           MOVE "Y" TO WS-EOF
                       ELSE
                           ADD 1 TO WS-LINE-COUNT
                           MOVE FUNCTION TRIM(SOURCE-LINE)
                               TO STORED-LINE(WS-LINE-COUNT)
                       END-IF
               END-READ
           END-PERFORM
           CLOSE SOURCE-STREAM.

       INDEX-PROGRAM.
           MOVE 1 TO WS-MAIN-IP
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-LINE-COUNT OR WS-HALTED = "Y"
               MOVE FUNCTION TRIM(STORED-LINE(WS-I)) TO WS-LINE
               MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LENGTH
               IF WS-LENGTH > ZERO
                   IF WS-LINE(WS-LENGTH:1) = ":"
                       MOVE SPACE TO WS-LINE(WS-LENGTH:1)
                       MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-LINE))
                           TO WS-LABEL-NAME
                       PERFORM ADD-LABEL
                   ELSE
                       PERFORM INDEX-SPECIAL-LINE
                   END-IF
               END-IF
           END-PERFORM.

       INDEX-SPECIAL-LINE.
           MOVE SPACES TO WS-T1 WS-T2
           UNSTRING WS-LINE DELIMITED BY ALL SPACES INTO WS-T1 WS-T2
           END-UNSTRING
           MOVE FUNCTION UPPER-CASE(WS-T1) TO WS-T1
           IF FUNCTION TRIM(WS-T1) = "FUNKTION"
               MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2))
                   TO WS-FUNCTION-NAME
               PERFORM STRIP-TRAILING-PERIOD-FUNCTION
               PERFORM ADD-FUNCTION
           END-IF
           IF FUNCTION TRIM(WS-T1) = "HAUPTPROGRAMM"
               COMPUTE WS-MAIN-IP = WS-I + 1
           END-IF.

       STRIP-TRAILING-PERIOD-FUNCTION.
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FUNCTION-NAME)) TO WS-LENGTH
           IF WS-LENGTH > ZERO
               IF WS-FUNCTION-NAME(WS-LENGTH:1) = "."
                   MOVE SPACE TO WS-FUNCTION-NAME(WS-LENGTH:1)
               END-IF
           END-IF.

       ADD-LABEL.
           PERFORM FIND-LABEL
           IF WS-FOUND = "Y"
               MOVE "Doppeltes Label" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM VARYING WS-TARGET-INDEX FROM 1 BY 1
               UNTIL WS-TARGET-INDEX > 250
               IF LABEL-USED(WS-TARGET-INDEX) NOT = "Y"
                   MOVE "Y" TO LABEL-USED(WS-TARGET-INDEX)
                   MOVE WS-LABEL-NAME TO LABEL-NAME(WS-TARGET-INDEX)
                   MOVE WS-I TO LABEL-IP(WS-TARGET-INDEX)
                   MOVE "Y" TO WS-FOUND
                   EXIT PERFORM
               END-IF
           END-PERFORM
           IF WS-FOUND NOT = "Y"
               MOVE "Labelspeicher ist voll" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
           END-IF.

       ADD-FUNCTION.
           PERFORM FIND-FUNCTION
           IF WS-FOUND = "Y"
               MOVE "Doppelte Funktion" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM VARYING WS-TARGET-INDEX FROM 1 BY 1
               UNTIL WS-TARGET-INDEX > 100
               IF FUNCTION-USED(WS-TARGET-INDEX) NOT = "Y"
                   MOVE "Y" TO FUNCTION-USED(WS-TARGET-INDEX)
                   MOVE WS-FUNCTION-NAME TO FUNCTION-NAME(WS-TARGET-INDEX)
                   COMPUTE FUNCTION-IP(WS-TARGET-INDEX) = WS-I + 1
                   MOVE "Y" TO WS-FOUND
                   EXIT PERFORM
               END-IF
           END-PERFORM
           IF WS-FOUND NOT = "Y"
               MOVE "Funktionsspeicher ist voll" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
           END-IF.

       EXECUTE-PROGRAM.
           MOVE WS-MAIN-IP TO WS-IP
           PERFORM UNTIL WS-HALTED = "Y" OR WS-IP > WS-LINE-COUNT
               ADD 1 TO WS-INSTRUCTION-COUNT
               IF WS-INSTRUCTION-COUNT > WS-INSTRUCTION-LIMIT
                   MOVE "Anweisungslimit ueberschritten" TO WS-ERROR
                   PERFORM FAIL-WITH-ERROR
               ELSE
                   COMPUTE WS-NEXT-IP = WS-IP + 1
                   MOVE FUNCTION TRIM(STORED-LINE(WS-IP)) TO WS-LINE
                   IF WS-LINE NOT = SPACES
                       PERFORM PROCESS-LINE
                   END-IF
                   MOVE WS-NEXT-IP TO WS-IP
               END-IF
           END-PERFORM.

       PROCESS-LINE.
           IF WS-LINE(1:2) = "*>"
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LENGTH
           IF WS-LENGTH = ZERO
               EXIT PARAGRAPH
           END-IF
           IF WS-LINE(WS-LENGTH:1) = ":"
               EXIT PARAGRAPH
           END-IF
           IF WS-LINE(WS-LENGTH:1) = "."
               MOVE SPACE TO WS-LINE(WS-LENGTH:1)
           END-IF
           MOVE SPACES TO WS-T1 WS-T2 WS-T3 WS-T4 WS-T5 WS-T6 WS-T7
           UNSTRING WS-LINE DELIMITED BY ALL SPACES
               INTO WS-T1 WS-T2 WS-T3 WS-T4 WS-T5 WS-T6 WS-T7
           END-UNSTRING
           MOVE FUNCTION UPPER-CASE(WS-T1) TO WS-T1
           MOVE FUNCTION UPPER-CASE(WS-T2) TO WS-T2
           MOVE FUNCTION UPPER-CASE(WS-T3) TO WS-T3
           MOVE FUNCTION UPPER-CASE(WS-T4) TO WS-T4
           MOVE FUNCTION UPPER-CASE(WS-T5) TO WS-T5
           MOVE FUNCTION UPPER-CASE(WS-T6) TO WS-T6

           IF FUNCTION TRIM(WS-T1) = "IDENTIFICATION"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "PROGRAM-ID"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "DATA"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "WORKING-STORAGE"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "PROCEDURE"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "BAYERN"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "HAUPTPROGRAMM"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "FUNKTION"
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "01"
               PERFORM DECLARE-VARIABLE
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "SETZE"
               PERFORM ASSIGN-VARIABLE
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "ADDIERE"
               MOVE "ADD" TO WS-OPERATION
               PERFORM ARITHMETIC-VARIABLE
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "SUBTRAHIERE"
               MOVE "SUB" TO WS-OPERATION
               PERFORM ARITHMETIC-VARIABLE
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "MULTIPLIZIERE"
               MOVE "MUL" TO WS-OPERATION
               PERFORM ARITHMETIC-VARIABLE
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "DIVIDIERE"
               MOVE "DIV" TO WS-OPERATION
               PERFORM ARITHMETIC-VARIABLE
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "SAG"
               MOVE WS-T2 TO WS-VALUE-TOKEN
               PERFORM RESOLVE-VALUE
               IF WS-HALTED NOT = "Y"
                   PERFORM DISPLAY-VALUE
               END-IF
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "SPRINGE"
               PERFORM UNCONDITIONAL-JUMP
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "WENN"
               PERFORM CONDITIONAL-JUMP
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "RUF"
               PERFORM CALL-FUNCTION
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "ZURUECK"
               PERFORM RETURN-FROM-FUNCTION
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "RESERVIERE"
               PERFORM ALLOCATE-HEAP
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "SCHREIBE"
               PERFORM WRITE-HEAP
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "LIES"
               PERFORM READ-HEAP
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "STOPP"
               MOVE "Y" TO WS-HALTED
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T1) = "HANDY"
               MOVE "Y" TO WS-HALTED
               EXIT PARAGRAPH
           END-IF
           PERFORM SYNTAX-ERROR.

       CALL-FUNCTION.
           IF FUNCTION TRIM(WS-T3) NOT = "AUF"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2))
               TO WS-FUNCTION-NAME
           PERFORM FIND-FUNCTION
           IF WS-FOUND NOT = "Y"
               MOVE "Unbekannte Funktion" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           IF WS-CALL-DEPTH >= WS-CALL-LIMIT
               MOVE "Aufrufstapel-Limit ueberschritten" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           ADD 1 TO WS-CALL-DEPTH
           COMPUTE RETURN-IP(WS-CALL-DEPTH) = WS-IP + 1
           MOVE FUNCTION-IP(WS-TARGET-INDEX) TO WS-NEXT-IP.

       RETURN-FROM-FUNCTION.
           IF WS-CALL-DEPTH = ZERO
               MOVE "ZURUECK ohne aktiven Funktionsaufruf" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE RETURN-IP(WS-CALL-DEPTH) TO WS-NEXT-IP
           SUBTRACT 1 FROM WS-CALL-DEPTH.

       ALLOCATE-HEAP.
           IF FUNCTION TRIM(WS-T3) NOT = "IN"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T2 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF WS-HALTED = "Y"
               EXIT PARAGRAPH
           END-IF
           IF WS-VALUE-TYPE NOT = "N" OR WS-NUMBER <= ZERO
               MOVE "Ungueltige Speichergroesse" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-NUMBER TO WS-SIZE
           COMPUTE WS-HEAP-END = WS-HEAP-NEXT + WS-SIZE - 1
           IF WS-HEAP-END > WS-HEAP-LIMIT
               MOVE "Heap-Limit ueberschritten" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T4)) TO WS-NAME
           PERFORM FIND-VARIABLE
           IF WS-FOUND NOT = "Y"
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF VAR-TYPE(WS-TARGET-INDEX) NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-HEAP-NEXT TO VAR-NUMBER(WS-TARGET-INDEX)
           COMPUTE WS-HEAP-NEXT = WS-HEAP-END + 1.

       WRITE-HEAP.
           IF FUNCTION TRIM(WS-T3) NOT = "NACH"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T4) NOT = "SPEICHER"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T2 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF WS-HALTED = "Y"
               EXIT PARAGRAPH
           END-IF
           IF WS-VALUE-TYPE NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-NUMBER TO WS-LEFT-NUMBER
           MOVE WS-T5 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-ADDRESS
           IF WS-HALTED = "Y"
               EXIT PARAGRAPH
           END-IF
           MOVE WS-LEFT-NUMBER TO HEAP-CELL(WS-ADDRESS).

       READ-HEAP.
           IF FUNCTION TRIM(WS-T2) NOT = "SPEICHER"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T4) NOT = "IN"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T3 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-ADDRESS
           IF WS-HALTED = "Y"
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T5)) TO WS-NAME
           PERFORM FIND-VARIABLE
           IF WS-FOUND NOT = "Y"
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF VAR-TYPE(WS-TARGET-INDEX) NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE HEAP-CELL(WS-ADDRESS) TO VAR-NUMBER(WS-TARGET-INDEX).

       RESOLVE-ADDRESS.
           PERFORM RESOLVE-VALUE
           IF WS-HALTED = "Y"
               EXIT PARAGRAPH
           END-IF
           IF WS-VALUE-TYPE NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF WS-NUMBER < 1 OR WS-NUMBER >= WS-HEAP-NEXT
               MOVE "Ungueltige Heap-Adresse" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-NUMBER TO WS-ADDRESS.

       UNCONDITIONAL-JUMP.
           IF FUNCTION TRIM(WS-T2) NOT = "ZU"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T3)) TO WS-LABEL-NAME
           PERFORM JUMP-TO-LABEL.

       CONDITIONAL-JUMP.
           IF FUNCTION TRIM(WS-T5) NOT = "SPRINGE" OR
              FUNCTION TRIM(WS-T6) NOT = "ZU"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2)) TO WS-NAME
           PERFORM FIND-VARIABLE
           IF WS-FOUND NOT = "Y"
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE VAR-TYPE(WS-TARGET-INDEX) TO WS-LEFT-TYPE
           MOVE VAR-NUMBER(WS-TARGET-INDEX) TO WS-LEFT-NUMBER
           MOVE VAR-TEXT(WS-TARGET-INDEX) TO WS-LEFT-TEXT
           MOVE WS-T4 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF WS-HALTED = "Y"
               EXIT PARAGRAPH
           END-IF
           IF WS-LEFT-TYPE NOT = WS-VALUE-TYPE
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE "N" TO WS-CONDITION
           IF FUNCTION TRIM(WS-T3) = "GLEICH"
               IF WS-VALUE-TYPE = "N"
                   IF WS-LEFT-NUMBER = WS-NUMBER MOVE "Y" TO WS-CONDITION END-IF
               ELSE
                   IF FUNCTION TRIM(WS-LEFT-TEXT) = FUNCTION TRIM(WS-TEXT)
                       MOVE "Y" TO WS-CONDITION
                   END-IF
               END-IF
           ELSE
               IF FUNCTION TRIM(WS-T3) = "UNGLEICH"
                   IF WS-VALUE-TYPE = "N"
                       IF WS-LEFT-NUMBER NOT = WS-NUMBER MOVE "Y" TO WS-CONDITION END-IF
                   ELSE
                       IF FUNCTION TRIM(WS-LEFT-TEXT) NOT = FUNCTION TRIM(WS-TEXT)
                           MOVE "Y" TO WS-CONDITION
                       END-IF
                   END-IF
               ELSE
                   IF WS-VALUE-TYPE NOT = "N"
                       PERFORM TYPE-ERROR
                       EXIT PARAGRAPH
                   END-IF
                   IF FUNCTION TRIM(WS-T3) = "KLEINER"
                       IF WS-LEFT-NUMBER < WS-NUMBER MOVE "Y" TO WS-CONDITION END-IF
                   ELSE
                       IF FUNCTION TRIM(WS-T3) = "GROESSER"
                           IF WS-LEFT-NUMBER > WS-NUMBER MOVE "Y" TO WS-CONDITION END-IF
                       ELSE
                           PERFORM SYNTAX-ERROR
                           EXIT PARAGRAPH
                       END-IF
                   END-IF
               END-IF
           END-IF
           IF WS-CONDITION = "Y"
               MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T7)) TO WS-LABEL-NAME
               PERFORM JUMP-TO-LABEL
           END-IF.

       JUMP-TO-LABEL.
           PERFORM FIND-LABEL
           IF WS-FOUND NOT = "Y"
               MOVE "Unbekanntes Label" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
           ELSE
               MOVE LABEL-IP(WS-TARGET-INDEX) TO WS-NEXT-IP
           END-IF.

       DECLARE-VARIABLE.
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2)) TO WS-NAME
           IF FUNCTION TRIM(WS-T4) NOT = "WERT"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM FIND-OR-CREATE-VARIABLE
           IF WS-HALTED = "Y" EXIT PARAGRAPH END-IF
           IF FUNCTION TRIM(WS-T3) = "ZAHL"
               MOVE WS-T5 TO WS-VALUE-TOKEN
               PERFORM RESOLVE-NUMERIC-LITERAL
               IF WS-HALTED NOT = "Y"
                   MOVE "N" TO VAR-TYPE(WS-TARGET-INDEX)
                   MOVE WS-NUMBER TO VAR-NUMBER(WS-TARGET-INDEX)
               END-IF
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T3) = "TEXT"
               MOVE "T" TO VAR-TYPE(WS-TARGET-INDEX)
               MOVE FUNCTION TRIM(WS-T5) TO WS-TEXT
               PERFORM STRIP-QUOTES
               MOVE WS-TEXT TO VAR-TEXT(WS-TARGET-INDEX)
               EXIT PARAGRAPH
           END-IF
           PERFORM SYNTAX-ERROR.

       ASSIGN-VARIABLE.
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2)) TO WS-NAME
           IF FUNCTION TRIM(WS-T3) NOT = "AUF"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM FIND-VARIABLE
           IF WS-FOUND NOT = "Y"
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T4 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF WS-HALTED = "Y" EXIT PARAGRAPH END-IF
           IF VAR-TYPE(WS-TARGET-INDEX) NOT = WS-VALUE-TYPE
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF WS-VALUE-TYPE = "N"
               MOVE WS-NUMBER TO VAR-NUMBER(WS-TARGET-INDEX)
           ELSE
               MOVE WS-TEXT TO VAR-TEXT(WS-TARGET-INDEX)
           END-IF.

       ARITHMETIC-VARIABLE.
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T4)) TO WS-NAME
           PERFORM FIND-VARIABLE
           IF WS-FOUND NOT = "Y"
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF VAR-TYPE(WS-TARGET-INDEX) NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T2 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF WS-HALTED = "Y" EXIT PARAGRAPH END-IF
           IF WS-VALUE-TYPE NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF WS-OPERATION = "ADD"
               ADD WS-NUMBER TO VAR-NUMBER(WS-TARGET-INDEX)
           ELSE IF WS-OPERATION = "SUB"
               SUBTRACT WS-NUMBER FROM VAR-NUMBER(WS-TARGET-INDEX)
           ELSE IF WS-OPERATION = "MUL"
               MULTIPLY WS-NUMBER BY VAR-NUMBER(WS-TARGET-INDEX)
           ELSE IF WS-OPERATION = "DIV"
               IF WS-NUMBER = ZERO
                   PERFORM DIVISION-ZERO-ERROR
               ELSE
                   DIVIDE WS-NUMBER INTO VAR-NUMBER(WS-TARGET-INDEX)
               END-IF
           END-IF END-IF END-IF END-IF.

       RESOLVE-VALUE.
           MOVE SPACES TO WS-TEXT
           MOVE ZERO TO WS-NUMBER
           MOVE FUNCTION TRIM(WS-VALUE-TOKEN) TO WS-VALUE-TOKEN
           IF WS-VALUE-TOKEN(1:1) = '"'
               MOVE "T" TO WS-VALUE-TYPE
               MOVE WS-VALUE-TOKEN TO WS-TEXT
               PERFORM STRIP-QUOTES
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-VALUE-TOKEN)) TO WS-NAME
           PERFORM FIND-VARIABLE
           IF WS-FOUND = "Y"
               MOVE VAR-TYPE(WS-TARGET-INDEX) TO WS-VALUE-TYPE
               IF WS-VALUE-TYPE = "N"
                   MOVE VAR-NUMBER(WS-TARGET-INDEX) TO WS-NUMBER
               ELSE
                   MOVE VAR-TEXT(WS-TARGET-INDEX) TO WS-TEXT
               END-IF
               EXIT PARAGRAPH
           END-IF
           PERFORM RESOLVE-NUMERIC-LITERAL.

       RESOLVE-NUMERIC-LITERAL.
           IF FUNCTION TEST-NUMVAL(FUNCTION TRIM(WS-VALUE-TOKEN)) NOT = 0
               PERFORM INVALID-VALUE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE "N" TO WS-VALUE-TYPE
           COMPUTE WS-NUMBER = FUNCTION NUMVAL(FUNCTION TRIM(WS-VALUE-TOKEN)).

       DISPLAY-VALUE.
           IF WS-VALUE-TYPE = "N"
               MOVE WS-NUMBER TO WS-DISPLAY-NUMBER
               DISPLAY FUNCTION TRIM(WS-DISPLAY-NUMBER)
           ELSE
               DISPLAY FUNCTION TRIM(WS-TEXT)
           END-IF.

       FIND-VARIABLE.
           MOVE "N" TO WS-FOUND
           MOVE ZERO TO WS-TARGET-INDEX
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
               IF VAR-USED(WS-I) = "Y"
                   IF FUNCTION TRIM(VAR-NAME(WS-I)) = FUNCTION TRIM(WS-NAME)
                       MOVE WS-I TO WS-TARGET-INDEX
                       MOVE "Y" TO WS-FOUND
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM.

       FIND-OR-CREATE-VARIABLE.
           PERFORM FIND-VARIABLE
           IF WS-FOUND = "Y" EXIT PARAGRAPH END-IF
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
               IF VAR-USED(WS-I) NOT = "Y"
                   MOVE "Y" TO VAR-USED(WS-I)
                   MOVE WS-NAME TO VAR-NAME(WS-I)
                   MOVE WS-I TO WS-TARGET-INDEX
                   MOVE "Y" TO WS-FOUND
                   EXIT PERFORM
               END-IF
           END-PERFORM
           IF WS-FOUND NOT = "Y"
               MOVE "Variablenspeicher ist voll" TO WS-ERROR
               PERFORM FAIL-WITH-ERROR
           END-IF.

       FIND-LABEL.
           MOVE "N" TO WS-FOUND
           MOVE ZERO TO WS-TARGET-INDEX
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 250
               IF LABEL-USED(WS-I) = "Y"
                   IF FUNCTION TRIM(LABEL-NAME(WS-I)) = FUNCTION TRIM(WS-LABEL-NAME)
                       MOVE WS-I TO WS-TARGET-INDEX
                       MOVE "Y" TO WS-FOUND
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM.

       FIND-FUNCTION.
           MOVE "N" TO WS-FOUND
           MOVE ZERO TO WS-TARGET-INDEX
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
               IF FUNCTION-USED(WS-I) = "Y"
                   IF FUNCTION TRIM(FUNCTION-NAME(WS-I)) = FUNCTION TRIM(WS-FUNCTION-NAME)
                       MOVE WS-I TO WS-TARGET-INDEX
                       MOVE "Y" TO WS-FOUND
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM.

       STRIP-QUOTES.
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LENGTH
           IF WS-LENGTH >= 2
               IF WS-TEXT(1:1) = '"' AND WS-TEXT(WS-LENGTH:1) = '"'
                   MOVE SPACE TO WS-TEXT(1:1)
                   MOVE SPACE TO WS-TEXT(WS-LENGTH:1)
                   MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT
               END-IF
           END-IF.

       SYNTAX-ERROR.
           MOVE "Syntaxfehler" TO WS-ERROR
           PERFORM FAIL-WITH-ERROR.
       UNKNOWN-VARIABLE-ERROR.
           MOVE "Unbekannte Variable" TO WS-ERROR
           PERFORM FAIL-WITH-ERROR.
       INVALID-VALUE-ERROR.
           MOVE "Ungueltiger Wert" TO WS-ERROR
           PERFORM FAIL-WITH-ERROR.
       TYPE-ERROR.
           MOVE "Typfehler" TO WS-ERROR
           PERFORM FAIL-WITH-ERROR.
       DIVISION-ZERO-ERROR.
           MOVE "Division durch Null" TO WS-ERROR
           PERFORM FAIL-WITH-ERROR.
       FAIL-WITH-ERROR.
           DISPLAY FUNCTION TRIM(WS-ERROR) UPON STDERR
           MOVE 2 TO RETURN-CODE
           MOVE "Y" TO WS-HALTED.

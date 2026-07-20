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
       01 SOURCE-LINE                 PIC X(4096).

       WORKING-STORAGE SECTION.
       01 WS-EOF                      PIC X VALUE "N".
          88 END-OF-SOURCE            VALUE "Y".
       01 WS-HALTED                   PIC X VALUE "N".
          88 VM-HALTED                VALUE "Y".
       01 WS-LINE-NUMBER              PIC 9(6) VALUE ZERO.
       01 WS-TRIMMED                  PIC X(4096).
       01 WS-OPCODE                   PIC X(16).
       01 WS-OPERAND                  PIC X(4000).
       01 WS-OPERAND-LENGTH           PIC 9(5) COMP VALUE ZERO.
       01 WS-BYTECODE-OP              PIC 9(4) COMP VALUE ZERO.
          88 BC-PRINT                 VALUE 1.
          88 BC-HALT                  VALUE 255.
       01 WS-ERROR-MESSAGE            PIC X(512).

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           OPEN INPUT SOURCE-STREAM
           PERFORM UNTIL END-OF-SOURCE OR VM-HALTED
               READ SOURCE-STREAM
                   AT END
                       SET END-OF-SOURCE TO TRUE
                   NOT AT END
                       ADD 1 TO WS-LINE-NUMBER
                       MOVE FUNCTION TRIM(SOURCE-LINE) TO WS-TRIMMED
                       IF WS-TRIMMED NOT = SPACES
                           PERFORM LEX-LINE
                           PERFORM PARSE-LINE
                           PERFORM COMPILE-INSTRUCTION
                           PERFORM EXECUTE-INSTRUCTION
                       END-IF
               END-READ
           END-PERFORM
           CLOSE SOURCE-STREAM
           GOBACK.

       LEX-LINE.
           MOVE SPACES TO WS-OPCODE WS-OPERAND
           UNSTRING WS-TRIMMED
               DELIMITED BY ALL SPACES
               INTO WS-OPCODE WS-OPERAND
           END-UNSTRING
           MOVE FUNCTION UPPER-CASE(WS-OPCODE) TO WS-OPCODE.

       PARSE-LINE.
           IF WS-OPCODE = "SAG"
               CONTINUE
           ELSE
               IF WS-OPCODE = "STOPP."
                   MOVE "STOPP" TO WS-OPCODE
               ELSE
                   IF WS-OPCODE = "STOPP"
                       CONTINUE
                   ELSE
                       MOVE SPACES TO WS-ERROR-MESSAGE
                       STRING
                           "Unbekannte SöderLang-Anweisung in Zeile "
                           WS-LINE-NUMBER DELIMITED BY SIZE
                           ": " WS-TRIMMED DELIMITED BY SPACE
                           INTO WS-ERROR-MESSAGE
                       END-STRING
                       DISPLAY FUNCTION TRIM(WS-ERROR-MESSAGE)
                           UPON STDERR
                       MOVE 2 TO RETURN-CODE
                       SET VM-HALTED TO TRUE
                   END-IF
               END-IF
           END-IF.

       COMPILE-INSTRUCTION.
           IF VM-HALTED
               EXIT PARAGRAPH
           END-IF
           EVALUATE WS-OPCODE
               WHEN "SAG"
                   SET BC-PRINT TO TRUE
               WHEN "STOPP"
                   SET BC-HALT TO TRUE
               WHEN OTHER
                   MOVE ZERO TO WS-BYTECODE-OP
           END-EVALUATE.

       EXECUTE-INSTRUCTION.
           EVALUATE TRUE
               WHEN BC-PRINT
                   MOVE FUNCTION TRIM(WS-OPERAND) TO WS-OPERAND
                   MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OPERAND))
                       TO WS-OPERAND-LENGTH
                   IF WS-OPERAND-LENGTH > ZERO
                       IF WS-OPERAND(WS-OPERAND-LENGTH:1) = "."
                           MOVE SPACE TO WS-OPERAND(WS-OPERAND-LENGTH:1)
                       END-IF
                   END-IF
                   DISPLAY FUNCTION TRIM(WS-OPERAND)
               WHEN BC-HALT
                   SET VM-HALTED TO TRUE
               WHEN OTHER
                   CONTINUE
           END-EVALUATE.

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
          88 END-OF-SOURCE               VALUE "Y".
       01 WS-HALTED                      PIC X VALUE "N".
          88 VM-HALTED                   VALUE "Y".
       01 WS-LINE-NUMBER                 PIC 9(6) VALUE ZERO.
       01 WS-LINE                        PIC X(4096) VALUE SPACES.
       01 WS-LENGTH                      PIC 9(5) COMP VALUE ZERO.
       01 WS-T1                          PIC X(256) VALUE SPACES.
       01 WS-T2                          PIC X(256) VALUE SPACES.
       01 WS-T3                          PIC X(256) VALUE SPACES.
       01 WS-T4                          PIC X(256) VALUE SPACES.
       01 WS-T5                          PIC X(256) VALUE SPACES.
       01 WS-T6                          PIC X(2048) VALUE SPACES.
       01 WS-NAME                        PIC X(64) VALUE SPACES.
       01 WS-VALUE-TOKEN                 PIC X(2048) VALUE SPACES.
       01 WS-VALUE-TYPE                  PIC X VALUE SPACE.
          88 VALUE-NUMBER                VALUE "N".
          88 VALUE-TEXT                  VALUE "T".
       01 WS-NUMBER                      PIC S9(18) VALUE ZERO.
       01 WS-TEXT                        PIC X(2048) VALUE SPACES.
       01 WS-TARGET-INDEX                PIC 9(3) COMP VALUE ZERO.
       01 WS-VALUE-INDEX                 PIC 9(3) COMP VALUE ZERO.
       01 WS-I                           PIC 9(3) COMP VALUE ZERO.
       01 WS-FOUND                       PIC X VALUE "N".
          88 FOUND                       VALUE "Y".
       01 WS-ERROR                       PIC X(1024) VALUE SPACES.
       01 WS-DISPLAY-NUMBER              PIC -9(18) VALUE ZERO.

       01 VARIABLE-TABLE.
          05 VAR-ENTRY OCCURS 100 TIMES.
             10 VAR-USED                 PIC X VALUE "N".
             10 VAR-NAME                 PIC X(64) VALUE SPACES.
             10 VAR-TYPE                 PIC X VALUE SPACE.
             10 VAR-NUMBER               PIC S9(18) VALUE ZERO.
             10 VAR-TEXT                 PIC X(2048) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           OPEN INPUT SOURCE-STREAM
           PERFORM UNTIL END-OF-SOURCE OR VM-HALTED
               READ SOURCE-STREAM
                   AT END
                       SET END-OF-SOURCE TO TRUE
                   NOT AT END
                       ADD 1 TO WS-LINE-NUMBER
                       MOVE FUNCTION TRIM(SOURCE-LINE) TO WS-LINE
                       IF WS-LINE NOT = SPACES
                           PERFORM PROCESS-LINE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE SOURCE-STREAM
           GOBACK.

       PROCESS-LINE.
           IF WS-LINE(1:2) = "*>"
               EXIT PARAGRAPH
           END-IF

           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LENGTH
           IF WS-LENGTH > ZERO
               IF WS-LINE(WS-LENGTH:1) = "."
                   MOVE SPACE TO WS-LINE(WS-LENGTH:1)
               END-IF
           END-IF

           MOVE SPACES TO WS-T1 WS-T2 WS-T3 WS-T4 WS-T5 WS-T6
           UNSTRING WS-LINE DELIMITED BY ALL SPACES
               INTO WS-T1 WS-T2 WS-T3 WS-T4 WS-T5 WS-T6
           END-UNSTRING
           MOVE FUNCTION UPPER-CASE(WS-T1) TO WS-T1
           MOVE FUNCTION UPPER-CASE(WS-T2) TO WS-T2
           MOVE FUNCTION UPPER-CASE(WS-T3) TO WS-T3
           MOVE FUNCTION UPPER-CASE(WS-T4) TO WS-T4
           MOVE FUNCTION UPPER-CASE(WS-T5) TO WS-T5

           EVALUATE FUNCTION TRIM(WS-T1)
               WHEN "IDENTIFICATION"
               WHEN "PROGRAM-ID."
               WHEN "PROGRAM-ID"
               WHEN "DATA"
               WHEN "WORKING-STORAGE"
               WHEN "PROCEDURE"
               WHEN "BAYERN"
               WHEN "HAUPTPROGRAMM"
                   CONTINUE
               WHEN "01"
                   PERFORM DECLARE-VARIABLE
               WHEN "SETZE"
                   PERFORM ASSIGN-VARIABLE
               WHEN "ADDIERE"
                   MOVE "ADD" TO WS-T6
                   PERFORM ARITHMETIC-VARIABLE
               WHEN "SUBTRAHIERE"
                   MOVE "SUB" TO WS-T6
                   PERFORM ARITHMETIC-VARIABLE
               WHEN "MULTIPLIZIERE"
                   MOVE "MUL" TO WS-T6
                   PERFORM ARITHMETIC-VARIABLE
               WHEN "DIVIDIERE"
                   MOVE "DIV" TO WS-T6
                   PERFORM ARITHMETIC-VARIABLE
               WHEN "SAG"
                   MOVE WS-T2 TO WS-VALUE-TOKEN
                   PERFORM RESOLVE-VALUE
                   IF NOT VM-HALTED
                       PERFORM DISPLAY-VALUE
                   END-IF
               WHEN "STOPP"
               WHEN "STOPP."
               WHEN "HANDY"
                   SET VM-HALTED TO TRUE
               WHEN OTHER
                   PERFORM SYNTAX-ERROR
           END-EVALUATE.

       DECLARE-VARIABLE.
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2)) TO WS-NAME
           IF FUNCTION TRIM(WS-T4) NOT = "WERT"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM FIND-OR-CREATE-VARIABLE
           IF VM-HALTED
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-T3) = "ZAHL"
               MOVE WS-T5 TO WS-VALUE-TOKEN
               PERFORM RESOLVE-NUMERIC-LITERAL
               IF NOT VM-HALTED
                   MOVE "N" TO VAR-TYPE(WS-TARGET-INDEX)
                   MOVE WS-NUMBER TO VAR-NUMBER(WS-TARGET-INDEX)
               END-IF
           ELSE
               IF FUNCTION TRIM(WS-T3) = "TEXT"
                   MOVE "T" TO VAR-TYPE(WS-TARGET-INDEX)
                   MOVE FUNCTION TRIM(WS-T5) TO WS-TEXT
                   PERFORM STRIP-QUOTES
                   MOVE WS-TEXT TO VAR-TEXT(WS-TARGET-INDEX)
               ELSE
                   PERFORM SYNTAX-ERROR
               END-IF
           END-IF.

       ASSIGN-VARIABLE.
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T2)) TO WS-NAME
           IF FUNCTION TRIM(WS-T3) NOT = "AUF"
               PERFORM SYNTAX-ERROR
               EXIT PARAGRAPH
           END-IF
           PERFORM FIND-VARIABLE
           IF NOT FOUND
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T4 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF VM-HALTED
               EXIT PARAGRAPH
           END-IF
           IF VAR-TYPE(WS-TARGET-INDEX) NOT = WS-VALUE-TYPE
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF VALUE-NUMBER
               MOVE WS-NUMBER TO VAR-NUMBER(WS-TARGET-INDEX)
           ELSE
               MOVE WS-TEXT TO VAR-TEXT(WS-TARGET-INDEX)
           END-IF.

       ARITHMETIC-VARIABLE.
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-T4)) TO WS-NAME
           PERFORM FIND-VARIABLE
           IF NOT FOUND
               PERFORM UNKNOWN-VARIABLE-ERROR
               EXIT PARAGRAPH
           END-IF
           IF VAR-TYPE(WS-TARGET-INDEX) NOT = "N"
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           MOVE WS-T2 TO WS-VALUE-TOKEN
           PERFORM RESOLVE-VALUE
           IF VM-HALTED
               EXIT PARAGRAPH
           END-IF
           IF NOT VALUE-NUMBER
               PERFORM TYPE-ERROR
               EXIT PARAGRAPH
           END-IF
           EVALUATE FUNCTION TRIM(WS-T6)
               WHEN "ADD"
                   ADD WS-NUMBER TO VAR-NUMBER(WS-TARGET-INDEX)
               WHEN "SUB"
                   SUBTRACT WS-NUMBER FROM VAR-NUMBER(WS-TARGET-INDEX)
               WHEN "MUL"
                   MULTIPLY WS-NUMBER BY VAR-NUMBER(WS-TARGET-INDEX)
               WHEN "DIV"
                   IF WS-NUMBER = ZERO
                       PERFORM DIVISION-ZERO-ERROR
                   ELSE
                       DIVIDE WS-NUMBER INTO VAR-NUMBER(WS-TARGET-INDEX)
                   END-IF
           END-EVALUATE.

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

           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-VALUE-TOKEN))
               TO WS-NAME
           PERFORM FIND-VARIABLE
           IF FOUND
               MOVE VAR-TYPE(WS-TARGET-INDEX) TO WS-VALUE-TYPE
               IF VALUE-NUMBER
                   MOVE VAR-NUMBER(WS-TARGET-INDEX) TO WS-NUMBER
               ELSE
                   MOVE VAR-TEXT(WS-TARGET-INDEX) TO WS-TEXT
               END-IF
               EXIT PARAGRAPH
           END-IF

           PERFORM RESOLVE-NUMERIC-LITERAL.

       RESOLVE-NUMERIC-LITERAL.
           MOVE "N" TO WS-VALUE-TYPE
           COMPUTE WS-NUMBER = FUNCTION NUMVAL(
               FUNCTION TRIM(WS-VALUE-TOKEN))
               ON SIZE ERROR
                   PERFORM INVALID-VALUE-ERROR
           END-COMPUTE.

       DISPLAY-VALUE.
           IF VALUE-NUMBER
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
                   IF FUNCTION TRIM(VAR-NAME(WS-I)) =
                      FUNCTION TRIM(WS-NAME)
                       MOVE WS-I TO WS-TARGET-INDEX
                       MOVE "Y" TO WS-FOUND
                       EXIT PERFORM
                   END-IF
               END-IF
           END-PERFORM.

       FIND-OR-CREATE-VARIABLE.
           PERFORM FIND-VARIABLE
           IF FOUND
               EXIT PARAGRAPH
           END-IF
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
               IF VAR-USED(WS-I) NOT = "Y"
                   MOVE "Y" TO VAR-USED(WS-I)
                   MOVE WS-NAME TO VAR-NAME(WS-I)
                   MOVE WS-I TO WS-TARGET-INDEX
                   MOVE "Y" TO WS-FOUND
                   EXIT PERFORM
               END-IF
           END-PERFORM
           IF NOT FOUND
               MOVE "Variablenspeicher ist voll" TO WS-ERROR
               PERFORM RUNTIME-ERROR
           END-IF.

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
           MOVE SPACES TO WS-ERROR
           STRING "Syntaxfehler in Zeile " WS-LINE-NUMBER
               ": " FUNCTION TRIM(WS-LINE)
               INTO WS-ERROR
           END-STRING
           PERFORM FAIL-WITH-ERROR.

       UNKNOWN-VARIABLE-ERROR.
           MOVE SPACES TO WS-ERROR
           STRING "Unbekannte Variable in Zeile " WS-LINE-NUMBER
               ": " FUNCTION TRIM(WS-NAME)
               INTO WS-ERROR
           END-STRING
           PERFORM FAIL-WITH-ERROR.

       INVALID-VALUE-ERROR.
           MOVE SPACES TO WS-ERROR
           STRING "Ungueltiger Wert in Zeile " WS-LINE-NUMBER
               ": " FUNCTION TRIM(WS-VALUE-TOKEN)
               INTO WS-ERROR
           END-STRING
           PERFORM FAIL-WITH-ERROR.

       TYPE-ERROR.
           MOVE SPACES TO WS-ERROR
           STRING "Typfehler in Zeile " WS-LINE-NUMBER
               INTO WS-ERROR
           END-STRING
           PERFORM FAIL-WITH-ERROR.

       DIVISION-ZERO-ERROR.
           MOVE SPACES TO WS-ERROR
           STRING "Division durch Null in Zeile " WS-LINE-NUMBER
               INTO WS-ERROR
           END-STRING
           PERFORM RUNTIME-ERROR.

       RUNTIME-ERROR.
           PERFORM FAIL-WITH-ERROR.

       FAIL-WITH-ERROR.
           DISPLAY FUNCTION TRIM(WS-ERROR) UPON STDERR
           MOVE 2 TO RETURN-CODE
           SET VM-HALTED TO TRUE.
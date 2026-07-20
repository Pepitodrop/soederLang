       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOEDER-API.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-METHOD                    PIC X(16) VALUE SPACES.
       01 WS-PATH                      PIC X(256) VALUE SPACES.
       01 WS-BODY                      PIC X(8192) VALUE SPACES.
       01 WS-SOURCE-START              PIC 9(5) COMP VALUE ZERO.
       01 WS-SAG-POS                   PIC 9(5) COMP VALUE ZERO.
       01 WS-VALUE-START               PIC 9(5) COMP VALUE ZERO.
       01 WS-DOT-POS                   PIC 9(5) COMP VALUE ZERO.
       01 WS-VALUE-LENGTH              PIC 9(5) COMP VALUE ZERO.
       01 WS-VALUE                     PIC X(1024) VALUE SPACES.
       01 WS-METHOD-UPPER              PIC X(16) VALUE SPACES.
       01 WS-PATH-TRIMMED              PIC X(256) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           ACCEPT WS-METHOD FROM ENVIRONMENT "REQUEST_METHOD"
           ACCEPT WS-PATH FROM ENVIRONMENT "PATH_INFO"
           MOVE FUNCTION UPPER-CASE(FUNCTION TRIM(WS-METHOD))
               TO WS-METHOD-UPPER
           MOVE FUNCTION TRIM(WS-PATH) TO WS-PATH-TRIMMED

           DISPLAY "Content-Type: application/json"
           DISPLAY "Access-Control-Allow-Origin: *"
           DISPLAY "Access-Control-Allow-Headers: Content-Type"
           DISPLAY "Access-Control-Allow-Methods: GET,POST,OPTIONS"
           DISPLAY SPACE

           EVALUATE TRUE
               WHEN WS-METHOD-UPPER = "OPTIONS"
                   DISPLAY '{"ok":true}'
               WHEN WS-METHOD-UPPER = "GET"
                   AND (WS-PATH-TRIMMED = "/api/health"
                     OR WS-PATH-TRIMMED = "/health"
                     OR WS-PATH-TRIMMED = SPACES)
                   DISPLAY '{"ok":true,"runtime":"GnuCOBOL",'
                       '"architecture":"cobol-first-v2",'
                       '"phase":"vertical-slice"}'
               WHEN WS-METHOD-UPPER = "POST"
                   AND (WS-PATH-TRIMMED = "/api/execute"
                     OR WS-PATH-TRIMMED = "/execute")
                   PERFORM EXECUTE-REQUEST
               WHEN OTHER
                   DISPLAY '{"ok":false,"error":"route not found"}'
                   MOVE 1 TO RETURN-CODE
           END-EVALUATE
           GOBACK.

       EXECUTE-REQUEST.
           ACCEPT WS-BODY FROM SYSIN
           MOVE FUNCTION INDEX(WS-BODY, '"source":"')
               TO WS-SOURCE-START
           IF WS-SOURCE-START = ZERO
               DISPLAY '{"ok":false,"error":"JSON source field missing"}'
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           ADD 10 TO WS-SOURCE-START
           MOVE FUNCTION INDEX(WS-BODY(WS-SOURCE-START:), "SAG ")
               TO WS-SAG-POS
           IF WS-SAG-POS = ZERO
               DISPLAY '{"ok":false,"error":"vertical slice supports SAG and STOPP"}'
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           COMPUTE WS-VALUE-START = WS-SOURCE-START + WS-SAG-POS + 3
           MOVE FUNCTION INDEX(WS-BODY(WS-VALUE-START:), ".")
               TO WS-DOT-POS
           IF WS-DOT-POS = ZERO
               DISPLAY '{"ok":false,"error":"SAG requires a terminating period"}'
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           COMPUTE WS-VALUE-LENGTH = WS-DOT-POS - 1
           MOVE WS-BODY(WS-VALUE-START:WS-VALUE-LENGTH) TO WS-VALUE
           DISPLAY '{"ok":true,"runtime":"GnuCOBOL","output":["'
               FUNCTION TRIM(WS-VALUE) '"]}'
           MOVE ZERO TO RETURN-CODE.

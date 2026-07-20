       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOEDER-API.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-METHOD                    PIC X(16) VALUE SPACES.
       01 WS-PATH                      PIC X(256) VALUE SPACES.
       01 WS-BODY                      PIC X(8192) VALUE SPACES.
       01 WS-PREFIX                    PIC X(8192) VALUE SPACES.
       01 WS-AFTER-SAG                 PIC X(8192) VALUE SPACES.
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

           IF WS-METHOD-UPPER = "OPTIONS"
               DISPLAY '{"ok":true}'
           ELSE
               IF WS-METHOD-UPPER = "GET"
                   PERFORM HANDLE-GET
               ELSE
                   IF WS-METHOD-UPPER = "POST"
                       PERFORM HANDLE-POST
                   ELSE
                       PERFORM NOT-FOUND
                   END-IF
               END-IF
           END-IF
           GOBACK.

       HANDLE-GET.
           IF WS-PATH-TRIMMED = "/api/health"
               PERFORM HEALTH-RESPONSE
           ELSE
               IF WS-PATH-TRIMMED = "/health"
                   PERFORM HEALTH-RESPONSE
               ELSE
                   IF WS-PATH-TRIMMED = SPACES
                       PERFORM HEALTH-RESPONSE
                   ELSE
                       PERFORM NOT-FOUND
                   END-IF
               END-IF
           END-IF.

       HANDLE-POST.
           IF WS-PATH-TRIMMED = "/api/execute"
               PERFORM EXECUTE-REQUEST
           ELSE
               IF WS-PATH-TRIMMED = "/execute"
                   PERFORM EXECUTE-REQUEST
               ELSE
                   PERFORM NOT-FOUND
               END-IF
           END-IF.

       HEALTH-RESPONSE.
           DISPLAY '{"ok":true,"runtime":"GnuCOBOL",'
               '"architecture":"cobol-first-v2",'
               '"phase":"vertical-slice"}'.

       NOT-FOUND.
           DISPLAY '{"ok":false,"error":"route not found"}'
           MOVE 1 TO RETURN-CODE.

       EXECUTE-REQUEST.
           ACCEPT WS-BODY
           MOVE SPACES TO WS-PREFIX WS-AFTER-SAG WS-VALUE
           UNSTRING WS-BODY
               DELIMITED BY "SAG "
               INTO WS-PREFIX WS-AFTER-SAG
           END-UNSTRING

           IF WS-AFTER-SAG = SPACES
               DISPLAY '{"ok":false,"error":"vertical slice supports SAG and STOPP"}'
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           UNSTRING WS-AFTER-SAG
               DELIMITED BY "."
               INTO WS-VALUE
           END-UNSTRING

           IF WS-VALUE = SPACES
               DISPLAY '{"ok":false,"error":"SAG requires a value"}'
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           DISPLAY '{"ok":true,"runtime":"GnuCOBOL","output":["'
               FUNCTION TRIM(WS-VALUE) '"]}'
           MOVE ZERO TO RETURN-CODE.

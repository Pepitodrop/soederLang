       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOEDER-API.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-METHOD                    PIC X(16) VALUE SPACES.
       01 WS-PATH                      PIC X(256) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           ACCEPT WS-METHOD FROM ENVIRONMENT "REQUEST_METHOD"
           ACCEPT WS-PATH FROM ENVIRONMENT "PATH_INFO"

           DISPLAY "Content-Type: application/json"
           DISPLAY "Access-Control-Allow-Origin: *"
           DISPLAY "Access-Control-Allow-Headers: Content-Type"
           DISPLAY "Access-Control-Allow-Methods: GET,POST,OPTIONS"
           DISPLAY SPACE

           EVALUATE TRUE
               WHEN FUNCTION UPPER-CASE(FUNCTION TRIM(WS-METHOD)) = "OPTIONS"
                   DISPLAY '{"ok":true}'
               WHEN FUNCTION UPPER-CASE(FUNCTION TRIM(WS-METHOD)) = "GET"
                   DISPLAY '{"ok":true,"runtime":"GnuCOBOL",'
                       '"architecture":"cobol-first-v2",'
                       '"phase":"vertical-slice"}'
               WHEN FUNCTION UPPER-CASE(FUNCTION TRIM(WS-METHOD)) = "POST"
                   DISPLAY '{"ok":false,"error":'
                       '"POST execution transport is being wired to '
                       'the COBOL compiler/VM in the next migration step"}'
                   MOVE 1 TO RETURN-CODE
               WHEN OTHER
                   DISPLAY '{"ok":false,"error":"method not allowed"}'
                   MOVE 1 TO RETURN-CODE
           END-EVALUATE
           GOBACK.

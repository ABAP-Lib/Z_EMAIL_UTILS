class ZCL_EMAIL_UTILS definition
  public
  final
  create public .

    public section.

        types:
            ty_v_destinatario type SOMLRECI1-RECEIVER.

        class-methods:
            SEND_HTML_EMAIL
                importing
                    it_destinatarios type stringtab
                    IV_ASSUNTO type CSEQUENCE
                    IV_CORPO type CSEQUENCE
                raising
                    ZCX_EMAIL_ERROR.

    protected section.

        class-methods:
            STRING_TO_TABLE
                importing
                    IV_CONTENT type STRING
                    IV_TAB_LINE_LENGTH type I
                changing
                    CT_CONTENT type TABLE.

    private section.
ENDCLASS.



CLASS ZCL_EMAIL_UTILS IMPLEMENTATION.

    method SEND_HTML_EMAIL.

      FIELD-SYMBOLS:
                     <LV_DESTINATARIO> TYPE STRING,
                     <LS_RECEIVERS> TYPE SOMLRECI1.

      DATA:
            LT_RECEIVERS TYPE STANDARD TABLE OF SOMLRECI1,
            LS_DOCUMENT_DATA TYPE SODOCCHGI1,
            LT_OBJECT_CONTENT TYPE STANDARD TABLE OF SOLISTI1.

      LOOP AT IT_DESTINATARIOS ASSIGNING <LV_DESTINATARIO>.
        CHECK <LV_DESTINATARIO> IS NOT INITIAL.
        APPEND INITIAL LINE TO LT_RECEIVERS ASSIGNING <LS_RECEIVERS>.
        <LS_RECEIVERS>-REC_TYPE  = 'U'.
        <LS_RECEIVERS>-RECEIVER = <LV_DESTINATARIO>.
      ENDLOOP.

      LS_DOCUMENT_DATA-OBJ_LANGU = SY-LANGU.
      LS_DOCUMENT_DATA-OBJ_DESCR = IV_ASSUNTO.

      STRING_TO_TABLE(
        EXPORTING
          IV_CONTENT = IV_CORPO
          IV_TAB_LINE_LENGTH = 255
        CHANGING
          CT_CONTENT = LT_OBJECT_CONTENT
      ).

      CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
        EXPORTING
          DOCUMENT_DATA                    = LS_DOCUMENT_DATA
          DOCUMENT_TYPE                    = 'HTM'
          PUT_IN_OUTBOX                    = ' '
          COMMIT_WORK                      = 'X'
*       IMPORTING
*         SENT_TO_ALL                      =
*         NEW_OBJECT_ID                    =
        TABLES
*         OBJECT_HEADER                    =
          OBJECT_CONTENT                   = LT_OBJECT_CONTENT
*         CONTENTS_HEX                     =
*         OBJECT_PARA                      =
*         OBJECT_PARB                      =
          RECEIVERS                        = LT_RECEIVERS
        EXCEPTIONS
          TOO_MANY_RECEIVERS               = 1
          DOCUMENT_NOT_SENT                = 2
          DOCUMENT_TYPE_NOT_EXIST          = 3
          OPERATION_NO_AUTHORIZATION       = 4
          PARAMETER_ERROR                  = 5
          X_ERROR                          = 6
          ENQUEUE_ERROR                    = 7
          OTHERS                           = 8
                .

      IF SY-SUBRC <> 0.

        raise exception type ZCX_EMAIL_ERROR.

      ENDIF.

    endmethod.

    method STRING_TO_TABLE.

      CALL FUNCTION 'CONVERT_STRING_TO_TABLE'
        EXPORTING
          I_STRING               = IV_CONTENT
          I_TABLINE_LENGTH       = IV_TAB_LINE_LENGTH
        TABLES
          ET_TABLE               = CT_CONTENT
                .

    endmethod.

ENDCLASS.

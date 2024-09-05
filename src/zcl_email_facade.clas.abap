class ZCL_EMAIL_FACADE definition
  public
  final
  create public .

    public section.

        methods:
            constructor
                importing
                    iv_assunto type csequence
                    iv_corpo type csequence
                    IV_TYPE type SO_OBJ_TP default 'RAW'
                raising
                    CX_DOCUMENT_BCS
                    CX_SEND_REQ_BCS,

            set_sender_from_user
                importing
                    iv_user type sy-uname default sy-uname
                raising
                    CX_ADDRESS_BCS
                    CX_SEND_REQ_BCS,

            add_recipient_from_address
                importing
                    iv_address type ADR6-SMTP_ADDR
                raising
                    CX_ADDRESS_BCS
                    CX_SEND_REQ_BCS,

            add_pdf_attach_from_xstring
                importing
                    iv_attachment_filename type csequence
                    iv_attachment_content type xstring
                raising
                    CX_DOCUMENT_BCS,

            send
                importing
                    iv_with_error_screen type abap_bool default abap_true
                exporting
                    ev_sent_to_all type abap_bool
                raising
                    CX_SEND_REQ_BCS,

            commit.

    protected section.

        data:
            lo_document TYPE REF TO cl_document_bcs.

        DATA:
            lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.

    private section.

ENDCLASS.



CLASS ZCL_EMAIL_FACADE IMPLEMENTATION.

    method constructor.

        DATA:
            lt_message_body TYPE bcsy_text.

        ZCL_EMAIL_UTILS=>string_to_table(
            exporting
                iv_content = conv #( iv_corpo )
                iv_tab_line_length = 255
            changing
                ct_content = lt_message_body
        ).

        lo_document = cl_document_bcs=>create_document(
            i_type = iv_type
            i_text = lt_message_body
            i_subject = conv #( iv_assunto )
        ).

        lo_send_request = cl_bcs=>create_persistent( ).

    endmethod.

    method set_sender_from_user.

        DATA:
            lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL,
            l_send type ADR6-SMTP_ADDR value 'abc@test.com'.

*        lo_sender = cl_cam_address_bcs=>create_internet_address( l_send ).
        lo_sender = cl_sapuser_bcs=>create( sy-uname ).
        lo_send_request->set_sender(
            EXPORTING
                i_sender = lo_sender
        ).

    endmethod.

    method add_recipient_from_address.

        DATA:
            lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.

        lo_recipient = cl_cam_address_bcs=>create_internet_address( iv_address ).

        lo_send_request->add_recipient(
            EXPORTING
                i_recipient = lo_recipient
                i_express = 'X'
        ).

    endmethod.

    method add_pdf_attach_from_xstring.

        data:
            lt_bindata TYPE solix_tab.

        call function 'SCMS_XSTRING_TO_BINARY'
          exporting
            BUFFER          = iv_attachment_content
*            APPEND_TO_TABLE = SPACE
*          importing
*            OUTPUT_LENGTH   =
          tables
            BINARY_TAB      = lt_bindata
          .

        lo_document->add_attachment(
            EXPORTING
                i_attachment_type = 'PDF'
                i_attachment_subject = conv #( iv_attachment_filename )
*               I_ATTACHMENT_SIZE =
*               I_ATTACHMENT_LANGUAGE = SPACE
*               I_ATT_CONTENT_TEXT =
*               I_ATTACHMENT_HEADER =
                i_att_content_hex = lt_bindata
        ).

    endmethod.

    method send.

        lo_send_request->set_document( lo_document ).

        ev_sent_to_all = lo_send_request->send(
            EXPORTING
                i_with_error_screen = 'X'
        ).

    endmethod.

    method commit.
        commit work and wait.
    endmethod.

ENDCLASS.

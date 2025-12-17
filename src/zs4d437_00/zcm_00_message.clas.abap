CLASS zcm_00_message DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF cancel_success,
        msgid TYPE symsgid VALUE '/LRN/S4D437',
        msgno TYPE symsgno VALUE '120',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF cancel_success .
    CONSTANTS:
      BEGIN OF already_canceled,
        msgid TYPE symsgid VALUE '/LRN/S4D437',
        msgno TYPE symsgno VALUE '130',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF already_canceled .
    CONSTANTS:
      BEGIN OF field_empty,
        msgid TYPE symsgid VALUE '/LRN/S4D437',
        msgno TYPE symsgno VALUE '200',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF field_empty .


    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .


    METHODS constructor
      IMPORTING
        textid   LIKE if_t100_message=>t100key
        severity LIKE if_abap_behv_message=>m_severity OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_00_message IMPLEMENTATION.

  METHOD constructor  ##ADT_SUPPRESS_GENERATION.

    super->constructor(  ).

    if_t100_message~t100key = textid.
    IF severity IS SUPPLIED.
      if_abap_behv_message~m_severity = severity.
    ELSE.
      if_abap_behv_message~m_severity = if_abap_behv_message~severity-error.
    ENDIF.


  ENDMETHOD.
ENDCLASS.

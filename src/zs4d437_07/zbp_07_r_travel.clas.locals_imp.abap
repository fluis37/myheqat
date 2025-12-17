CLASS lhc_Z07_R_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.

ENDCLASS.

CLASS lhc_Z07_R_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <result>-agencyid
                                                        i_actvt = '02' ).
      IF rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <result>-%update = if_abap_behv=>auth-allowed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF z07_r_travel IN LOCAL MODE
       ENTITY travel
         ALL FIELDS
         WITH CORRESPONDING #( keys )
       RESULT DATA(travels).
    IF travels IS NOT INITIAL.
      LOOP AT travels INTO DATA(travel).
        IF travel-Status <> 'C'.
          MODIFY ENTITIES OF Z07_R_Travel IN LOCAL MODE
          ENTITY Travel
          UPDATE FIELDS ( status )
          WITH VALUE #( ( %tky = travel-%tky status = 'C' ) ).
        ELSE.
          APPEND VALUE #( %tky = travel-%tky )
            TO failed-travel.
          APPEND VALUE #( %tky = travel-%tky
                          %msg = NEW zcm_07_travel( textid = zcm_07_travel=>already_canceled ) )
            TO reported-travel.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

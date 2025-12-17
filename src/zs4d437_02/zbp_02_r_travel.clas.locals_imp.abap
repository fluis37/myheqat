CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).
    loop at result ASSIGNING FIELD-SYMBOL(<result>).
      data(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <result>-AgencyId i_actvt = '02' ).
      if rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update               = if_abap_behv=>auth-unauthorized.
      else.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <result>-%update               = if_abap_behv=>auth-allowed.
      endif.
    endloop.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF Z02_R_Travel in local mode ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys ) result data(travels).
    loop at travels ASSIGNING FIELD-SYMBOL(<travel>).
      if <travel>-status ne 'C'.
        modify entities of z02_r_travel in local mode
          ENTITY travel update fields ( status )
          with value #( ( %tky = <travel>-%tky status = 'C' ) ).
      else.
        append value #( %tky = <travel>-%tky ) to failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW zcm_02_travel( textid = zcm_02_travel=>already_canceled ) ) TO reported-travel.
      endif.
    endloop.
  ENDMETHOD.

ENDCLASS.

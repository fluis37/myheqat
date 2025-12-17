CLASS lhc_Z05_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.

ENDCLASS.

CLASS lhc_Z05_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING  #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).

      DATA(r_result) = /lrn/cl_s4d437_model=>authority_check(
        EXPORTING
          i_agencyid = <result>-AgencyId
          i_actvt    = '02'
      ).
      IF r_result = 0.
        <result>-%update = if_abap_behv=>auth-allowed.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.

      ELSE.
        <result>-%update = if_abap_behv=>auth-unauthorized.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF Z05_R_Travel IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-Status <> 'C'.
        MODIFY ENTITIES OF Z05_R_Travel IN LOCAL MODE ENTITY Travel UPDATE FIELDS ( Status )
            WITH VALUE #( ( %tky   = <travel>-%tky
                            status = 'C' ) ).
      ELSE.
*        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
*        APPEND VALUE #( %tky        = <travel>-%tky
*                        %state_area = 'CANCEL_TRAVEL'
*                        %msg        = NEW /dmo/cm_flight_home( textid      = /dmo/cm_flight_home=>travel_already_cancelled
*                                                               travel_id   = <travel>-TravelID
*                                                               severity    =
      ENDIF.
*      travel-Status = 'X'.
*      MODIFY ENTITIES OF Z05_R_Travel IN LOCAL MODE ENTITY Travel
*      UPDATE FIELDS ( Status )
*      WITH VALUE #( ( %tky = travel-%tky Status = travel-Status ) )
*      FAILED failed REPORTED reported.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

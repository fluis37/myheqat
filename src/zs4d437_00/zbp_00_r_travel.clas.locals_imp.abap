CLASS lhc_Z00_R_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS issue_message FOR MODIFY
      IMPORTING keys FOR ACTION Travel~issue_message.

    METHODS static_ation FOR MODIFY
      IMPORTING keys FOR ACTION Travel~static_ation.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

ENDCLASS.

CLASS lhc_Z00_R_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).

      DATA(rc) =  /lrn/cl_s4d437_model=>authority_check(
                              i_agencyid  = <result>-agencyid
                              i_actvt     = '02' ).

      IF rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update               = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <result>-%update               = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD issue_message.


  ENDMETHOD.

  METHOD static_ation.
  ENDMETHOD.

  METHOD cancel_travel.


    READ ENTITIES OF z00_r_travel IN LOCAL MODE
      ENTITY travel
        ALL FIELDS
       WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      IF travel-status <> 'C'.

        MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
          ENTITY travel
            UPDATE
            FIELDS ( status )
            WITH VALUE #( (
                   %tky   = travel-%tky
                   status = 'C'
                 ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky )
            TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW zcm_00_message(
                                     textid = zcm_00_message=>already_canceled
                                   )
                      )
            TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
      ALL FIELDS
     WITH CORRESPONDING #( keys )
   RESULT DATA(travels).


    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-CustomerId IS INITIAL.
        "APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.


        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW zcm_00_message(
                                     textid = zcm_00_message=>field_empty
                                     severity = zcm_00_message=>if_abap_behv_message~severity-success
                                   )
                        %element-customerid = if_abap_behv=>mk-on
                      )
            TO reported-travel.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

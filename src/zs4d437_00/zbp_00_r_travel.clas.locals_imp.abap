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
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.

    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.

    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

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


  METHOD validatedescription.

    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( description )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-description IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-description = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
            TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatecustomer.

    CONSTANTS c_area TYPE string VALUE `CUST`.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( customerid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-customerid IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-customerid = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
            TO reported-travel.
      ELSE.

        SELECT SINGLE
          FROM /dmo/i_customer
        FIELDS customerid
         WHERE customerid = @<travel>-customerid
          INTO @DATA(dummy).

        IF sy-subrc <> 0.

          APPEND VALUE #(  %tky = <travel>-%tky )
              TO failed-travel.

          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                                       textid     = /lrn/cm_s4d437=>customer_not_exist
                                       customerid = <travel>-customerid
                                     )
                          %element-customerid = if_abap_behv=>mk-on
                          %state_area = c_area
                         )
          TO reported-travel.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatebegindate.

    CONSTANTS c_area TYPE string VALUE `BEGINDATE`.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( begindate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.
      IF <travel>-begindate IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-begindate = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
            TO reported-travel.
      ELSEIF <travel>-begindate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     textid     = /lrn/cm_s4d437=>begin_date_past
                                   )
                        %element-begindate = if_abap_behv=>mk-on
                        %state_area = c_area
                       )
        TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateenddate.
    CONSTANTS c_area TYPE string VALUE `ENDDATE`.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-enddate IS INITIAL.

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-enddate = if_abap_behv=>mk-on
                      %state_area = c_area
                       )
            TO reported-travel.
      ELSEIF <travel>-enddate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #(  %tky = <travel>-%tky )
            TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     textid     = /lrn/cm_s4d437=>end_date_past
                                   )
                        %element-enddate = if_abap_behv=>mk-on
                      %state_area = c_area
                       )
        TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedatesequence.
    CONSTANTS c_area TYPE string VALUE `SEQUENCE`.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( begindate enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area
                     )
          TO reported-travel.

      IF <travel>-enddate < <travel>-begindate.
        APPEND VALUE #(  %tky = <travel>-%tky )
           TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>dates_wrong_sequence
                                   )
                    %element = VALUE #(
                                     begindate = if_abap_behv=>mk-on
                                     enddate   = if_abap_behv=>mk-on
                                )
                    %state_area = c_area
                       )
             TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-agencyid = agencyid.
      <mapping>-travelid = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF Z00_r_travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DELETE travels WHERE Status IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF Z00_r_travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN travels ( %tky   = key-%tky
                                           Status = 'N' )  )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( status begindate enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND CORRESPONDING #( <travel> ) TO result
             ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-status = 'C' OR
         ( <travel>-enddate IS NOT INITIAL AND
           <travel>-enddate < cl_abap_context_info=>get_system_date( )
         ).

        <result>-%update               = if_abap_behv=>fc-o-disabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.

      ELSE.

        <result>-%update               = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.

      ENDIF.

      IF <travel>-begindate IS NOT INITIAL AND
         <travel>-begindate < cl_abap_context_info=>get_system_date( ).

        <result>-%field-customerid = if_abap_behv=>fc-f-read_only.
        <result>-%field-begindate  = if_abap_behv=>fc-f-read_only.

      ELSE.

        <result>-%field-customerid = if_abap_behv=>fc-f-mandatory.
        <result>-%field-begindate  = if_abap_behv=>fc-f-mandatory.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineDuration.

    read entities of Z00_r_travel IN LOCAL MODE
      entity travel
        fields ( begindate enddate )
        with corresponding #( keys )
        RESULT Data(travels).

     LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
        DATA(duration) = <travel>-enddate - <travel>-begindate.
        MODIFY ENTITIES of Z00_r_travel IN LOCAL MODE
          ENTITY travel
            UPDATE FIELDS ( duration )
            WITH VALUE #( ( %tky = <travel>-%tky
                            duration = duration ) ).
     ENDLOOP.

  ENDMETHOD.

ENDCLASS.

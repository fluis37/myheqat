CLASS lsc_z03_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

  PRIVATE SECTION.
    METHODS map_message
      IMPORTING
        i_msg        TYPE symsg
      RETURNING
        VALUE(r_msg) TYPE REF TO if_abap_behv_message.

ENDCLASS.

CLASS lsc_z03_r_travel IMPLEMENTATION.

  METHOD save_modified.

    DATA(model) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z03_TRITEM' ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
      DATA(msg_d) = model->delete_item( i_uuid = <item_d>-ItemUuid ).
      IF msg_d IS NOT INITIAL.
        APPEND VALUE #( %tky-itemuuid = <item_d>-ItemUuid
                        %msg = map_message( msg_d ) )
                        TO reported-item.
      ENDIF.
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
      DATA(msg_c) = model->create_item( i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).
      IF msg_c IS NOT INITIAL.
        APPEND VALUE #( %tky-itemuuid = <item_c>-ItemUuid
                        %msg = map_message( msg_c ) )
                        TO reported-item.
      ENDIF.
    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
      DATA(msg_u) = model->update_item( i_item = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
                          i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY
                          USING CONTROL ) ).
      IF msg_u IS NOT INITIAL.
        APPEND VALUE #( %tky-itemuuid = <item_u>-ItemUuid
                        %msg = map_message( msg_u ) )
                        TO reported-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.



  METHOD map_message.

    DATA(severity) = SWITCH #(  i_msg-msgty
    WHEN 'S' THEN if_abap_behv_message=>severity-success
    WHEN 'I' THEN if_abap_behv_message=>severity-information
    WHEN 'W' THEN if_abap_behv_message=>severity-warning
    WHEN 'E' THEN if_abap_behv_message=>severity-error
    WHEN 'A' THEN if_abap_behv_message=>severity-error
    WHEN 'X' THEN if_abap_behv_message=>severity-error
    ELSE          if_abap_behv_message=>severity-none ).

    r_msg = NEW_message(
    id = i_msg-msgid
    number = i_msg-msgno
    severity = severity
    v1 = i_msg-msgv1
    v2 = i_msg-msgv2
    v3 = i_msg-msgv3
    v4 = i_msg-msgv4 ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateFlightDate.
    METHODS determineTravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~determineTravelDates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validateFlightDate.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
          ENTITY Item
          FIELDS ( AgencyId TravelId FlightDate )
          WITH CORRESPONDING #( keys )
          RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = 'FLDATE' )
                      TO reported-item.

      IF <item>-FlightDate IS INITIAL.
        APPEND VALUE #( %tky = <item>-%tky ) TO failed-item.
        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-FlightDate = if_abap_behv=>mk-on
                        %state_area = 'FLDATE'
                        %path-travel = CORRESPONDING #( <item> ) )
                        TO reported-item.
      ELSEIF <item>-FlightDate < cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = <item>-%tky ) TO failed-item.
        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>begin_date_past )
                        %element-FlightDate = if_abap_behv=>mk-on
                        %state_area = 'FLDATE'
                        %path-travel = CORRESPONDING #( <item> ) )
                        TO reported-item.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineTravelDates.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
            ENTITY Item
            FIELDS ( FlightDate )
            WITH CORRESPONDING #( keys )
            RESULT DATA(items)
            BY \_Travel
            FIELDS ( BeginDate EndDate )
            WITH CORRESPONDING #( keys )
            RESULT DATA(travels)
            LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      ASSIGN travels[ %tky =
                     link[ source-%tky = <item>-%tky ]-target-%tky ]
                     TO FIELD-SYMBOL(<travel>).

      IF <travel>-EndDate < <item>-FlightDate.
        <travel>-EndDate = <item>-FlightDate.
      ENDIF.

      IF <item>-FlightDate < cl_abap_context_info=>get_system_date(  )
      AND <item>-FlightDate < <travel>-BeginDate.
        <travel>-BeginDate = <item>-FlightDate.
      ENDIF.

      MODIFY ENTITIES OF Z03_R_Travel IN LOCAL MODE
      ENTITY Travel
      UPDATE FIELDS ( BeginDate EndDate )
      WITH CORRESPONDING #( travels ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.
*    METHODS validateCustomer2 FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Travel~validateCustomer2.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      DATA(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <lfs_travel>-AgencyId i_actvt = '02' ).

      IF rc = 0.
        <lfs_travel>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <lfs_travel>-%update = if_abap_behv=>auth-allowed.
      ELSE.
        <lfs_travel>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <lfs_travel>-%update = if_abap_behv=>auth-unauthorized.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF z03_r_travel IN LOCAL MODE
        ENTITY Travel
           FIELDS ( Status )
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).
      IF <lfs_travel>-Status NE 'C'.
        MODIFY ENTITIES OF z03_r_travel IN LOCAL MODE
              ENTITY Travel
              UPDATE FIELDS ( Status )
              WITH VALUE #( ( %tky = <lfs_travel>-%tky
                              Status = 'C' ) )
              REPORTED DATA(lt_reported)
              FAILED failed.

      ELSE.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW zcm_03_travel( textid = zcm_03_travel=>msg_error  ) ) TO reported-travel.
*                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>already_canceled ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescription.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( Description )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( %tky = <lfs_travel>-%tky
                      %state_area = 'DESCR' )
                      TO reported-travel.

      IF <lfs_travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area = 'DESCR' )
                        TO reported-travel.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( %tky = <lfs_travel>-%tky
                      %state_area = 'CUST' )
                      TO reported-travel.

      IF <lfs_travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-CustomerId = if_abap_behv=>mk-on
                        %state_area = 'CUST' )
                        TO reported-travel.
      ELSE.

        SELECT SINGLE FROM /DMO/I_Customer
            FIELDS CustomerID
            WHERE CustomerID = @<lfs_travel>-CustomerId
            INTO @DATA(lv_customer).

        IF sy-subrc NE 0.

          APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <lfs_travel>-%tky
                          %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>customer_not_exist
                          customerid = <lfs_travel>-CustomerId )
                          %element-CustomerId = if_abap_behv=>mk-on )
                          TO reported-travel.

        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateBeginDate.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
      ENTITY Travel
      FIELDS ( BeginDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( %tky = <lfs_travel>-%tky
                      %state_area = 'BDAT' )
                      TO reported-travel.

      IF  <lfs_travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %state_area = 'BDAT' )
                        TO reported-travel.
      ELSEIF <lfs_travel>-BeginDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>begin_date_past )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %state_area = 'BDAT' )
                        TO reported-travel.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
      ENTITY Travel
      FIELDS ( EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( %tky = <lfs_travel>-%tky
                    %state_area = 'EDAT' )
                    TO reported-travel.

      IF  <lfs_travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-EndDate = if_abap_behv=>mk-on
                        %state_area = 'EDAT' )
                        TO reported-travel.
      ELSEIF <lfs_travel>-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>end_date_past )
                        %element-EndDate = if_abap_behv=>mk-on
                        %state_area = 'EDAT' )
                        TO reported-travel.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateDateSequence.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
      ENTITY Travel
      FIELDS ( BeginDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).

      APPEND VALUE #( %tky = <lfs_travel>-%tky
              %state_area = 'SDAT' )
              TO reported-travel.

      IF <lfs_travel>-EndDate < <lfs_travel>-BeginDate.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>dates_wrong_sequence )
                        %element = VALUE #( BeginDate = if_abap_behv=>mk-on EndDate = if_abap_behv=>mk-on )
                        %state_area = 'SDAT' )
                        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

*  METHOD validateCustomer2.
*    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
*          ENTITY Travel
*          FIELDS ( CustomerId )
*          WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_travels).
*
*    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travel>).
*
*      IF <lfs_travel>-CustomerId IS INITIAL.
*        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
*        APPEND VALUE #( %tky = <lfs_travel>-%tky
*                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
*                        %element-Description = if_abap_behv=>mk-on )
*                        TO reported-travel.
*      ELSE.
*
*        SELECT SINGLE FROM /DMO/I_Customer
*            FIELDS CustomerID
*            WHERE CustomerID = @<lfs_travel>-CustomerId
*            INTO @DATA(lv_customer).
*
*        IF sy-subrc NE 0.
*
*          APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
*          APPEND VALUE #( %tky = <lfs_travel>-%tky
*                          %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>customer_not_exist
*                          customerid = <lfs_travel>-CustomerId )
*                          %element-CustomerId = if_abap_behv=>mk-on )
*                          TO reported-travel.
*
*        ENDIF.
*      ENDIF.
*
*    ENDLOOP.
*  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      <fs_travel>-AgencyId = agencyid.
      <fs_travel>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travels).

    DELETE lt_travels WHERE Status IS NOT INITIAL.
    CHECK lt_travels IS NOT INITIAL.

    MODIFY ENTITIES OF Z03_R_Travel IN LOCAL MODE
     ENTITY Travel
      UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN lt_travels ( %tky = key-%tky
                                            status = 'N' ) )
      REPORTED DATA(reported_travel).

    reported = CORRESPONDING #( DEEP reported_travel ).
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( Status BeginDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<lfs_travels>).

      APPEND CORRESPONDING #( <lfs_travels> ) TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).

      IF <lfs_travels>-Status = 'C' OR
      (  <lfs_travels>-EndDate IS NOT INITIAL AND
      <lfs_travels>-EndDate < cl_abap_context_info=>get_system_date( ) ).
        <lfs_result>-%update = if_abap_behv=>fc-o-disabled.
        <lfs_result>-%features-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <lfs_result>-%update = if_abap_behv=>fc-o-enabled.
        <lfs_result>-%features-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <lfs_travels>-BeginDate IS NOT INITIAL AND
      <lfs_travels>-BeginDate < cl_abap_context_info=>get_system_date( ).
        <lfs_result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
        <lfs_result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <lfs_result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
        <lfs_result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.

      APPEND CORRESPONDING #( <lfs_travels> )
      TO result ASSIGNING FIELD-SYMBOL(<result>).

      IF <lfs_travels>-%is_draft = if_abap_behv=>mk-on.

        READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH VALUE #( ( %key = <lfs_travels>-%key ) )

        RESULT DATA(travels_active).

        IF travels_active IS NOT INITIAL.
          <lfs_travels>-BeginDate = travels_active[ 1 ]-BeginDate.
          <lfs_travels>-EndDate = travels_active[ 1 ]-EndDate.
        ELSE.
          CLEAR <lfs_travels>-BeginDate.
          CLEAR <lfs_travels>-EndDate.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineDuration.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys ) RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-Duration = <travel>-EndDate - <travel>-BeginDate.
    ENDLOOP.

    MODIFY ENTITIES OF Z03_R_Travel IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( Duration )
    WITH CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.

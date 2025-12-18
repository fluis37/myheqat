**********************************************************************
*Local Types lsc_z08_r_travel  Local Saver Class
*The local saver class is always meant for the entire business object,
*not for an individual entity. Therefore, it uses the name of the business object.
*It must not use travel, because this is the alias name of the root entity,
*not an alias name for the business object.
**********************************************************************
CLASS lsc_z08_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z08_r_travel IMPLEMENTATION.

  METHOD save_modified.
*   create an instance of the /LRN/CL_S4D437_TRITEM class
*   and store a reference to the new instance in an inline declared variable model
    DATA(model) = NEW zCL_08_S4D437_TRITEM( i_table_name = 'Z08_TRITEM' ).


    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
      model->delete_item( i_uuid = <item_d>-itemuuid ).
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).

*     quand les noms des champs sont identiques
*      model->create_item( i_item = CORRESPONDING #( <item_c> ) ).

*     On utilise le "mapping for /lrn/437_s_tritem" défini dans la behavior definition Z08_R_TRAVEL
      model->create_item( i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).

    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
      model->update_item(
      i_item = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
      i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY USING CONTROL ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

**********************************************************************
*Local Types lhc_Item   Local Handler Class
**********************************************************************
CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateFlightDate.
    METHODS determineTravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~determineTravelDates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

* Control la validité de la date
  METHOD validateFlightDate.
    CONSTANTS c_area TYPE string VALUE `FLIGHTDATE`.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE
         ENTITY Item
          FIELDS ( AgencyId TravelId FlightDate )
          WITH CORRESPONDING #(  keys )
         RESULT DATA(lt_item).

    LOOP AT lt_item INTO DATA(ls_item).
      "Vide les précédents messages liés à l'aréa
      APPEND VALUE #( %tky = ls_item-%tky
                      %state_area = c_area )
        TO reported-item.
      IF ls_item-FlightDate IS INITIAL.
        APPEND VALUE #( %tky = ls_item-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = ls_item-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-FlightDate = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( ls_item ) )
            TO reported-item.
      ELSEIF ls_item-FlightDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-item.
        APPEND VALUE #( %tky = ls_item-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>flight_date_past )
                        %element-FlightDate = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( ls_item ) )
            TO reported-item.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineTravelDates.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE
      ENTITY Item FIELDS ( FlightDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(items)

      BY \_Travel
      FIELDS ( BeginDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
*      ASSIGN travels[ %tky = link[ source-%tky = <item>-%tky ]-target-%tky ]
*          TO FIELD-SYMBOL(<travel>).

*      READ TABLE travels ASSIGNING FIELD-SYMBOL(<travel>)
*            WITH KEY %tky = link[ source-%tky = <item>-%tky ]-target-%tky.

      ASSIGN travels[ KEY id %tky = link[ KEY id source-%tky = <item>-%tky ]-target-%tky ]
        TO FIELD-SYMBOL(<travel>).

      IF <travel>-EndDate < <item>-FlightDate.
        <travel>-EndDate = <item>-FlightDate.
      ENDIF.

      IF <item>-FlightDate > cl_abap_context_info=>get_system_date( )
      AND <item>-FlightDate < <travel>-BeginDate.
        <travel>-BeginDate = <item>-FlightDate.
      ENDIF.

    ENDLOOP.

*   Actualise la table TRAVEL
    MODIFY ENTITIES OF Z08_R_Travel IN LOCAL MODE
    ENTITY Travel UPDATE FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.

**********************************************************************
*Local Types lhc_Travel
**********************************************************************
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
    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
                        i_agencyid = <result>-agencyid
                        i_actvt = '02' ).
      IF rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

*-Button
  METHOD cancel_travel.
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
         ENTITY Travel
          ALL FIELDS WITH CORRESPONDING #(  keys )
          RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-status <> 'C'.
        MODIFY ENTITIES OF Z08_R_Travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( status )
        WITH VALUE #( ( %tky = travel-%tky
                         status = 'C' ) )
            FAILED failed
            REPORTED reported.

      ELSE.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %msg = new_message( id       = '/LRN/S4D437'
                                            number   = '130'
                                            severity = if_abap_behv_message=>severity-warning
                                            v1       = travel-TravelID ) )
        TO reported-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW ZCM_08_travel( textid = zcm_08_travel=>already_canceled ) )
        TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*-Control Description before save
  METHOD validateDescription.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF z08_r_travel IN LOCAL MODE
         ENTITY Travel
          FIELDS ( description )
          WITH CORRESPONDING #(  keys )
         RESULT DATA(lt_travel).

    LOOP AT lt_travel INTO DATA(ls_travel).

*     Vide le message
      APPEND VALUE #( %tky = ls_travel-%tky
                        %state_area = c_area ) TO reported-travel.

      IF ls_travel-Description IS INITIAL.
        APPEND VALUE #( %key = ls_travel-%key ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW ZCM_08_travel( textid = zcm_08_travel=>field_empty )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area = c_area )
        TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*-Control CustomerID before save
  METHOD validateCustomer.
    CONSTANTS c_area TYPE string VALUE `CUST`.

    READ ENTITIES OF z08_r_travel IN LOCAL MODE ENTITY Travel FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys ) RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area ) TO reported-travel.

      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-CustomerId = if_abap_behv=>mk-on
                        %state_area = c_area )
        TO reported-travel.

        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437(
            textid = /lrn/cm_s4d437=>customer_not_exist
                    customerid = <travel>-CustomerId )
                    %element-CustomerId = if_abap_behv=>mk-on
                    %state_area = c_area )
            TO reported-travel.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE ENTITY Travel FIELDS ( BeginDate )
    WITH CORRESPONDING #( keys ) RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
        %element-BeginDate = if_abap_behv=>mk-on )
        TO reported-travel.
      ELSEIF <travel>-begindate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>begin_date_past )
        %element-Begindate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE ENTITY Travel FIELDS ( EndDate )
    WITH CORRESPONDING #( keys ) RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
        %element-EndDate = if_abap_behv=>mk-on )
        TO reported-travel.
      ELSEIF <travel>-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>end_date_past )
        %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDateSequence.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE ENTITY Travel FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys ) RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>dates_wrong_sequence )
        %element = VALUE #( BeginDate = if_abap_behv=>mk-on EndDate = if_abap_behv=>mk-on ) )
        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).
    mapped-travel = CORRESPONDING #( entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-AgencyId = agencyid.
      <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.
  ENDMETHOD.

*-Determine the status "N"ew at save push
  METHOD determineStatus.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE ENTITY Travel
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE Status IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF Z08_R_Travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN travels ( %tky = key-%tky
                                            Status = 'N' ) )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

*-Authorization  management on fields and button
  METHOD get_instance_features.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( Status BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND CORRESPONDING #( <travel> )
          TO result ASSIGNING FIELD-SYMBOL(<result>).

*     draft version ?
      IF <travel>-%is_draft = if_abap_behv=>mk-on.
*       Lire (la version active de) la BD
        READ ENTITIES OF Z08_R_Travel IN LOCAL MODE
          ENTITY Travel FIELDS ( BeginDate EndDate )
            WITH VALUE #( ( %key = <travel>-%key ) )
            RESULT DATA(travels_active).
*       recharge les données de la version active (de la BD)
        IF travels_active IS NOT INITIAL.
          <travel>-BeginDate = travels_active[ 1 ]-BeginDate.
          <travel>-EndDate = travels_active[ 1 ]-EndDate.
        ELSE.
          CLEAR <travel>-BeginDate.
          CLEAR <travel>-EndDate.
        ENDIF.
      ENDIF.

      IF <travel>-Status = 'C'
      OR ( <travel>-EndDate IS NOT INITIAL
        AND <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <result>-%update = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <travel>-BeginDate IS NOT INITIAL
      AND <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).
        <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

* Calcule la durée
  METHOD determineDuration.
    READ ENTITIES OF Z08_R_Travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-Duration = <travel>-EndDate - <travel>-BeginDate.
    ENDLOOP.

    MODIFY ENTITIES OF Z08_R_Travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Duration )
        WITH CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.

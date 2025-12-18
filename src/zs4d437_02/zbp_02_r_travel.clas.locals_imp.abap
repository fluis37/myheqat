CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
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

    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.

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

  METHOD validateDescription.
    constants c_area type string value 'DESC'.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( Description )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      append value #( %tky = <travel>-%tky
                      %state_area = c_area )
        to reported-travel.
      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area = c_area )
          TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.
    CONSTANTS c_area TYPE string VALUE `CUST`.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-CustomerId = if_abap_behv=>mk-on
                        %state_area = c_area )
          TO reported-travel.
      ELSE.
        SELECT SINGLE FROM /dmo/i_customer
          FIELDS CustomerID
          WHERE CustomerID = @<travel>-CustomerId
          INTO @DATA(dummy).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>customer_not_exist customerid = <travel>-CustomerId )
                          %element-CustomerId = if_abap_behv=>mk-on
                          %state_area = c_area )
            TO reported-travel.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.
    CONSTANTS c_area TYPE string VALUE `BEGINDATE`.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( BeginDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %state_area = c_area )
          TO reported-travel.
      ELSEIF <travel>-begindate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>begin_date_past )
                        %element-Begindate = if_abap_behv=>mk-on
                        %state_area = c_area )
          TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDateSequence.
    CONSTANTS c_area TYPE string VALUE `DATESEAQUENCE`.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>dates_wrong_sequence )
                        %element = VALUE #( BeginDate = if_abap_behv=>mk-on EndDate = if_abap_behv=>mk-on )
                        %state_area = c_area )
          TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    CONSTANTS c_area TYPE string VALUE `ENDDATE`.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky %state_area = c_area ) TO reported-travel.
      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-EndDate = if_abap_behv=>mk-on
                        %state_area = c_area )
          TO reported-travel.
      ELSEIF <travel>-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>end_date_past )
                        %element-EndDate = if_abap_behv=>mk-on
                        %state_area = c_area )
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

  METHOD determineStatus.
    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).
    DELETE travels WHERE Status IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.
    MODIFY ENTITIES OF Z02_R_Travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( Status ) WITH VALUE #( FOR key IN travels ( %tky = key-%tky Status = 'N' ) )
        REPORTED DATA(update_reported). .
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE ENTITY Travel FIELDS ( Status BeginDate EndDate ) WITH CORRESPONDING #( keys ) RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND CORRESPONDING #( <travel> ) TO result ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
          ENTITY Travel
            FIELDS ( BeginDate EndDate )
            WITH VALUE #( ( %key = <travel>-%key ) )
            RESULT DATA(travels_active).
        IF travels_active IS NOT INITIAL.
          <travel>-BeginDate = travels_active[ 1 ]-BeginDate.
          <travel>-EndDate = travels_active[ 1 ]-EndDate.
        ELSE.
          CLEAR <travel>-BeginDate.
          CLEAR <travel>-EndDate.
        ENDIF.
      ENDIF.

      IF <travel>-Status = 'C' OR ( <travel>-EndDate IS NOT INITIAL AND <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).
        <result>-%update               = if_abap_behv=>fc-o-disabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <result>-%update               = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <travel>-BeginDate IS NOT INITIAL AND <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).
        <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineDuration.

    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE ENTITY Travel FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( keys ) RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-Duration = <travel>-EndDate - <travel>-BeginDate.
    ENDLOOP.
    MODIFY ENTITIES OF Z02_R_Travel IN LOCAL MODE ENTITY Travel UPDATE FIELDS ( Duration ) WITH CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.

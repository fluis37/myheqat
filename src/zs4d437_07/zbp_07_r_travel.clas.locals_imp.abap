CLASS lhc_Z07_R_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
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

  METHOD validateDescription.
    READ ENTITIES OF Z07_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
      ENDIF.
      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-Description = if_abap_behv=>mk-on )
                        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF Z07_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel. APPEND VALUE #( %tky = <travel>-%tky
        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
        %element-CustomerId = if_abap_behv=>mk-on )
        TO reported-travel.
      ELSE.
        SELECT SINGLE FROM /dmo/i_customer
        FIELDS CustomerID
        WHERE CustomerID = @<travel>-CustomerId
        INTO @DATA(dummy).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <travel>-%tky )
          TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>customer_not_exist
                                                     customerid = <travel>-CustomerId )
                          %element-CustomerId = if_abap_behv=>mk-on )
                          TO reported-travel.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateBeginDate.
    READ ENTITIES OF Z07_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( BeginDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels). LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty ) %element-BeginDate = if_abap_behv=>mk-on )
        TO reported-travel. ELSEIF <travel>-begindate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>begin_date_past ) %element-Begindate = if_abap_behv=>mk-on )
        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDateSequence.
    READ ENTITIES OF Z07_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>dates_wrong_sequence ) %element = VALUE #( BeginDate = if_abap_behv=>mk-on EndDate = if_abap_behv=>mk-on ) )
        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    READ ENTITIES OF Z07_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( EndDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels). LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty ) %element-EndDate = if_abap_behv=>mk-on )
        TO reported-travel.
      ELSEIF <travel>-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>end_date_past ) %element-EndDate = if_abap_behv=>mk-on )
        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

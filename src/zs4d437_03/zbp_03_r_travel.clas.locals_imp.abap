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

      IF <lfs_travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <lfs_travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <lfs_travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-Description = if_abap_behv=>mk-on )
                        TO reported-travel.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS zzvalidateclass FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~zzvalidateclass.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD zzvalidateclass.

    CONSTANTS c_area TYPE string VALUE `CLASS`.

    READ ENTITIES OF z03_r_travel IN LOCAL MODE
      ENTITY item
      FIELDS ( agencyid travelid zzClassZ03 )
      WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = c_area
                     )
          TO reported-item.

      IF <item>-zzClassZ03 IS INITIAL.

        APPEND VALUE #(  %tky = <item>-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-zzClassZ03 = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                       )
            TO reported-item.
      ELSE.

        SELECT SINGLE
          FROM /lrn/437_i_classstdvh
        FIELDS classid
         WHERE classid = @<item>-zzClassZ03
          INTO @DATA(dummy).

        IF sy-subrc <> 0.

          APPEND VALUE #(  %tky = <item>-%tky )
              TO failed-item.

          APPEND VALUE #( %tky = <item>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                                       textid   = /lrn/cm_s4d437=>class_not_exist
                                       classid  = <item>-zzClassZ03
                                     )
                          %element-zzClassZ03 = if_abap_behv=>mk-on
                          %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                         )
          TO reported-item.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z03_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z03_R_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item>)
    WHERE %control-zzClassZ03 = if_abap_behv=>mk-on.

      UPDATE z03_tritem
      SET zzclassz03 = @<item>-zzClassZ03
      WHERE item_uuid = @<item>-ItemUuid.

    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>)
    WHERE %control-ItemUuid = if_abap_behv=>mk-on.

      UPDATE z03_tritem
      SET zzclassz03 = @<item_c>-zzClassZ03
      WHERE item_uuid = @<item_c>-ItemUuid.

    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

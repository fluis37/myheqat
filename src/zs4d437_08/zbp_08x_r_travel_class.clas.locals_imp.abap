CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS ZZvalidateClass FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~ZZvalidateClass.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD ZZvalidateClass.
    CONSTANTS c_area TYPE string VALUE `CLASS`.

    READ ENTITIES OF Z08_R_TRAVEL IN LOCAL MODE
      ENTITY item
      FIELDS ( agencyid travelid zzclassz08 )
      WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = c_area
                     )
          TO reported-item.

      IF <item>-zzclassz08 IS INITIAL.

        APPEND VALUE #(  %tky = <item>-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-zzclassz08 = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                       )
            TO reported-item.
      ELSE.

        SELECT SINGLE
          FROM /lrn/437_i_classstdvh
        FIELDS classid
         WHERE classid = @<item>-zzclassz08
          INTO @DATA(dummy).

        IF sy-subrc <> 0.

          APPEND VALUE #(  %tky = <item>-%tky )
              TO failed-item.

          APPEND VALUE #( %tky = <item>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                                       textid   = /lrn/cm_s4d437=>class_not_exist
                                       classid  = <item>-zzclassz08
                                     )
                          %element-zzclassz08 = if_abap_behv=>mk-on
                          %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                         )
          TO reported-item.

        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z08_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z08_R_TRAVEL IMPLEMENTATION.

  METHOD save_modified.
    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item>)
    WHERE %control-ZZClassZ08 = if_abap_behv=>mk-on.
      UPDATE z08_tritem
      SET zzclassz08 = @<item>-ZZClassZ08
      WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.

    LOOP AT create-item ASSIGNING <item>
    WHERE %control-ZZClassZ08 = if_abap_behv=>mk-on.
      UPDATE z08_tritem
      SET zzclassz08 = @<item>-ZZClassZ08
      WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.

*   Autre façon de faire
*    DATA(items) = update-item. APPEND LINES OF create-item TO items.
*    LOOP AT items ASSIGNING FIELD-SYMBOL(<item2>)
*    WHERE %control-ZZClassZ08 = if_abap_behv=>mk-on.
*      UPDATE z08_tritem
*      SET zzclassz08 = @<item2>-ZZClassZ08
*      WHERE item_uuid = @<item2>-ItemUuid.
*    ENDLOOP.

  ENDMETHOD.

* Autre façon de faire



  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

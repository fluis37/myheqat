CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS ZZvalidateClass FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~ZZvalidateClass.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD ZZvalidateClass.

    CONSTANTS c_area TYPE string VALUE `CLASS`.

    READ ENTITIES OF z02_r_travel IN LOCAL MODE
      ENTITY item
      FIELDS ( AgencyId TravelId ZZClassZ02 )
      WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = c_area
                     )
          TO reported-item.

      IF <item>-ZZClassZ02 IS INITIAL.
        APPEND VALUE #(  %tky = <item>-%tky )
            TO failed-item.

        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                                     /lrn/cm_s4d437=>field_empty
                                   )
                        %element-ZZClassZ02 = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> )
                       )
            TO reported-item.
      ELSE.
        SELECT SINGLE
          FROM /lrn/437_i_classstdvh
        FIELDS classid
         WHERE classid = @<item>-ZZClassZ02
          INTO @DATA(dummy).

        IF sy-subrc <> 0.
          APPEND VALUE #(  %tky = <item>-%tky )
              TO failed-item.
          APPEND VALUE #( %tky = <item>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                                       textid   = /lrn/cm_s4d437=>class_not_exist
                                       classid  = <item>-ZZClassZ02
                                     )
                          %element-ZZClassZ02 = if_abap_behv=>mk-on
                          %state_area = c_area
                          %path-travel = CORRESPONDING #( <item> )
                         )
          TO reported-item.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z02_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z02_R_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item>) WHERE %control-ZZClassZ02 = if_abap_behv=>mk-on.
      UPDATE z02_tritem
         SET zzclassz02 = @<item>-ZZClassZ02
       WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.
    LOOP AT create-item ASSIGNING <item> WHERE %control-ZZClassZ02 = if_abap_behv=>mk-on.
        UPDATE z02_tritem
           SET zzclassz02 = @<item>-ZZClassZ02
         WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

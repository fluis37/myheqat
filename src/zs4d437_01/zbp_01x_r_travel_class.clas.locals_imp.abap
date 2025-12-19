CLASS lsc_Z01_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z01_R_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item>)
                    WHERE %control-ZZClassZ01 = if_abap_behv=>mk-on.

        UPDATE z01_tritem
            SET zzclassz01 = @<item>-ZZClassZ01
            WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.

    LOOP AT create-item ASSIGNING <item>
                    WHERE %control-ZZClassZ01 = if_abap_behv=>mk-on.

        UPDATE z01_tritem
            SET zzclassz01 = @<item>-ZZClassZ01
            WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

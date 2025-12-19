CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS ZZvalidateClass FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~ZZvalidateClass.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD ZZvalidateClass.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lsc_z07x_r_travel_class DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z07x_r_travel_class IMPLEMENTATION.

  METHOD save_modified.
    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item>)
    WHERE %control-ZZClassZ07 = if_abap_behv=>mk-on.
      UPDATE z07_tritem
      SET zzclassz07 = @<item>-ZZClassZ07
      WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.

    LOOP AT create-item ASSIGNING <item>
    WHERE %control-ZZClassZ07 = if_abap_behv=>mk-on.
      UPDATE z07_tritem
      SET zzclassz07 = @<item>-ZZClassZ07
      WHERE item_uuid = @<item>-ItemUuid.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS zcl_05_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070005'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '0004180'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_05_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    READ ENTITY Z05_R_Travel ALL FIELDS WITH VALUE #( ( TravelID = c_travel_id AgencyId = c_agency_id ) )
    RESULT DATA(travels) FAILED DATA(failed).
    IF failed IS NOT INITIAL.
      out->write( 'Voyage non trouvé' ).
      RETURN.
    ELSE.
      MODIFY ENTITIES OF Z05_R_Travel ENTITY Travel
      UPDATE FIELDS ( Description )
      WITH VALUE #( (   TravelID = c_travel_id
                        AgencyId = c_agency_id
                        Description = 'new description 11h35' ) )
      FAILED DATA(failedModif).
      IF failedModif IS INITIAL.
        COMMIT ENTITIES.
        out->write( 'Update success' ).
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_09_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070009'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '0004314'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_09_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF z09_r_travel
    ENTITY travel
    ALL FIELDS WITH
    VALUE #( ( AgencyId = c_agency_id
               TravelID = c_travel_id ) )
               RESULT DATA(travels)
               FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( `Error retrieving tha travel` ).
    ELSE.
      MODIFY ENTITIES OF z09_r_travel
      ENTITY travel
      UPDATE FIELDS ( Description )
      WITH VALUE #(  (  AgencyId = c_agency_id
                        TravelId = c_travel_id
                        Description = 'My new description 4' ) )
                        FAILED failed.
      IF failed IS INITIAL.
        COMMIT ENTITIES.
        out->write( `Description successfully updated` ).
      ELSE.
        ROLLBACK ENTITIES.
        out->write( `Error updating the description` ).
      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

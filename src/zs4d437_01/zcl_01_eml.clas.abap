CLASS zcl_01_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070001'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004343'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_01_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF Z01_R_Travel
        ENTITY Travel
         ALL FIELDS WITH
          VALUE #( ( AgencyId = c_agency_id
            TravelId = c_travel_id ) )
          RESULT DATA(travels)
          FAILED DATA(failed).

    IF failed IS NOT INITIAL.
        out->write( `Error retrieving the travel` ).
    ELSE.
        MODIFY ENTITIES OF Z01_R_Travel
            ENTITY Travel
            UPDATE FIELDS ( Description )
            WITH VALUE #( ( AgencyId = c_agency_id
            TravelId = c_travel_id
            Description = `My new Description` ) )
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

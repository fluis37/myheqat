CLASS zcl_08_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070008'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004303'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_08_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    READ ENTITIES OF Z08_R_Travel
        ENTITY Travel ALL FIELDS WITH
            VALUE #( ( AgencyId = c_agency_id
            TravelId = c_travel_id ) )
            RESULT DATA(travels)
            FAILED DATA(failed).

    IF failed IS NOT INITIAL.
        out->write( `Error retrieving the travel` ).
    ELSE.
        out->write( travels[ 1 ] ).
        MODIFY ENTITIES OF Z08_R_Travel
            ENTITY Travel UPDATE FIELDS ( Description ) WITH
                VALUE #( ( agencyid = c_agency_id
                            travelid = c_travel_id
                            Description = 'my new description 2' ) )
                            FAILED failed.
        IF failed IS NOT INITIAL.
            out->write( `Error updating the travel` ).
        ELSE.
            COMMIT ENTITIES RESPONSE OF Z08_R_Travel
            FAILED DATA(failed_commit).
            IF failed_commit IS NOT INITIAL.
                ROLLBACK ENTITIES.
                out->write( `Error on commit` ).
            ELSE.
                COMMIT ENTITIES.
                out->write( `Travel succesfully updated` ).
            ENDIF.
        ENDIF.
    ENDIF.


  ENDMETHOD.
ENDCLASS.

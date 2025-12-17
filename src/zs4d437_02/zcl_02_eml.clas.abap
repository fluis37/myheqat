CLASS zcl_02_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070002'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004333'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_02_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF Z02_R_Travel ENTITY Travel ALL FIELDS WITH VALUE #( ( AgencyId = c_agency_id TravelId = c_travel_id ) )
        RESULT DATA(travels)
        FAILED DATA(failed).
    IF failed IS NOT INITIAL.
      out->write( `Error retrieving the travel` ).
    else.
      modify entities of z02_r_travel entity travel
        update fields ( Description )
        with value #(  ( AgencyId = c_agency_id
                         TravelId = c_travel_id
                         Description = 'My new Description' ) )
        failed failed.
      if failed is initial.
        commit entities.
        out->write( `Description successfully updated` ).
      else.
        rollback entities.
        out->write( `Error updating the description` ).
      endif.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

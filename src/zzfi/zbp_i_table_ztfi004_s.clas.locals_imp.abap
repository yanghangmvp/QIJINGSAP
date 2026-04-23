CLASS lhc_zi_table_ztfi004_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS:
      co_entity               TYPE abp_entity_name VALUE `ZI_TABLE_ZTFI004_S`,
      co_transport_object     TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZZTFI004`,
      co_authorization_entity TYPE abp_entity_name VALUE `ZI_TABLE_ZTFI004`.

  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ztfi004all
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION ztfi004all~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ztfi004all
        RESULT result.
ENDCLASS.

CLASS lhc_zi_table_ztfi004_s IMPLEMENTATION.
  METHOD get_instance_features.
*    mbc_cp_api=>rap_bc_api( )->get_instance_features(
*      transport_object   = co_transport_object
*      entity             = co_entity
*      keys               = REF #( keys )
*      requested_features = REF #( requested_features )
*      result             = REF #( result )
*      failed             = REF #( failed )
*      reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
*    mbc_cp_api=>rap_bc_api( )->select_transport_action(
*      entity   = co_entity
*      keys     = REF #( keys )
*      result   = REF #( result )
*      mapped   = REF #( mapped )
*      failed   = REF #( failed )
*      reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
*    mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*      entity                   = co_authorization_entity
*      requested_authorizations = REF #( requested_authorizations )
*      result                   = REF #( result )
*      reported                 = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lsc_zi_table_ztfi004_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_table_ztfi004_s IMPLEMENTATION.
  METHOD save_modified.
*    mbc_cp_api=>rap_bc_api( )->record_changes(
*      transport_object = lhc_zi_table_ztfi004_s=>co_transport_object
*      entity           = lhc_zi_table_ztfi004_s=>co_entity
*      create           = REF #( create )
*      update           = REF #( update )
*      delete           = REF #( delete )
*      reported         = REF #( reported ) ).
*    mbc_cp_api=>rap_bc_api( )->update_last_changed_date_time(
*      maintenance_object = 'ZZTFI004'
*      entity             = lhc_zi_table_ztfi004_s=>co_authorization_entity
*      create             = REF #( create )
*      update             = REF #( update )
*      delete             = REF #( delete )
*      reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_zi_table_ztfi004 DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS:
      co_entity TYPE sxco_cds_object_name VALUE `ZI_TABLE_ZTFI004`.

  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ztfi004
        RESULT result,
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys_ztfi004all FOR ztfi004all~validatetransportrequest
          keys_ztfi004    FOR ztfi004~validatetransportrequest.
ENDCLASS.

CLASS lhc_zi_table_ztfi004 IMPLEMENTATION.
  METHOD get_global_features.
*    mbc_cp_api=>rap_bc_api( )->get_global_features(
*      transport_object   = lhc_zi_table_ztfi004_s=>co_transport_object
*      entity             = co_entity
*      requested_features = REF #( requested_features )
*      result             = REF #( result )
*      reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD validatetransportrequest.
*    mbc_cp_api=>rap_bc_api( )->validate_transport_request(
*      transport_object = lhc_zi_table_ztfi004_s=>co_transport_object
*      entity           = lhc_zi_table_ztfi004_s=>co_entity
*      validation_keys  = VALUE #( ( REF #( keys_ztfi004all ) )
*                                  ( REF #( keys_ztfi004 ) ) )
*      failed           = REF #( failed )
*      reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.

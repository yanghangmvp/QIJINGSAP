CLASS lhc_zi_config_ztfi001_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS:
      co_entity               TYPE abp_entity_name VALUE `ZI_CONFIG_ZTFI001_S`,
      co_transport_object     TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZZTFI001`,
      co_authorization_entity TYPE abp_entity_name VALUE `ZI_CONFIG_ZTFI001`.

  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR ztfi001all
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ztfi001all
        RESULT result,
      edit FOR MODIFY
        IMPORTING
          keys FOR ACTION ztfi001all~edit.
ENDCLASS.

CLASS lhc_zi_config_ztfi001_s IMPLEMENTATION.
  METHOD get_instance_features.
*  mbc_cp_api=>rap_bc_api( )->get_instance_features(
*    transport_object   = co_transport_object
*    entity             = co_entity
*    keys               = REF #( keys )
*    requested_features = REF #( requested_features )
*    result             = REF #( result )
*    failed             = REF #( failed )
*    reported           = REF #( reported ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
*  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*    entity                   = co_authorization_entity
*    requested_authorizations = REF #( requested_authorizations )
*    result                   = REF #( result )
*    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD edit.
*  mbc_cp_api=>rap_bc_api( )->get_default_transport_request(
*    transport_object = co_transport_object
*    entity           = co_entity
*    keys             = REF #( keys )
*    mapped           = REF #( mapped )
*    failed           = REF #( failed )
*    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lsc_zi_config_ztfi001_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_config_ztfi001_s IMPLEMENTATION.
  METHOD save_modified.
*  mbc_cp_api=>rap_bc_api( )->record_changes(
*    transport_object = lhc_ZI_CONFIG_Ztfi001_S=>co_transport_object
*    entity           = lhc_ZI_CONFIG_Ztfi001_S=>co_entity
*    create           = REF #( create )
*    update           = REF #( update )
*    delete           = REF #( delete )
*    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_zi_config_ztfi001 DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CONSTANTS:
      co_entity TYPE sxco_cds_object_name VALUE `ZI_CONFIG_ZTFI001`.

  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR ztfi001
        RESULT result.

ENDCLASS.

CLASS lhc_zi_config_ztfi001 IMPLEMENTATION.
  METHOD get_global_features.
*    mbc_cp_api=>rap_bc_api( )->get_global_features(
*      transport_object   = lhc_zi_config_ztfi001_s=>co_transport_object
*      entity             = co_entity
*      requested_features = REF #( requested_features )
*      result             = REF #( result )
*      reported           = REF #( reported ) ).
  ENDMETHOD.

ENDCLASS.

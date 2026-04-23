CLASS LHC_ZTFI011ALL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_CONFIG_ZTFI011_S`,
      CO_TRANSPORT_OBJECT TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZZTFI011`,
      CO_AUTHORIZATION_ENTITY TYPE abp_entity_name VALUE `ZI_CONFIG_ZTFI011`.

  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR Ztfi011All
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Ztfi011All
        RESULT result.
ENDCLASS.

CLASS LHC_ZTFI011ALL IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
*  mbc_cp_api=>rap_bc_api( )->get_instance_features(
*    transport_object   = co_transport_object
*    entity             = co_entity
*    keys               = REF #( keys )
*    requested_features = REF #( requested_features )
*    result             = REF #( result )
*    failed             = REF #( failed )
*    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
*  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*    entity                   = co_authorization_entity
*    requested_authorizations = REF #( requested_authorizations )
*    result                   = REF #( result )
*    reported                 = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZTFI011ALL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZTFI011ALL IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
*  mbc_cp_api=>rap_bc_api( )->update_last_changed_date_time(
*    maintenance_object = 'ZZTFI011'
*    entity             = lhc_Ztfi011All=>co_authorization_entity
*    create             = REF #( create )
*    update             = REF #( update )
*    delete             = REF #( delete )
*    reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZTFI011 DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_CONFIG_ZTFI011`.

  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR Ztfi011
        RESULT result,
      DEPRECATE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztfi011~Deprecate
        RESULT result,
      INVALIDATE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztfi011~Invalidate
        RESULT result,
      COPY FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztfi011~Copy,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Ztfi011
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR Ztfi011
        RESULT result.
ENDCLASS.

CLASS LHC_ZTFI011 IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
*  mbc_cp_api=>rap_bc_api( )->get_global_features(
*    transport_object   = lhc_Ztfi011All=>co_transport_object
*    entity             = co_entity
*    requested_features = REF #( requested_features )
*    result             = REF #( result )
*    reported           = REF #( reported ) ).
  ENDMETHOD.
  METHOD DEPRECATE.
*  mbc_cp_api=>rap_bc_api( )->deprecate_entity(
*    entity   = co_entity
*    keys     = REF #( keys )
*    result   = REF #( result )
*    mapped   = REF #( mapped )
*    failed   = REF #( failed )
*    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD INVALIDATE.
*  mbc_cp_api=>rap_bc_api( )->invalidate_entity(
*    entity   = co_entity
*    keys     = REF #( keys )
*    result   = REF #( result )
*    mapped   = REF #( mapped )
*    failed   = REF #( failed )
*    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD COPY.
*  mbc_cp_api=>rap_bc_api( )->copy_by_association(
*    entity   = co_entity
*    keys     = REF #( keys )
*    mapped   = REF #( mapped )
*    failed   = REF #( failed )
*    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
*  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*    entity                   = lhc_Ztfi011All=>co_authorization_entity
*    requested_authorizations = REF #( requested_authorizations )
*    result                   = REF #( result )
*    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
*  mbc_cp_api=>rap_bc_api( )->get_action_features(
*    entity             = co_entity
*    keys               = REF #( keys )
*    requested_features = REF #( requested_features )
*    result             = REF #( result )
*    failed             = REF #( failed )
*    reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.

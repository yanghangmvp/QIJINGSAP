CLASS LHC_ZTMM002ALL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_TABLE_ZTMM002_S`,
      CO_TRANSPORT_OBJECT TYPE mbc_cp_api=>indiv_transaction_obj_name VALUE `ZZTMM002`,
      CO_AUTHORIZATION_ENTITY TYPE abp_entity_name VALUE `ZI_TABLE_ZTMM002`.

  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR Ztmm002All
        RESULT result,
      SELECTCUSTOMIZINGTRANSPTREQ FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztmm002All~SelectCustomizingTransptReq
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Ztmm002All
        RESULT result,
      EDIT FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztmm002All~edit.
ENDCLASS.

CLASS LHC_ZTMM002ALL IMPLEMENTATION.
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
  METHOD SELECTCUSTOMIZINGTRANSPTREQ.
*  mbc_cp_api=>rap_bc_api( )->select_transport_action(
*    entity   = co_entity
*    keys     = REF #( keys )
*    result   = REF #( result )
*    mapped   = REF #( mapped )
*    failed   = REF #( failed )
*    reported = REF #( reported ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
*  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*    entity                   = co_authorization_entity
*    requested_authorizations = REF #( requested_authorizations )
*    result                   = REF #( result )
*    reported                 = REF #( reported ) ).
  ENDMETHOD.
  METHOD EDIT.
*  mbc_cp_api=>rap_bc_api( )->get_default_transport_request(
*    transport_object = co_transport_object
*    entity           = co_entity
*    keys             = REF #( keys )
*    mapped           = REF #( mapped )
*    failed           = REF #( failed )
*    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZTMM002ALL DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZTMM002ALL IMPLEMENTATION.
  METHOD SAVE_MODIFIED.
*  mbc_cp_api=>rap_bc_api( )->record_changes(
*    transport_object = lhc_Ztmm002All=>co_transport_object
*    entity           = lhc_Ztmm002All=>co_entity
*    create           = REF #( create )
*    update           = REF #( update )
*    delete           = REF #( delete )
*    reported         = REF #( reported ) ).
*  mbc_cp_api=>rap_bc_api( )->update_last_changed_date_time(
*    maintenance_object = 'ZZTMM002'
*    entity             = lhc_Ztmm002All=>co_authorization_entity
*    create             = REF #( create )
*    update             = REF #( update )
*    delete             = REF #( delete )
*    reported           = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZTMM002 DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PUBLIC SECTION.
    CONSTANTS:
      CO_ENTITY TYPE abp_entity_name VALUE `ZI_TABLE_ZTMM002`.

  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR Ztmm002
        RESULT result,
      DEPRECATE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztmm002~Deprecate
        RESULT result,
      INVALIDATE FOR MODIFY
        IMPORTING
          KEYS FOR ACTION Ztmm002~Invalidate
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Ztmm002
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR Ztmm002
        RESULT result,
      VALIDATETRANSPORTREQUEST FOR VALIDATE ON SAVE
        IMPORTING
          KEYS_ZTMM002ALL FOR Ztmm002All~ValidateTransportRequest
          KEYS_ZTMM002 FOR Ztmm002~ValidateTransportRequest.
ENDCLASS.

CLASS LHC_ZTMM002 IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
*  mbc_cp_api=>rap_bc_api( )->get_global_features(
*    transport_object   = lhc_Ztmm002All=>co_transport_object
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
  METHOD GET_GLOBAL_AUTHORIZATIONS.
*  mbc_cp_api=>rap_bc_api( )->get_global_authorizations(
*    entity                   = lhc_Ztmm002All=>co_authorization_entity
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
  METHOD VALIDATETRANSPORTREQUEST.
*  mbc_cp_api=>rap_bc_api( )->validate_transport_request(
*    transport_object = lhc_Ztmm002All=>co_transport_object
*    entity           = lhc_Ztmm002All=>co_entity
*    validation_keys  = VALUE #( ( REF #( keys_Ztmm002All ) )
*                                ( REF #( keys_Ztmm002 ) ) )
*    failed           = REF #( failed )
*    reported         = REF #( reported ) ).
  ENDMETHOD.
ENDCLASS.

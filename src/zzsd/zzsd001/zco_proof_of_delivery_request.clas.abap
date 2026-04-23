class ZCO_PROOF_OF_DELIVERY_REQUEST definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods PROOF_OF_DELIVERY_REQUEST_IN
    importing
      !INPUT type ZPROOF_OF_DELIVERY_REQUEST
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCO_PROOF_OF_DELIVERY_REQUEST IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCO_PROOF_OF_DELIVERY_REQUEST'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method PROOF_OF_DELIVERY_REQUEST_IN.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'PROOF_OF_DELIVERY_REQUEST_IN'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.

CLASS zzcl_dyr_test002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_dyr_test002 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    TYPES: BEGIN OF ty_entry,
             result  TYPE string,
             message TYPE string,
           END OF ty_entry.

    TYPES: BEGIN OF ty_msg,
             entry TYPE ty_entry,
           END OF ty_msg.

    DATA: ls_msg TYPE ty_msg.

    DATA: lv_xml   TYPE string,
          lv_cdata TYPE string.


    lv_xml = |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">| &&
             |<soapenv:Header xmlns:boi="http://localhost/BOI/"/>| &&
             |<soapenv:Body xmlns:boi="http://localhost/BOI/">| &&
             |<boi:InvokeResponse>| &&
             |<boi:InvokeResult>true</boi:InvokeResult>| &&
             |<boi:result>| &&
             |<![CDATA[<msg><Entry><result>S</result><message>成功</message></Entry></msg>]]>| &&
             |</boi:result>| &&
             |</boi:InvokeResponse>| &&
             |</soapenv:Body>| &&
             |</soapenv:Envelope>|.

    FIND FIRST OCCURRENCE OF REGEX |<!\\[CDATA\\[([^]]*)\\]\\]>|
      IN lv_xml
      SUBMATCHES lv_cdata.

*      lv_cdata = |<?xml version="1.0" encoding="UTF-8"?>| && lv_cdata.
*
    TRY.
        CALL TRANSFORMATION zzt_xml
  SOURCE XML lv_cdata
  RESULT msg = ls_msg.
      CATCH cx_root INTO DATA(oref).
        DATA(text) = oref->get_text( ).
    ENDTRY.



  ENDMETHOD.
ENDCLASS.

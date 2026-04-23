CLASS zzcl_xml_builder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS build_xml
      IMPORTING
        it_table      TYPE STANDARD TABLE
        iv_uuid       TYPE string
        iv_numb       TYPE string
        iv_root_name  TYPE string DEFAULT 'Interface'
        iv_item_name  TYPE string DEFAULT 'Entry'
        iv_from       TYPE string DEFAULT 'sap_farwon@2026'
      RETURNING
        VALUE(rv_xml) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS escape_xml
      IMPORTING iv_value        TYPE string
      RETURNING VALUE(rv_value) TYPE string.

ENDCLASS.



CLASS zzcl_xml_builder IMPLEMENTATION.


  METHOD build_xml.

    DATA: lv_xml  TYPE string VALUE '',
          lv_line TYPE string.

    FIELD-SYMBOLS: <ls_line>  TYPE any,
                   <lv_field> TYPE any.

    DATA: lo_descr TYPE REF TO cl_abap_structdescr,
          lt_comp  TYPE cl_abap_structdescr=>component_table,
          ls_comp  LIKE LINE OF lt_comp.

    DATA: lv_datum TYPE string.

    " XML头
    lv_xml = '<?xml version="1.0" encoding="UTF-8"?>'.

    " Root开始
    lv_xml &&= |<{ iv_root_name }>|.

    LOOP AT it_table ASSIGNING <ls_line>.

      lv_xml &&= |<{ iv_item_name }|.

      " 获取结构描述
      lo_descr ?= cl_abap_typedescr=>describe_by_data( <ls_line> ).
*      lt_comp = lo_descr->components.
      lt_comp = lo_descr->get_components( ).

      LOOP AT lt_comp INTO ls_comp.

        ASSIGN COMPONENT ls_comp-name OF STRUCTURE <ls_line> TO <lv_field>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        DATA(lv_name)  = to_upper( ls_comp-name ).
*        DATA(lv_value) = escape_xml( |{ <lv_field> }| ).
        DATA(lv_value) = |{ <lv_field> }|.

        AT FIRST.
          IF lv_name = 'DOFLAG'.
            lv_xml &&= | DoFlag='{ lv_value }'>|.
          ENDIF.
        ENDAT.

        lv_xml &&= |<{ lv_name }>{ lv_value }</{ lv_name }>|.

      ENDLOOP.

      lv_xml &&= |</{ iv_item_name }>|.

    ENDLOOP.

    lv_xml &&= |</{ iv_root_name }>|.

    lv_datum = |{ sy-datlo+0(4) }/{ sy-datlo+4(2) }/{ sy-datlo+6(2) } { sy-timlo+0(2) }:{ sy-timlo+2(2) }:{ sy-timlo+4(2) }|.

    lv_xml = |<?xml version='1.0' encoding='UTF-8'?>| &&
             |<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">| &&
             |<soap-env:Header>| &&
             |<extraParams>| &&
             |<esbCode></esbCode>| &&
             |<COMP>107</COMP>| &&
             |<transactionType></transactionType>| &&
             |<requesttime>{ lv_datum }</requesttime>| &&
             |<requestsequence></requestsequence>| &&
             |</extraParams>| &&
             |</soap-env:Header>| &&
             |<soap-env:Body>| &&
             |<n0:Invoke xmlns:n0="http://localhost/BOI/" xmlns:prx="urn:sap.com:proxy:ED1:/1SAI/TASF269687A1093569DEFEE:752">| &&
             |<n0:from>{ iv_from }</n0:from>| &&
             |<n0:token>{ iv_uuid }</n0:token>| &&
             |<n0:funcName>{ iv_numb }</n0:funcName>| &&
             |<n0:parameters>| &&
             |<![CDATA[{ lv_xml }| &&
             |]]></n0:parameters></n0:Invoke></soap-env:Body></soap-env:Envelope>|.

    rv_xml = lv_xml.

  ENDMETHOD.


  METHOD escape_xml.

    rv_value = iv_value.

    REPLACE ALL OCCURRENCES OF '&' IN rv_value WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN rv_value WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN rv_value WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '"' IN rv_value WITH '&quot;'.
    REPLACE ALL OCCURRENCES OF |'| IN rv_value WITH '&apos;'.

  ENDMETHOD.
ENDCLASS.

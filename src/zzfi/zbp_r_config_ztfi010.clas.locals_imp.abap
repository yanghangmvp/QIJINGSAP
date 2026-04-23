CLASS lhc_zr_config_ztfi010 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ztfi010
        RESULT result,

      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR ztfi010 RESULT result,

      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE ztfi010,

      setdefaultvalues FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ztfi010~setdefaultvalues,

      zsave FOR MODIFY
        IMPORTING keys FOR ACTION ztfi010~zsave RESULT result.


ENDCLASS.

CLASS lhc_zr_config_ztfi010 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(entity).
      IF entity-uuid IS INITIAL.
        TRY.
            entity-uuid = cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
      ENDIF.

      APPEND CORRESPONDING #( entity ) TO mapped-ztfi010.
    ENDLOOP.
  ENDMETHOD.


  METHOD setdefaultvalues.
    " 读取需要设置默认值的数据
    READ ENTITIES OF zr_config_ztfi010 IN LOCAL MODE
      ENTITY ztfi010
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fi010).

    " 设置默认值
    MODIFY ENTITIES OF zr_config_ztfi010 IN LOCAL MODE
      ENTITY ztfi010
      UPDATE FIELDS (
                      originalreferencedocumenttype
                      businesstransactiontype
                    )
      WITH VALUE #( FOR ls_fi010 IN lt_fi010 (
        %tky          = ls_fi010-%tky
        originalreferencedocumenttype = 'BKPFF'
        businesstransactiontype = 'RFBU'
      ) ).

  ENDMETHOD.


  METHOD zsave.
    DATA: lr_uuid TYPE RANGE OF zztfi010-uuid.
    DATA: lt_ztfi001 TYPE TABLE OF zztfi001,
          ls_ztfi001 TYPE zztfi001,
          lt_ztfi002 TYPE TABLE OF zztfi002,
          ls_ztfi002 TYPE zztfi002.

    " 读取选中的数据
    READ ENTITIES OF zr_config_ztfi010 IN LOCAL MODE
      ENTITY ztfi010
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ztfi010).

    LOOP AT lt_ztfi010 INTO DATA(ls_ztfi010).
      CLEAR: ls_ztfi001, ls_ztfi002.
      ls_ztfi001 = CORRESPONDING #( ls_ztfi010 ).
      ls_ztfi002 = CORRESPONDING #( ls_ztfi010 ).

      APPEND ls_ztfi001 TO lt_ztfi001.
      APPEND ls_ztfi002 TO lt_ztfi002.

      APPEND VALUE #( %tky = ls_ztfi010-%tky
                      %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = '已创建!' )
                      ) TO reported-ztfi010.

      MODIFY ENTITIES OF zr_config_ztfi010 IN LOCAL MODE
        ENTITY ztfi010
        UPDATE FIELDS ( zflag )
        WITH VALUE #( ( %tky = ls_ztfi010-%tky
                        zflag = abap_true
                      ) ).

    ENDLOOP.

    SORT lt_ztfi001 BY reference1indocumentheader.
    SORT lt_ztfi002 BY reference1indocumentheader accountingdocumentitem.

    DELETE ADJACENT DUPLICATES FROM lt_ztfi001 COMPARING reference1indocumentheader.
    DELETE ADJACENT DUPLICATES FROM lt_ztfi002 COMPARING reference1indocumentheader accountingdocumentitem.

    TRY .
        MODIFY zztfi001 FROM TABLE @lt_ztfi001.
        MODIFY zztfi002 FROM TABLE @lt_ztfi002.

        READ ENTITIES OF zr_config_ztfi010 IN LOCAL MODE
          ENTITY ztfi010
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_ztfi010_res).

        result = VALUE #( FOR ls_ztfi010_res IN lt_ztfi010_res ( %tky   = ls_ztfi010_res-%tky
                                             %param = ls_ztfi010_res ) ).

      CATCH cx_sy_open_sql_db INTO DATA(lo_error).
        DATA(ls_error) = lo_error->get_text( ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

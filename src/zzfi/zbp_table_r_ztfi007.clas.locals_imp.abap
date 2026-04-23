CLASS lsc_zr_table_ztfi007 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_table_ztfi007 IMPLEMENTATION.

  METHOD save_modified.

    IF create-fi007 IS NOT INITIAL.



    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_table_ztfi007 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR fi007
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR fi007 RESULT result.

    METHODS zhklx FOR MODIFY
      IMPORTING keys FOR ACTION fi007~zhklx RESULT result.

    METHODS zlsbs FOR MODIFY
      IMPORTING keys FOR ACTION fi007~zlsbs RESULT result.
    METHODS setdeafultvalue FOR DETERMINE ON SAVE
      IMPORTING keys FOR fi007~setdeafultvalue.
ENDCLASS.

CLASS lhc_zr_table_ztfi007 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA: lv_abled_hklx TYPE abp_behv_op_ctrl.
    DATA: lv_abled_delete TYPE abp_behv_op_ctrl.
    DATA: lv_abled_lsbs TYPE abp_behv_op_ctrl.
    DATA: lv_disabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-disabled.
    DATA: lv_enabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.



    READ ENTITIES OF zr_table_ztfi007 IN LOCAL MODE
    ENTITY fi007
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    LOOP AT results INTO DATA(ls_result).

      IF ls_result-status = '10' OR ls_result-status = '25' OR ls_result-status = '35'.
        lv_abled_hklx = lv_enabled.
        lv_abled_delete = lv_enabled.
      ELSE.
        lv_abled_hklx = lv_disabled.
        lv_abled_delete = lv_disabled.
      ENDIF.

      IF ls_result-accountingdocument IS NOT INITIAL.
        lv_abled_delete = lv_disabled.
      ENDIF.

      IF ls_result-status = '10' OR ls_result-status = '25'.
        lv_abled_lsbs = lv_enabled.
      ELSE.
        lv_abled_lsbs = lv_disabled.
      ENDIF.


      APPEND VALUE #( %tky = ls_result-%tky
                      %action-zhklx = lv_abled_hklx
                      %action-edit = lv_abled_hklx
                      %action-zlsbs = lv_abled_lsbs
                      %delete = lv_abled_delete
                       )
      TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD zhklx.


    READ ENTITIES OF zr_table_ztfi007 IN LOCAL MODE
    ENTITY fi007
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    READ TABLE keys INTO DATA(key) INDEX 1.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).

      IF key-%param-receivablestype IS NOT INITIAL.
        <fs_result>-receivablestype = key-%param-receivablestype.
      ENDIF.
      IF key-%param-accounttype IS NOT INITIAL.
        <fs_result>-accounttype = key-%param-accounttype.
      ENDIF.

      IF key-%param-merchantnumber IS NOT INITIAL.
        <fs_result>-merchantnumber =  key-%param-merchantnumber.
        SELECT SINGLE customername
        FROM i_customer WITH PRIVILEGED ACCESS
        WHERE customer = @<fs_result>-merchantnumber
        INTO @<fs_result>-merchantname.
      ENDIF.
      IF  key-%param-storecode IS NOT INITIAL.
        <fs_result>-storecode =  key-%param-storecode.
        SELECT SINGLE customername
          FROM i_customer WITH PRIVILEGED ACCESS
          WHERE customer = @<fs_result>-storecode
          INTO @<fs_result>-storename.
      ENDIF.

    ENDLOOP.

    "更新数据库
    MODIFY ENTITIES OF zr_table_ztfi007 IN LOCAL MODE
     ENTITY fi007
     UPDATE FIELDS ( receivablestype accounttype  merchantnumber merchantname storecode storename )
       WITH VALUE #(  FOR ls_result IN lt_result
                        (  %key     = ls_result-%key
                        receivablestype   = ls_result-receivablestype
                        accounttype   = ls_result-accounttype
                        merchantnumber   = ls_result-merchantnumber
                        merchantname   = ls_result-merchantname
                        storecode   = ls_result-storecode
                        storename   = ls_result-storename
                         ) )
     REPORTED DATA(lt_reported)
     FAILED DATA(lt_failed).


    "更新前台界面
    result = VALUE #( FOR demo IN lt_result (  %key     = demo-%key
                                               %param   = demo
                                           ) ).


  ENDMETHOD.

  METHOD zlsbs.

    DATA:lt_zztfi001 TYPE TABLE OF zztfi001,
         ls_zztfi001 TYPE zztfi001,
         lt_zztfi002 TYPE TABLE OF zztfi002,
         ls_zztfi002 TYPE zztfi002.

    READ ENTITIES OF zr_table_ztfi007 IN LOCAL MODE
      ENTITY fi007
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).


    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).


      IF <fs_result>-receivablestype IS INITIAL.
        APPEND VALUE #( %tky = <fs_result>-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-warning
                          text       = '请维护回款类型'
                         )
                      )  TO reported-fi007.

        CONTINUE.
      ENDIF.
      IF <fs_result>-accounttype IS INITIAL.
        APPEND VALUE #( %tky = <fs_result>-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-warning
                          text       = '请维护账户类型'
                         )
                      )  TO reported-fi007.

        CONTINUE.
      ENDIF.
      IF <fs_result>-merchantnumber IS INITIAL OR <fs_result>-storecode IS INITIAL.
        APPEND VALUE #( %tky = <fs_result>-%tky
                       %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-warning
                       text       = '请维护客户编码和门店编码'
                      )
                   )  TO reported-fi007.

        CONTINUE.
      ENDIF.
      IF <fs_result>-status = '10' OR <fs_result>-status = '25' OR <fs_result>-status = '35'.

      ELSE.
        APPEND VALUE #( %tky = <fs_result>-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-warning
                          text       = '当前状态不可辨识'
                         )
                      )  TO reported-fi007.
        CONTINUE.
      ENDIF.


      CLEAR: ls_zztfi001.
      ls_zztfi001-reference1indocumentheader = <fs_result>-recordid.
      ls_zztfi001-datasource = 'A03'.
      ls_zztfi001-originalreferencedocumenttype = 'BKPFF'.
      ls_zztfi001-businesstransactiontype = 'RFBU'.
      ls_zztfi001-companycode = <fs_result>-unitno.
      ls_zztfi001-accountingdocumenttype = 'DA'.
      ls_zztfi001-postingdate = <fs_result>-recorddate.
      ls_zztfi001-documentdate = <fs_result>-recorddate.
      ls_zztfi001-transactioncurrency = <fs_result>-currencyno.

      ls_zztfi001-accountingdocumentheadertext = <fs_result>-merchantnumber && <fs_result>-receivablestypetxt && '回款'.
      APPEND ls_zztfi001 TO lt_zztfi001.

      CLEAR:ls_zztfi002.
      ls_zztfi002-reference1indocumentheader = <fs_result>-recordid.
      ls_zztfi002-datasource = 'A03'.
      ls_zztfi002-accountingdocumentitem = 1.

      SELECT SINGLE glaccount
        FROM i_housebankaccountlinkage WITH PRIVILEGED ACCESS
       WHERE companycode = @<fs_result>-unitno
         AND bankaccount && referenceinfo = @<fs_result>-accountno
        INTO @ls_zztfi002-glaccount.

      ls_zztfi002-amountintransactioncurrency = <fs_result>-amount.
      IF <fs_result>-amount > 0.
        ls_zztfi002-debitcreditcode = 'S'.
      ELSE.
        ls_zztfi002-debitcreditcode = 'H'.
        ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
      ENDIF.
      ls_zztfi002-documentitemtext = <fs_result>-hostid.
      ls_zztfi002-reasoncode = 'A01'.
      ls_zztfi002-assignmentreference = <fs_result>-receivablestype && <fs_result>-receivablestypetxt.
      ls_zztfi002-profitcenter = 'PGH00'.
      APPEND ls_zztfi002 TO lt_zztfi002.

      CLEAR:ls_zztfi002.
      ls_zztfi002-reference1indocumentheader = <fs_result>-recordid.
      ls_zztfi002-datasource = 'A03'.
      ls_zztfi002-accountingdocumentitem = 2.

      SELECT SINGLE reconciliationaccount
        FROM i_customercompany WITH PRIVILEGED ACCESS
       WHERE companycode = @<fs_result>-unitno
         AND customer = @<fs_result>-merchantnumber
        INTO @ls_zztfi002-glaccount.

      ls_zztfi002-amountintransactioncurrency = <fs_result>-amount.
      IF <fs_result>-amount > 0.
        ls_zztfi002-debitcreditcode = 'H'.
        ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
      ELSE.
        ls_zztfi002-debitcreditcode = 'S'.
      ENDIF.
      ls_zztfi002-documentitemtext = <fs_result>-hostid.
      ls_zztfi002-assignmentreference = <fs_result>-receivablestype && <fs_result>-receivablestypetxt.
      ls_zztfi002-profitcenter = 'PGH00'.
      ls_zztfi002-customer = <fs_result>-merchantnumber.
      CASE <fs_result>-receivablestype .
        WHEN 'A1'.
          ls_zztfi002-altvrecnclnaccts = '2204010102'.
        WHEN 'A2'.
          ls_zztfi002-altvrecnclnaccts = '2204010301'.
        WHEN 'A3'.
          ls_zztfi002-altvrecnclnaccts = '2204010701'.
        WHEN 'A4'.
          ls_zztfi002-altvrecnclnaccts = '2204010401'.
      ENDCASE.


      SELECT SINGLE tradingpartner
          FROM i_customer WITH PRIVILEGED ACCESS
         WHERE customer = @<fs_result>-merchantnumber
          INTO @ls_zztfi002-tradingpartner.
      APPEND ls_zztfi002 TO lt_zztfi002.

      <fs_result>-status = '20'.

      UPDATE zztfi007a SET  status = @<fs_result>-status
       WHERE recordid = @<fs_result>-recordid
         AND unitno = @<fs_result>-unitno.

      APPEND VALUE #( %tky = <fs_result>-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-success
                        text       = '预制成功'
                       )
                    )  TO reported-fi007.
    ENDLOOP.

    MODIFY zztfi001 FROM TABLE @lt_zztfi001.
    MODIFY zztfi002 FROM TABLE @lt_zztfi002.


    "更新前台界面
    result = VALUE #( FOR demo IN lt_result (  %key     = demo-%key
                                               %param   = demo
                                           ) ).

  ENDMETHOD.

  METHOD setdeafultvalue.

*&---获取UI 界面实体数据内容
    READ ENTITIES OF zr_table_ztfi007 IN LOCAL MODE
      ENTITY fi007
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_fi007).

      IF ls_fi007-merchantnumber IS  INITIAL AND ls_fi007-opaccountno IS NOT INITIAL.

        SELECT SINGLE b~customer,b~customername
          FROM i_businesspartnerbank WITH PRIVILEGED ACCESS AS a
          JOIN i_customer WITH PRIVILEGED ACCESS AS b ON a~businesspartner = b~customer
         WHERE a~bankaccount && a~bankaccountreferencetext = @ls_fi007-opaccountno
          INTO @DATA(ls_data).
        IF sy-subrc = 0.
          "更新数据库
          MODIFY ENTITIES OF zr_table_ztfi007 IN LOCAL MODE
           ENTITY fi007
           UPDATE FIELDS ( merchantnumber merchantname )
             WITH VALUE #( (   %key   = ls_fi007-%key
                             merchantnumber   = ls_data-customer
                             merchantname     = ls_data-customername
                          ) )
           REPORTED DATA(lt_reported)
           FAILED DATA(lt_failed).

        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

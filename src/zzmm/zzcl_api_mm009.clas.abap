CLASS zzcl_api_mm009 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:BEGIN OF ty_scale,
            conditionscaleline           TYPE string,
            conditionscalequantity       TYPE string,
            conditionscalequantityunit   TYPE string,
            conditionscaleamount         TYPE string,
            conditionscaleamountcurrency TYPE string,
          END OF ty_scale,
          BEGIN OF tty_scale,
            results TYPE TABLE OF ty_scale WITH EMPTY KEY,
          END OF tty_scale,
          BEGIN OF ty_condition,
            conditioncurrency       TYPE string,
            conditionrateamount     TYPE string,
            conditionquantity       TYPE string,
            conditionquantityunit   TYPE string,
            conditionisdeleted      TYPE abap_bool,
            to_pricingcndnrecdscale TYPE tty_scale,
          END OF ty_condition,
          BEGIN OF ty_validity,
            conditionvaliditystartdate   TYPE string,
            conditionvalidityenddate     TYPE string,
            conditiontype                TYPE string,
            purchasingorganization       TYPE string,
            purchasinginforecordcategory TYPE string,
            purchasinginforecord         TYPE string,
            supplier                     TYPE string,
            materialgroup                TYPE string,
            material                     TYPE string,
            plant                        TYPE string,
            to_purinforecdprcgcndn       TYPE ty_condition,
          END OF ty_validity,
          BEGIN OF tty_validity,
            results TYPE TABLE OF ty_validity WITH EMPTY KEY,
          END OF tty_validity,
          BEGIN OF ty_orgplantdata,
            purchasinginforecordcategory   TYPE string,
            purchasingorganization         TYPE string,
            plant                          TYPE string,
            createdbyuser                  TYPE string,
            creationdate                   TYPE string,
            ismarkedfordeletion            TYPE string,
            purchasinggroup                TYPE string,
            currency                       TYPE string,
            minimumpurchaseorderquantity   TYPE string,
            standardpurchaseorderquantity  TYPE string,
            materialplanneddeliverydurn    TYPE string,
            overdelivtolrtdlmtratioinpct   TYPE string,
            underdelivtolrtdlmtratioinpct  TYPE string,
            unlimitedoverdeliveryisallowed TYPE string,
            lastreferencingpurchaseorder   TYPE string,
            lastreferencingpurorderitem    TYPE string,
            material                       TYPE string,
            supplier                       TYPE string,
            materialgroup                  TYPE string,
            purgdocorderquantityunit       TYPE string,
            netpriceamount                 TYPE string,
            materialpriceunitqty           TYPE string,
            purchaseorderpriceunit         TYPE string,
            pricevalidityenddate           TYPE string,
            shippinginstruction            TYPE string,
            invoiceisgoodsreceiptbased     TYPE string,
            taxcode                        TYPE string,
            incotermsclassification        TYPE string,
            incotermstransferlocation      TYPE string,
            incotermslocation1             TYPE string,
            maximumorderquantity           TYPE string,
            isrelevantforautomsrcg         TYPE string,
            supplierquotation              TYPE string,
            supplierquotationdate          TYPE string,
            minremainingshelflife          TYPE string,
            isevaluatedrcptsettlmtallowed  TYPE string,
            ispurorderallwdforinbdeliv     TYPE string,
            isorderacknrqd                 TYPE string,
            isretmatlauthznrqdbysupplier   TYPE string,
            iscashdiscountgranted          TYPE string,
            materialconditiongroup         TYPE string,
            purchasingdocumentdate         TYPE string,
            shelflifeexpirationdateperiod  TYPE string,
            isendofpurposeblocked          TYPE string,
            supplierconfirmationcontrolkey TYPE string,
            pricingdatecontrol             TYPE string,
            timedependenttaxvalidfromdate  TYPE string,
            taxcountry                     TYPE string,
            materialroundingprofile        TYPE string,
            matlmstrtxtisnotrlvtforpoitm   TYPE string,
            productionversion              TYPE string,
            purgdocexportimportprocedure   TYPE string,
            orderpriceunittoorderunitnmrtr TYPE string,
            ordpriceunittoorderunitdnmntr  TYPE string,
            to_purinforecdprcgcndnvalidity TYPE tty_validity,
          END OF ty_orgplantdata,
          BEGIN OF tty_orgplantdata,
            results TYPE TABLE OF ty_orgplantdata WITH EMPTY KEY,
          END OF tty_orgplantdata,
          BEGIN OF ty_record,
            purchasinginforecord           TYPE string,
            supplier                       TYPE lifnr,
            material                       TYPE matnr,
            materialgroup                  TYPE string,
            creationdate                   TYPE string,
            isdeleted                      TYPE string,
            purchasinginforecorddesc       TYPE string,
            purginforecnonstockitmsortterm TYPE string,
            purgdocorderquantityunit       TYPE string,
            orderitemqtytobaseqtynmrtr     TYPE string,
            orderitemqtytobaseqtydnmntr    TYPE string,
            suppliermaterialnumber         TYPE string,
            supplierrespsalespersonname    TYPE string,
            supplierphonenumber            TYPE string,
            baseunit                       TYPE string,
            suppliermaterialgroup          TYPE string,
            priorsupplier                  TYPE string,
            availabilitystartdate          TYPE string,
            availabilityenddate            TYPE string,
            varblpurordunitisactive        TYPE string,
            manufacturer                   TYPE string,
            isregularsupplier              TYPE string,
            suppliersubrange               TYPE string,
            nodaysreminder1                TYPE string,
            nodaysreminder2                TYPE string,
            nodaysreminder3                TYPE string,
            productpurchasepointsqty       TYPE string,
            productpurchasepointsqtyunit   TYPE string,
            suppliersubrangesortnumber     TYPE string,
            lastchangedatetime             TYPE string,
            isendofpurposeblocked          TYPE string,
            isretmatlauthznrqdbysupplier   TYPE string,
            iscashdiscountgranted          TYPE string,
            materialconditiongroup         TYPE string,
            purchasingdocumentdate         TYPE string,
            shelflifeexpirationdateperiod  TYPE string,
            to_purginforecdorgplantdata    TYPE tty_orgplantdata,
          END OF ty_record.

    DATA:gv_purchasinginforecord TYPE i_purchasinginforecordapi01-purchasinginforecord.
    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gs_tmp TYPE zzs_mmi009_in.
    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.
    DATA:gv_srv    TYPE string,
         gv_entity TYPE string.
    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_mmi009_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    "创建
    METHODS create
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "更新
    METHODS update
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "更新---一般数据
    METHODS update_basic
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "更新---采购组织
    METHODS update_orgplant
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "更新---有效期
    METHODS update_validity
      EXPORTING
        o_resp TYPE zzs_rest_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM009 IMPLEMENTATION.


  METHOD inbound.

    gs_tmp = i_req-req.

    "传入数据处理
    gs_tmp-basic-supplier = |{ gs_tmp-basic-supplier ALPHA = IN }|.
    CONDENSE gs_tmp-basic-orderitemqtytobaseqtydnmntr NO-GAPS.
    CONDENSE gs_tmp-basic-orderitemqtytobaseqtynmrtr NO-GAPS.
    "采购信息记录信息类别 0 标准 /2 寄售/3 分包合同/P 管道/1 可记帐
    IF gs_tmp-orgplant-purchasinginforecordcategory IS INITIAL.
      gs_tmp-orgplant-purchasinginforecordcategory = '0'.
    ENDIF.

    "判断新建还是更改
    SELECT SINGLE a~purchasinginforecord
      FROM i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS a
      JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS b
                                   ON a~purchasinginforecord = b~purchasinginforecord
     WHERE a~material = @gs_tmp-basic-material
       AND a~supplier = @gs_tmp-basic-supplier
       AND b~purchasinginforecordcategory = @gs_tmp-orgplant-purchasinginforecordcategory
       AND b~purchasingorganization = @gs_tmp-orgplant-purchasingorganization
       AND b~plant = @gs_tmp-orgplant-plant
      INTO @gv_purchasinginforecord.
    IF sy-subrc <> 0.

      "创建采购信息记录
      me->create( IMPORTING o_resp = o_resp ).

    ELSE.

      "更新采购信息记录
      me->update( IMPORTING o_resp = o_resp ).

    ENDIF.

    o_resp-sapnum = gv_purchasinginforecord.
  ENDMETHOD.


  METHOD create  .

    DATA:lv_json TYPE string.
    DATA:ls_create TYPE ty_record.

    "信息记录------------一般数据
    MOVE-CORRESPONDING gs_tmp-basic TO ls_create.
    "信息记录------------采购组织数据
    APPEND INITIAL LINE TO ls_create-to_purginforecdorgplantdata-results ASSIGNING FIELD-SYMBOL(<fs_orgplant>).
    MOVE-CORRESPONDING gs_tmp-orgplant TO <fs_orgplant>.
    <fs_orgplant>-timedependenttaxvalidfromdate = zzcl_comm_tool=>date2iso( gs_tmp-orgplant-timedependenttaxvalidfromdate ).

    "信息记录------------条件有效期
    DATA(ls_condition) = gs_tmp-orgplant-condition.
    APPEND INITIAL LINE TO <fs_orgplant>-to_purinforecdprcgcndnvalidity-results ASSIGNING FIELD-SYMBOL(<fs_validity>).
    "有效期开始
    <fs_validity>-conditionvaliditystartdate = zzcl_comm_tool=>date2iso( ls_condition-conditionvaliditystartdate ).
    "有效期截止
    <fs_validity>-conditionvalidityenddate = zzcl_comm_tool=>date2iso( ls_condition-conditionvalidityenddate ).
    "价格类型
    <fs_validity>-conditiontype = ls_condition-conditiontype.

    "信息记录------------条件价格
    MOVE-CORRESPONDING gs_tmp-orgplant-condition TO <fs_validity>-to_purinforecdprcgcndn.

    "信息记录------------等级价格
    IF ls_condition-scales IS NOT INITIAL.
      LOOP AT ls_condition-scales INTO DATA(ls_scales).
        APPEND INITIAL LINE TO <fs_validity>-to_purinforecdprcgcndn-to_pricingcndnrecdscale-results ASSIGNING FIELD-SYMBOL(<fs_scale>).
        MOVE-CORRESPONDING ls_scales TO <fs_scale>.
      ENDLOOP.
    ENDIF.



*&---接口HTTP 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    gv_srv = 'API_INFORECORD_PROCESS_SRV'.
    gv_entity = 'A_PurchasingInfoRecord'.
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/{  gv_srv }/{ gv_entity }| && |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize( data          = ls_create
                                                compress      = abap_true
                                                name_mappings = gt_mapping ).

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '201'.
      TYPES:BEGIN OF ty_heads,
              purchasinginforecord TYPE string,
            END OF ty_heads,
            BEGIN OF ty_ress,
              d TYPE ty_heads,
            END OF  ty_ress.
      DATA:ls_ress TYPE ty_ress.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_ress ).

      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.
      gv_purchasinginforecord = ls_ress-d-purchasinginforecord.
    ELSE.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails).
        o_resp-msgtx = o_resp-msgtx  && ls_errordetails-message.
      ENDLOOP.
      IF o_resp-msgtx  IS INITIAL.
        o_resp-msgtx  = ls_rese-error-message-value.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD update.

    "更新采购信息记录---一般数据
    me->update_basic( IMPORTING o_resp = o_resp ).
    CHECK o_resp-msgty <> 'E'.

    "更新采购信息记录---采购组织
    me->update_orgplant( IMPORTING o_resp = o_resp ).
    CHECK o_resp-msgty <> 'E'.

    "更新采购信息记录---条件价格
    me->update_validity( IMPORTING o_resp = o_resp ).
    CHECK o_resp-msgty <> 'E'.

  ENDMETHOD.


  METHOD update_basic.

    DATA:lv_json TYPE string.
    DATA:ls_basic TYPE ty_record.

    "信息记录------------一般数据
    MOVE-CORRESPONDING gs_tmp-basic TO ls_basic.

*&---接口HTTP 链接调用
    gv_srv = 'API_INFORECORD_PROCESS_SRV'.
    gv_entity = 'A_PurchasingInfoRecord'.
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'PATCH'.
    gs_http_req-etag = '*'.
    gs_http_req-url = |/{ gv_srv }/{ gv_entity }(| &&
                      |PurchasingInfoRecord='{ gv_purchasinginforecord }')| &&
                      |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body =  /ui2/cl_json=>serialize(
              data          = ls_basic
              compress      = abap_true
              name_mappings = gt_mapping
              ).

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '204'.
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.
    ELSE.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails).
        o_resp-msgtx = o_resp-msgtx  && ls_errordetails-message.
      ENDLOOP.
      IF o_resp-msgtx  IS INITIAL.
        o_resp-msgtx  = ls_rese-error-message-value.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD update_orgplant.

    DATA:lv_json TYPE string.
    DATA:ls_orgplant TYPE ty_orgplantdata.
    "信息记录------------采购组织
    MOVE-CORRESPONDING gs_tmp-orgplant TO ls_orgplant.
    ls_orgplant-timedependenttaxvalidfromdate = zzcl_comm_tool=>date2iso( ls_orgplant-timedependenttaxvalidfromdate ).
*&---接口HTTP 链接调用
    gv_srv = 'API_INFORECORD_PROCESS_SRV'.
    gv_entity = 'A_PurgInfoRecdOrgPlantData'.
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'PATCH'.
    gs_http_req-etag = '*'.
    gs_http_req-url = |/{ gv_srv }/{ gv_entity }(| &&
                      |PurchasingInfoRecord='{ gv_purchasinginforecord }',| &&
                      |PurchasingInfoRecordCategory='{ gs_tmp-orgplant-purchasinginforecordcategory }',| &&
                      |PurchasingOrganization='{ gs_tmp-orgplant-purchasingorganization }',| &&
                      |Plant='{ gs_tmp-orgplant-plant }')| &&
                      |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body =  /ui2/cl_json=>serialize(
              data          = ls_orgplant
              compress      = abap_true
              name_mappings = gt_mapping
              ).
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '204'.
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.
    ELSE.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = ls_rese-error-message-value .
    ENDIF.


  ENDMETHOD.


  METHOD update_validity.

    DATA:lv_json TYPE string.
    DATA:ls_validity TYPE ty_validity.

    DATA(ls_condition) = gs_tmp-orgplant-condition.
    MOVE-CORRESPONDING gs_tmp-orgplant TO ls_validity.
    MOVE-CORRESPONDING gs_tmp-basic TO ls_validity.
    "信息记录------------条件有效期
    "有效期开始
    ls_validity-conditionvaliditystartdate = zzcl_comm_tool=>date2iso( ls_condition-conditionvaliditystartdate ).
    "有效期截止
    ls_validity-conditionvalidityenddate = zzcl_comm_tool=>date2iso( ls_condition-conditionvalidityenddate ).
    "价格类型
    ls_validity-conditiontype = ls_condition-conditiontype.

    "信息记录------------条件价格
    MOVE-CORRESPONDING gs_tmp-orgplant-condition TO ls_validity-to_purinforecdprcgcndn.

    "信息记录------------等级价格
    IF ls_condition-scales IS NOT INITIAL.
      LOOP AT ls_condition-scales INTO DATA(ls_scales).
        APPEND INITIAL LINE TO ls_validity-to_purinforecdprcgcndn-to_pricingcndnrecdscale-results ASSIGNING FIELD-SYMBOL(<fs_scale>).
        MOVE-CORRESPONDING ls_scales TO <fs_scale>.
      ENDLOOP.
    ENDIF.
*&---接口HTTP 链接调用
    gv_srv = 'API_INFORECORD_PROCESS_SRV'.
    gv_entity = 'A_PurgInfoRecdOrgPlantData'.
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/{ gv_srv }/{ gv_entity }(| &&
                            |PurchasingInfoRecord='{ gv_purchasinginforecord }',| &&
                            |PurchasingInfoRecordCategory='{ gs_tmp-orgplant-purchasinginforecordcategory }',| &&
                            |PurchasingOrganization='{ gs_tmp-orgplant-purchasingorganization }',| &&
                            |Plant='{ gs_tmp-orgplant-plant }')| &&
                            |/to_PurInfoRecdPrcgCndnValidity| &&
                            |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_validity
              compress      = abap_true
              name_mappings = gt_mapping
              ).
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '201'.
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.
    ELSE.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = ls_rese-error-message-value .

    ENDIF.


  ENDMETHOD.


  METHOD constructor.

    gt_mapping = VALUE #(
        ( abap = 'PurchasingInfoRecord'                      json = 'PurchasingInfoRecord'   )
        ( abap = 'Supplier'                                  json = 'Supplier'               )
        ( abap = 'Material'                                  json = 'Material' )
        ( abap = 'MaterialGroup'                             json = 'MaterialGroup' )
        ( abap = 'CreationDate'                              json = 'CreationDate' )
        ( abap = 'IsDeleted'                                 json = 'IsDeleted' )
        ( abap = 'PurchasingInfoRecordDesc'                  json = 'PurchasingInfoRecordDesc' )
        ( abap = 'PurgInfoRecNonStockItmSortTerm'            json = 'PurgInfoRecNonStockItmSortTerm' )
        ( abap = 'PurgDocOrderQuantityUnit'                  json = 'PurgDocOrderQuantityUnit' )
        ( abap = 'OrderItemQtyToBaseQtyNmrtr'                json = 'OrderItemQtyToBaseQtyNmrtr' )
        ( abap = 'OrderItemQtyToBaseQtyDnmntr'               json = 'OrderItemQtyToBaseQtyDnmntr' )
        ( abap = 'SupplierMaterialNumber'                    json = 'SupplierMaterialNumber' )
        ( abap = 'SupplierRespSalesPersonName'               json = 'SupplierRespSalesPersonName' )
        ( abap = 'SupplierPhoneNumber'                       json = 'SupplierPhoneNumber' )
        ( abap = 'BaseUnit'                                  json = 'BaseUnit' )
        ( abap = 'SupplierMaterialGroup'                     json = 'SupplierMaterialGroup' )
        ( abap = 'TimeDependentTaxValidFromDate'             json = 'TimeDependentTaxValidFromDate' )
        ( abap = 'PriorSupplier'                             json = 'PriorSupplier' )
        ( abap = 'AvailabilityStartDate'                     json = 'AvailabilityStartDate' )
        ( abap = 'AvailabilityEndDate'                       json = 'AvailabilityEndDate' )
        ( abap = 'VarblPurOrdUnitIsActive'                   json = 'VarblPurOrdUnitIsActive' )
        ( abap = 'Manufacturer'                              json = 'Manufacturer' )
        ( abap = 'IsRegularSupplier'                         json = 'IsRegularSupplier' )
        ( abap = 'SupplierSubrange'                          json = 'SupplierSubrange' )
        ( abap = 'NoDaysReminder1'                           json = 'NoDaysReminder1' )
        ( abap = 'NoDaysReminder2'                           json = 'NoDaysReminder2' )
        ( abap = 'NoDaysReminder3'                           json = 'NoDaysReminder3' )
        ( abap = 'ProductPurchasePointsQty'                  json = 'ProductPurchasePointsQty' )
        ( abap = 'ProductPurchasePointsQtyUnit'              json = 'ProductPurchasePointsQtyUnit' )
        ( abap = 'SupplierSubrangeSortNumber'                json = 'SupplierSubrangeSortNumber' )
        ( abap = 'LastChangeDateTime'                        json = 'LastChangeDateTime' )
        ( abap = 'IsEndOfPurposeBlocked'                     json = 'IsEndOfPurposeBlocked' )
        ( abap = 'PurchasingOrganization'                    json = 'PurchasingOrganization' )
        ( abap = 'PurchasingInfoRecordCategory'              json = 'PurchasingInfoRecordCategory' )
        ( abap = 'Plant'                                     json = 'Plant' )
        ( abap = 'CreatedByUser'                             json = 'CreatedByUser' )
        ( abap = 'IsMarkedForDeletion'                       json = 'IsMarkedForDeletion' )
        ( abap = 'PurchasingGroup'                           json = 'PurchasingGroup' )
        ( abap = 'Currency'                                  json = 'Currency' )
        ( abap = 'MinimumPurchaseOrderQuantity'              json = 'MinimumPurchaseOrderQuantity' )
        ( abap = 'StandardPurchaseOrderQuantity'             json = 'StandardPurchaseOrderQuantity' )
        ( abap = 'MaterialPlannedDeliveryDurn'               json = 'MaterialPlannedDeliveryDurn' )
        ( abap = 'OverdelivTolrtdLmtRatioInPct'              json = 'OverdelivTolrtdLmtRatioInPct' )
        ( abap = 'UnderdelivTolrtdLmtRatioInPct'             json = 'UnderdelivTolrtdLmtRatioInPct' )
        ( abap = 'UnlimitedOverdeliveryIsAllowed'            json = 'UnlimitedOverdeliveryIsAllowed' )
        ( abap = 'LastReferencingPurchaseOrder'              json = 'LastReferencingPurchaseOrder' )
        ( abap = 'LastReferencingPurOrderItem'               json = 'LastReferencingPurOrderItem' )
        ( abap = 'NetPriceQuantityUnit'                      json = 'NetPriceQuantityUnit' )
        ( abap = 'NetPriceAmount'                            json = 'NetPriceAmount' )
        ( abap = 'MaterialPriceUnitQty'                      json = 'MaterialPriceUnitQty' )
        ( abap = 'PurchaseOrderPriceUnit'                    json = 'PurchaseOrderPriceUnit' )
        ( abap = 'PriceValidityEndDate'                      json = 'PriceValidityEndDate' )
        ( abap = 'InvoiceIsGoodsReceiptBased'                json = 'InvoiceIsGoodsReceiptBased' )
        ( abap = 'TaxCode'                                   json = 'TaxCode' )
        ( abap = 'IncotermsClassification'                   json = 'IncotermsClassification' )
        ( abap = 'IncotermsTransferLocation'                 json = 'IncotermsTransferLocation' )
        ( abap = 'IncotermsLocation1'                        json = 'IncotermsLocation1' )
        ( abap = 'MaximumOrderQuantity'                      json = 'MaximumOrderQuantity' )
        ( abap = 'IsRelevantForAutomSrcg'                    json = 'IsRelevantForAutomSrcg' )
        ( abap = 'SupplierQuotation'                         json = 'SupplierQuotation' )
        ( abap = 'SupplierQuotationDate'                     json = 'SupplierQuotationDate' )
        ( abap = 'MinRemainingShelfLife'                     json = 'MinRemainingShelfLife' )
        ( abap = 'IsEvaluatedRcptSettlmtAllowed'             json = 'IsEvaluatedRcptSettlmtAllowed' )
        ( abap = 'IsPurOrderAllwdForInbDeliv'                json = 'IsPurOrderAllwdForInbDeliv' )
        ( abap = 'IsOrderAcknRqd'                            json = 'IsOrderAcknRqd' )
        ( abap = 'IsRetMatlAuthznRqdBySupplier'              json = 'IsRetMatlAuthznRqdBySupplier' )
        ( abap = 'IsCashDiscountGranted'                     json = 'IsCashDiscountGranted' )
        ( abap = 'MaterialConditionGroup'                    json = 'MaterialConditionGroup' )
        ( abap = 'PurchasingDocumentDate'                    json = 'PurchasingDocumentDate' )
        ( abap = 'ShelfLifeExpirationDatePeriod'             json = 'ShelfLifeExpirationDatePeriod' )
        ( abap = 'SupplierConfirmationControlKey'            json = 'SupplierConfirmationControlKey' )
        ( abap = 'PricingDateControl'                        json = 'PricingDateControl' )
        ( abap = 'MaterialRoundingProfile'                   json = 'MaterialRoundingProfile' )
        ( abap = 'MatlMstrTxtIsNotRlvtForPOItm'              json = 'MatlMstrTxtIsNotRlvtForPOItm' )
        ( abap = 'ProductionVersion'                         json = 'ProductionVersion' )
        ( abap = 'PurgDocExportImportProcedure'              json = 'PurgDocExportImportProcedure' )
        ( abap = 'ConditionRecord'                           json = 'ConditionRecord' )
        ( abap = 'ConditionValidityEndDate'                  json = 'ConditionValidityEndDate' )
        ( abap = 'ConditionValidityStartDate'                json = 'ConditionValidityStartDate' )
        ( abap = 'ConditionApplication'                      json = 'ConditionApplication' )
        ( abap = 'ConditionType'                             json = 'ConditionType' )
        ( abap = 'ConditionRateAmount'                       json = 'ConditionRateAmount' )
        ( abap = 'ConditionCurrency'                         json = 'ConditionCurrency' )
        ( abap = 'ConditionSequentialNumber'                 json = 'ConditionSequentialNumber' )
        ( abap = 'CreationTextID'                            json = 'CreationTextID' )
        ( abap = 'PricingScaleType'                          json = 'PricingScaleType' )
        ( abap = 'PricingScaleBasis'                         json = 'PricingScaleBasis' )
        ( abap = 'ConditionScaleQuantity'                    json = 'ConditionScaleQuantity' )
        ( abap = 'ConditionScaleQuantityUnit'                json = 'ConditionScaleQuantityUnit' )
        ( abap = 'ConditionScaleAmount'                      json = 'ConditionScaleAmount' )
        ( abap = 'ConditionScaleAmountCurrency'              json = 'ConditionScaleAmountCurrency' )
        ( abap = 'ConditionCalcutationType'                  json = 'ConditionCalcutationType' )
        ( abap = 'ConditionRateValue'                        json = 'ConditionRateValue' )
        ( abap = 'ConditionRateValueUnit'                    json = 'ConditionRateValueUnit' )
        ( abap = 'ConditionQuantity'                         json = 'ConditionQuantity' )
        ( abap = 'ConditionQuantityUnit'                     json = 'ConditionQuantityUnit' )
        ( abap = 'ConditionToBaseQtyNmrtr'                   json = 'ConditionToBaseQtyNmrtr' )
        ( abap = 'ConditionToBaseQtyDnmntr'                  json = 'ConditionToBaseQtyDnmntr' )
        ( abap = 'ConditionLowerLimit'                       json = 'ConditionLowerLimit' )
        ( abap = 'ConditionUpperLimit'                       json = 'ConditionUpperLimit' )
        ( abap = 'ConditionalAlternativeCurrency'            json = 'ConditionalAlternativeCurrency' )
        ( abap = 'ConditionExclusion'                        json = 'ConditionExclusion' )
        ( abap = 'ConditionIsDeleted'                        json = 'ConditionIsDeleted' )
        ( abap = 'AdditionalValueDays'                       json = 'AdditionalValueDays' )
        ( abap = 'FixedValueDate'                            json = 'FixedValueDate' )
        ( abap = 'PaymentTerms'                              json = 'PaymentTerms' )
        ( abap = 'CndnMaxNumberofSalesOrders'                json = 'CndnMaxNumberofSalesOrders' )
        ( abap = 'MinimumConditionBasisValue'                json = 'MinimumConditionBasisValue' )
        ( abap = 'MaximumConditionBasisValue'                json = 'MaximumConditionBasisValue' )
        ( abap = 'MaximumConditionAmount'                    json = 'MaximumConditionAmount' )
        ( abap = 'IncrementalScale'                          json = 'IncrementalScale' )
        ( abap = 'PricingScaleLine'                          json = 'PricingScaleLine' )
        ( abap = 'ConditionReleaseStatus'                    json = 'ConditionReleaseStatus' )

        ( abap = 'to_PurgInfoRecdOrgPlantData'               json = 'to_PurgInfoRecdOrgPlantData' )
        ( abap = 'to_PurInfoRecdPrcgCndnValidity'            json = 'to_PurInfoRecdPrcgCndnValidity' )
        ( abap = 'to_PurInfoRecdPrcgCndn'                    json = 'to_PurInfoRecdPrcgCndn' )
        ( abap = 'to_pricingcndnrecdscale'                   json = 'to_pricingcndnrecdscale' )
        ( abap = 'results'                                   json = 'results' )

        ( abap = 'OrderPriceUnitToOrderUnitNmrtr'            json = 'OrderPriceUnitToOrderUnitNmrtr' )
        ( abap = 'OrdPriceUnitToOrderUnitDnmntr'             json = 'OrdPriceUnitToOrderUnitDnmntr' )
    ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.

  ENDMETHOD.
ENDCLASS.

CLASS zzcl_api_mm003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:BEGIN OF ty_itempurordref,
            supplierinvoiceitem            TYPE string,
            purchaseorder                  TYPE string,
            purchaseorderitem              TYPE string,
            plant                          TYPE string,
            referencedocument              TYPE string,
            referencedocumentfiscalyear    TYPE string,
            referencedocumentitem          TYPE string,
            issubsequentdebitcredit        TYPE string,
            taxcode                        TYPE string,
            taxjurisdiction                TYPE string,
            documentcurrency               TYPE string,
            supplierinvoiceitemamount      TYPE string,
            purchaseorderquantityunit      TYPE string,
            purchaseorderqtyunitsapcode    TYPE string,
            purchaseorderqtyunitisocode    TYPE string,
            quantityinpurchaseorderunit    TYPE string,
            purchaseorderpriceunit         TYPE string,
            purchaseorderpriceunitsapcode  TYPE string,
            purchaseorderpriceunitisocode  TYPE string,
            qtyinpurchaseorderpriceunit    TYPE string,
            suplrinvcdeliverycostcndntype  TYPE string,
            suplrinvcdeliverycostcndnstep  TYPE string,
            suplrinvcdeliverycostcndncount TYPE string,
            supplierinvoiceitemtext        TYPE string,
            freightsupplier                TYPE string,
            isnotcashdiscountliable        TYPE string,
            retentionamountindoccurrency   TYPE string,
            retentionpercentage            TYPE string,
            retentionduedate               TYPE string,
            suplrinvcitmisnotrlvtforrtntn  TYPE string,
            serviceentrysheet              TYPE string,
            serviceentrysheetitem          TYPE string,
            taxcountry                     TYPE string,
            isfinallyinvoiced              TYPE string,
            taxdeterminationdate           TYPE string,
            in_hsnorsaccode                TYPE string,
            in_customdutyassessablevalue   TYPE string,
          END OF ty_itempurordref.
    TYPES: BEGIN OF tty_itempurordref,
             results TYPE TABLE OF ty_itempurordref WITH EMPTY KEY,
           END OF tty_itempurordref.
    TYPES:BEGIN OF ty_invoicetax,
            taxcode                  TYPE string,
            documentcurrency         TYPE string,
            taxamount                TYPE string,
            taxbaseamountintranscrcy TYPE string,
            taxjurisdiction          TYPE string,
            taxcountry               TYPE string,
            taxdeterminationdate     TYPE string,
            taxratevaliditystartdate TYPE string,
          END OF ty_invoicetax.
    TYPES: BEGIN OF tty_invoicetax,
             results TYPE TABLE OF ty_invoicetax WITH EMPTY KEY,
           END OF tty_invoicetax.
    TYPES:BEGIN OF ty_itemglacct,
            supplierinvoiceitem        TYPE string,
            companycode                TYPE string,
            costcenter                 TYPE string,
            controllingarea            TYPE string,
            businessarea               TYPE string,
            profitcenter               TYPE string,
            functionalarea             TYPE string,
            glaccount                  TYPE string,
            salesorder                 TYPE string,
            salesorderitem             TYPE string,
            costobject                 TYPE string,
            costctractivitytype        TYPE string,
            businessprocess            TYPE string,
            wbselement                 TYPE string,
            documentcurrency           TYPE string,
            supplierinvoiceitemamount  TYPE string,
            taxcode                    TYPE string,
            personnelnumber            TYPE string,
            workitem                   TYPE string,
            debitcreditcode            TYPE string,
            taxjurisdiction            TYPE string,
            supplierinvoiceitemtext    TYPE string,
            assignmentreference        TYPE string,
            isnotcashdiscountliable    TYPE string,
            internalorder              TYPE string,
            projectnetwork             TYPE string,
            networkactivity            TYPE string,
            commitmentitem             TYPE string,
            fundscenter                TYPE string,
            taxbaseamountintranscrcy   TYPE string,
            fund                       TYPE string,
            grantid                    TYPE string,
            quantityunit               TYPE string,
            suplrinvcitmqtyunitsapcode TYPE string,
            suplrinvcitmqtyunitisocode TYPE string,
            quantity                   TYPE string,
            partnerbusinessarea        TYPE string,
            financialtransactiontype   TYPE string,
            taxcountry                 TYPE string,
            earmarkedfundsdocument     TYPE string,
            earmarkedfundsdocumentitem TYPE string,
            budgetperiod               TYPE string,
            servicedocument            TYPE string,
            servicedocumentitem        TYPE string,
            servicedocumenttype        TYPE string,
          END OF ty_itemglacct.
    TYPES: BEGIN OF tty_itemglacct,
             results TYPE TABLE OF ty_itemglacct WITH EMPTY KEY,
           END OF tty_itemglacct.

    TYPES: BEGIN OF ty_data,
             companycode                    TYPE string,
             documentdate                   TYPE string,
             postingdate                    TYPE string,
             supplierinvoiceidbyinvcgparty  TYPE string,
             invoicingparty                 TYPE string,
             documentcurrency               TYPE string,
             invoicegrossamount             TYPE string,
             unplanneddeliverycost          TYPE string,
             documentheadertext             TYPE string,
             reconciliationaccount          TYPE string,
             manualcashdiscount             TYPE string,
             paymentterms                   TYPE string,
             duecalculationbasedate         TYPE string,
             cashdiscount1percent           TYPE string,
             cashdiscount1days              TYPE string,
             cashdiscount2percent           TYPE string,
             cashdiscount2days              TYPE string,
             netpaymentdays                 TYPE string,
             paymentblockingreason          TYPE string,
             accountingdocumenttype         TYPE string,

             bpbankaccountinternalid        TYPE string,
             supplierinvoicestatus          TYPE string,
             indirectquotedexchangerate     TYPE string,
             directquotedexchangerate       TYPE string,
             statecentralbankpaymentreason  TYPE string,
             supplyingcountry               TYPE string,
             paymentmethod                  TYPE string,
             paymentmethodsupplement        TYPE string,
             paymentreference               TYPE string,
             invoicereference               TYPE string,
             invoicereferencefiscalyear     TYPE string,
             fixedcashdiscount              TYPE string,
             unplanneddeliverycosttaxcode   TYPE string,
             unplnddelivcosttaxjurisdiction TYPE string,
             unplnddeliverycosttaxcountry   TYPE string,
             assignmentreference            TYPE string,

             supplierpostinglineitemtext    TYPE string,
             taxiscalculatedautomatically   TYPE string,
             businessplace                  TYPE string,
             businesssectioncode            TYPE string,
             businessarea                   TYPE string,
             suplrinvciscapitalgoodsrelated TYPE string,
             supplierinvoiceiscreditmemo    TYPE string,
             paytslipwthrefsubscriber       TYPE string,

             paytslipwthrefcheckdigit       TYPE string,
             paytslipwthrefreference        TYPE string,
             taxdeterminationdate           TYPE string,
             taxreportingdate               TYPE string,
             taxfulfillmentdate             TYPE string,
             invoicereceiptdate             TYPE string,

             deliveryofgoodsreportingcntry  TYPE string,
             suppliervatregistration        TYPE string,
             iseutriangulardeal             TYPE string,
             suplrinvcdebitcrdtcodedelivery TYPE string,
             suplrinvcdebitcrdtcodereturns  TYPE string,
             retentionduedate               TYPE string,
             paymentreason                  TYPE string,
             housebank                      TYPE string,
             housebankaccount               TYPE string,
             alternativepayeepayer          TYPE string,
             in_gstpartner                  TYPE string,
             in_gstplaceofsupply            TYPE string,
             in_invoicereferencenumber      TYPE string,
             jrnlentrycntryspecificref1     TYPE string,
             jrnlentrycntryspecificdate1    TYPE string,
             jrnlentrycntryspecificref2     TYPE string,
             jrnlentrycntryspecificdate2    TYPE string,
             jrnlentrycntryspecificref3     TYPE string,
             jrnlentrycntryspecificdate3    TYPE string,
             jrnlentrycntryspecificref4     TYPE string,
             jrnlentrycntryspecificdate4    TYPE string,
             jrnlentrycntryspecificref5     TYPE string,
             jrnlentrycntryspecificdate5    TYPE string,
             jrnlentrycntryspecificbp1      TYPE string,
             jrnlentrycntryspecificbp2      TYPE string,
             to_suplrinvcitempurordref      TYPE tty_itempurordref,
             to_supplierinvoicetax          TYPE tty_invoicetax,
             to_supplierinvoiceitemglacct   TYPE tty_itemglacct,

           END OF ty_data.

    DATA:gv_reservation TYPE i_reservationdocumentitem-reservation.
    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gs_tmp TYPE zzs_mmi003_in.

    DATA:lv_date TYPE string.
    DATA:gv_srv    TYPE string,
         gv_entity TYPE string.
    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_mmi003_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS create
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS cancel
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm003 IMPLEMENTATION.


  METHOD inbound.
    gs_tmp = i_req-data.
    "传入数据处理
    lv_date = gs_tmp-header-documentdate.
    gs_tmp-header-documentdate = zzcl_comm_tool=>date2iso( gs_tmp-header-documentdate ).
    gs_tmp-header-postingdate = zzcl_comm_tool=>date2iso( gs_tmp-header-postingdate ).
    IF gs_tmp-header-taxdeterminationdate IS NOT INITIAL.
      gs_tmp-header-taxdeterminationdate = zzcl_comm_tool=>date2iso( gs_tmp-header-taxdeterminationdate ).
    ELSE.
      gs_tmp-header-taxdeterminationdate = gs_tmp-header-documentdate.
    ENDIF.
    IF gs_tmp-header-reversalreason IS INITIAL.
      "创建采购发票
      me->create( IMPORTING o_resp = o_resp ).
    ELSE.
      "取消采购发票
      me->cancel( IMPORTING o_resp = o_resp ).
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
         ( abap = 'CompanyCode' json = 'CompanyCode' )
         ( abap = 'DocumentDate' json = 'DocumentDate' )
         ( abap = 'PostingDate' json = 'PostingDate' )
         ( abap = 'SupplierInvoiceIDByInvcgParty' json = 'SupplierInvoiceIDByInvcgParty' )
         ( abap = 'InvoicingParty' json = 'InvoicingParty' )
         ( abap = 'DocumentCurrency' json = 'DocumentCurrency' )
         ( abap = 'InvoiceGrossAmount' json = 'InvoiceGrossAmount' )
         ( abap = 'UnplannedDeliveryCost' json = 'UnplannedDeliveryCost' )
         ( abap = 'DocumentHeaderText' json = 'DocumentHeaderText' )
         ( abap = 'ReconciliationAccount' json = 'ReconciliationAccount' )
         ( abap = 'ManualCashDiscount' json = 'ManualCashDiscount' )
         ( abap = 'PaymentTerms' json = 'PaymentTerms' )
         ( abap = 'DueCalculationBaseDate' json = 'DueCalculationBaseDate' )
         ( abap = 'CashDiscount1Percent' json = 'CashDiscount1Percent' )
         ( abap = 'CashDiscount1Days' json = 'CashDiscount1Days' )
         ( abap = 'CashDiscount2Percent' json = 'CashDiscount2Percent' )
         ( abap = 'CashDiscount2Days' json = 'CashDiscount2Days' )
         ( abap = 'NetPaymentDays' json = 'NetPaymentDays' )
         ( abap = 'PaymentBlockingReason' json = 'PaymentBlockingReason' )
         ( abap = 'AccountingDocumentType' json = 'AccountingDocumentType' )
         ( abap = 'BPBankAccountInternalID' json = 'BPBankAccountInternalID' )
         ( abap = 'SupplierInvoiceStatus' json = 'SupplierInvoiceStatus' )
         ( abap = 'IndirectQuotedExchangeRate' json = 'IndirectQuotedExchangeRate' )
         ( abap = 'DirectQuotedExchangeRate' json = 'DirectQuotedExchangeRate' )
         ( abap = 'StateCentralBankPaymentReason' json = 'StateCentralBankPaymentReason' )
         ( abap = 'SupplyingCountry' json = 'SupplyingCountry' )
         ( abap = 'PaymentMethod' json = 'PaymentMethod' )
         ( abap = 'PaymentMethodSupplement' json = 'PaymentMethodSupplement' )
         ( abap = 'PaymentReference' json = 'PaymentReference' )
         ( abap = 'InvoiceReference' json = 'InvoiceReference' )
         ( abap = 'InvoiceReferenceFiscalYear' json = 'InvoiceReferenceFiscalYear' )
         ( abap = 'FixedCashDiscount' json = 'FixedCashDiscount' )
         ( abap = 'UnplannedDeliveryCostTaxCode' json = 'UnplannedDeliveryCostTaxCode' )
         ( abap = 'UnplndDelivCostTaxJurisdiction' json = 'UnplndDelivCostTaxJurisdiction' )
         ( abap = 'UnplndDeliveryCostTaxCountry' json = 'UnplndDeliveryCostTaxCountry' )
         ( abap = 'AssignmentReference' json = 'AssignmentReference' )
         ( abap = 'SupplierPostingLineItemText' json = 'SupplierPostingLineItemText' )
         ( abap = 'TaxIsCalculatedAutomatically' json = 'TaxIsCalculatedAutomatically' )
         ( abap = 'BusinessPlace' json = 'BusinessPlace' )
         ( abap = 'BusinessSectionCode' json = 'BusinessSectionCode' )
         ( abap = 'BusinessArea' json = 'BusinessArea' )
         ( abap = 'SuplrInvcIsCapitalGoodsRelated' json = 'SuplrInvcIsCapitalGoodsRelated' )
         ( abap = 'SupplierInvoiceIsCreditMemo' json = 'SupplierInvoiceIsCreditMemo' )
         ( abap = 'PaytSlipWthRefSubscriber' json = 'PaytSlipWthRefSubscriber' )
         ( abap = 'PaytSlipWthRefCheckDigit' json = 'PaytSlipWthRefCheckDigit' )
         ( abap = 'PaytSlipWthRefReference' json = 'PaytSlipWthRefReference' )
         ( abap = 'TaxDeterminationDate' json = 'TaxDeterminationDate' )
         ( abap = 'TaxReportingDate' json = 'TaxReportingDate' )
         ( abap = 'TaxFulfillmentDate' json = 'TaxFulfillmentDate' )
         ( abap = 'InvoiceReceiptDate' json = 'InvoiceReceiptDate' )
         ( abap = 'DeliveryOfGoodsReportingCntry' json = 'DeliveryOfGoodsReportingCntry' )
         ( abap = 'SupplierVATRegistration' json = 'SupplierVATRegistration' )
         ( abap = 'IsEUTriangularDeal' json = 'IsEUTriangularDeal' )
         ( abap = 'SuplrInvcDebitCrdtCodeDelivery' json = 'SuplrInvcDebitCrdtCodeDelivery' )
         ( abap = 'SuplrInvcDebitCrdtCodeReturns' json = 'SuplrInvcDebitCrdtCodeReturns' )
         ( abap = 'RetentionDueDate' json = 'RetentionDueDate' )
         ( abap = 'PaymentReason' json = 'PaymentReason' )
         ( abap = 'HouseBank' json = 'HouseBank' )
         ( abap = 'HouseBankAccount' json = 'HouseBankAccount' )
         ( abap = 'AlternativePayeePayer' json = 'AlternativePayeePayer' )
         ( abap = 'IN_GSTPartner' json = 'IN_GSTPartner' )
         ( abap = 'IN_GSTPlaceOfSupply' json = 'IN_GSTPlaceOfSupply' )
         ( abap = 'IN_InvoiceReferenceNumber' json = 'IN_InvoiceReferenceNumber' )
         ( abap = 'JrnlEntryCntrySpecificRef1' json = 'JrnlEntryCntrySpecificRef1' )
         ( abap = 'JrnlEntryCntrySpecificDate1' json = 'JrnlEntryCntrySpecificDate1' )
         ( abap = 'JrnlEntryCntrySpecificRef2' json = 'JrnlEntryCntrySpecificRef2' )
         ( abap = 'JrnlEntryCntrySpecificDate2' json = 'JrnlEntryCntrySpecificDate2' )
         ( abap = 'JrnlEntryCntrySpecificRef3' json = 'JrnlEntryCntrySpecificRef3' )
         ( abap = 'JrnlEntryCntrySpecificDate3' json = 'JrnlEntryCntrySpecificDate3' )
         ( abap = 'JrnlEntryCntrySpecificRef4' json = 'JrnlEntryCntrySpecificRef4' )
         ( abap = 'JrnlEntryCntrySpecificDate4' json = 'JrnlEntryCntrySpecificDate4' )
         ( abap = 'JrnlEntryCntrySpecificRef5' json = 'JrnlEntryCntrySpecificRef5' )
         ( abap = 'JrnlEntryCntrySpecificDate5' json = 'JrnlEntryCntrySpecificDate5' )
         ( abap = 'JrnlEntryCntrySpecificBP1' json = 'JrnlEntryCntrySpecificBP1' )
         ( abap = 'JrnlEntryCntrySpecificBP2' json = 'JrnlEntryCntrySpecificBP2' )
         ( abap = 'TaxCode' json = 'TaxCode' )
         ( abap = 'TaxAmount' json = 'TaxAmount' )
         ( abap = 'TaxBaseAmountInTransCrcy' json = 'TaxBaseAmountInTransCrcy' )
         ( abap = 'TaxJurisdiction' json = 'TaxJurisdiction' )
         ( abap = 'TaxCountry' json = 'TaxCountry' )
         ( abap = 'TaxRateValidityStartDate' json = 'TaxRateValidityStartDate' )
         ( abap = 'SupplierInvoiceItem' json = 'SupplierInvoiceItem' )
         ( abap = 'CostCenter' json = 'CostCenter' )
         ( abap = 'ControllingArea' json = 'ControllingArea' )
         ( abap = 'ProfitCenter' json = 'ProfitCenter' )
         ( abap = 'FunctionalArea' json = 'FunctionalArea' )
         ( abap = 'GLAccount' json = 'GLAccount' )
         ( abap = 'SalesOrder' json = 'SalesOrder' )
         ( abap = 'SalesOrderItem' json = 'SalesOrderItem' )
         ( abap = 'CostObject' json = 'CostObject' )
         ( abap = 'CostCtrActivityType' json = 'CostCtrActivityType' )
         ( abap = 'BusinessProcess' json = 'BusinessProcess' )
         ( abap = 'WBSElement' json = 'WBSElement' )
         ( abap = 'SupplierInvoiceItemAmount' json = 'SupplierInvoiceItemAmount' )
         ( abap = 'PersonnelNumber' json = 'PersonnelNumber' )
         ( abap = 'WorkItem' json = 'WorkItem' )
         ( abap = 'DebitCreditCode' json = 'DebitCreditCode' )
         ( abap = 'SupplierInvoiceItemText' json = 'SupplierInvoiceItemText' )
         ( abap = 'IsNotCashDiscountLiable' json = 'IsNotCashDiscountLiable' )
         ( abap = 'InternalOrder' json = 'InternalOrder' )
         ( abap = 'ProjectNetwork' json = 'ProjectNetwork' )
         ( abap = 'NetworkActivity' json = 'NetworkActivity' )
         ( abap = 'CommitmentItem' json = 'CommitmentItem' )
         ( abap = 'FundsCenter' json = 'FundsCenter' )
         ( abap = 'Fund' json = 'Fund' )
         ( abap = 'GrantID' json = 'GrantID' )
         ( abap = 'QuantityUnit' json = 'QuantityUnit' )
         ( abap = 'SuplrInvcItmQtyUnitSAPCode' json = 'SuplrInvcItmQtyUnitSAPCode' )
         ( abap = 'SuplrInvcItmQtyUnitISOCode' json = 'SuplrInvcItmQtyUnitISOCode' )
         ( abap = 'Quantity' json = 'Quantity' )
         ( abap = 'PartnerBusinessArea' json = 'PartnerBusinessArea' )
         ( abap = 'FinancialTransactionType' json = 'FinancialTransactionType' )
         ( abap = 'EarmarkedFundsDocument' json = 'EarmarkedFundsDocument' )
         ( abap = 'EarmarkedFundsDocumentItem' json = 'EarmarkedFundsDocumentItem' )
         ( abap = 'BudgetPeriod' json = 'BudgetPeriod' )
         ( abap = 'ServiceDocument' json = 'ServiceDocument' )
         ( abap = 'ServiceDocumentItem' json = 'ServiceDocumentItem' )
         ( abap = 'ServiceDocumentType' json = 'ServiceDocumentType' )
         ( abap = 'PurchaseOrder' json = 'PurchaseOrder' )
         ( abap = 'PurchaseOrderItem' json = 'PurchaseOrderItem' )
         ( abap = 'Plant' json = 'Plant' )
         ( abap = 'ReferenceDocument' json = 'ReferenceDocument' )
         ( abap = 'ReferenceDocumentFiscalYear' json = 'ReferenceDocumentFiscalYear' )
         ( abap = 'ReferenceDocumentItem' json = 'ReferenceDocumentItem' )
         ( abap = 'IsSubsequentDebitCredit' json = 'IsSubsequentDebitCredit' )
         ( abap = 'PurchaseOrderQuantityUnit' json = 'PurchaseOrderQuantityUnit' )
         ( abap = 'PurchaseOrderQtyUnitSAPCode' json = 'PurchaseOrderQtyUnitSAPCode' )
         ( abap = 'PurchaseOrderQtyUnitISOCode' json = 'PurchaseOrderQtyUnitISOCode' )
         ( abap = 'QuantityInPurchaseOrderUnit' json = 'QuantityInPurchaseOrderUnit' )
         ( abap = 'PurchaseOrderPriceUnit' json = 'PurchaseOrderPriceUnit' )
         ( abap = 'PurchaseOrderPriceUnitSAPCode' json = 'PurchaseOrderPriceUnitSAPCode' )
         ( abap = 'PurchaseOrderPriceUnitISOCode' json = 'PurchaseOrderPriceUnitISOCode' )
         ( abap = 'QtyInPurchaseOrderPriceUnit' json = 'QtyInPurchaseOrderPriceUnit' )
         ( abap = 'SuplrInvcDeliveryCostCndnType' json = 'SuplrInvcDeliveryCostCndnType' )
         ( abap = 'SuplrInvcDeliveryCostCndnStep' json = 'SuplrInvcDeliveryCostCndnStep' )
         ( abap = 'SuplrInvcDeliveryCostCndnCount' json = 'SuplrInvcDeliveryCostCndnCount' )
         ( abap = 'FreightSupplier' json = 'FreightSupplier' )
         ( abap = 'RetentionAmountInDocCurrency' json = 'RetentionAmountInDocCurrency' )
         ( abap = 'RetentionPercentage' json = 'RetentionPercentage' )
         ( abap = 'SuplrInvcItmIsNotRlvtForRtntn' json = 'SuplrInvcItmIsNotRlvtForRtntn' )
         ( abap = 'ServiceEntrySheet' json = 'ServiceEntrySheet' )
         ( abap = 'ServiceEntrySheetItem' json = 'ServiceEntrySheetItem' )
         ( abap = 'IsFinallyInvoiced' json = 'IsFinallyInvoiced' )
         ( abap = 'IN_HSNOrSACCode' json = 'IN_HSNOrSACCode' )
         ( abap = 'IN_CustomDutyAssessableValue' json = 'IN_CustomDutyAssessableValue' )
         ( abap = 'to_SuplrInvcItemPurOrdRef' json = 'to_SuplrInvcItemPurOrdRef' )
         ( abap = 'to_SupplierInvoiceItemGLAcct' json = 'to_SupplierInvoiceItemGLAcct' )
         ( abap = 'to_SupplierInvoiceTax' json = 'to_SupplierInvoiceTax' )
         ( abap = 'results' json = 'results' )
     ).




    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.

  ENDMETHOD.


  METHOD create.
    DATA:lv_json TYPE string.
    DATA:ls_create TYPE ty_data.

    DATA: lv_total TYPE p LENGTH 11 DECIMALS 2.
    DATA: lv_cyje TYPE p LENGTH 11 DECIMALS 2.
    "供应商发票-----抬头数据
    MOVE-CORRESPONDING gs_tmp-header TO ls_create.
    "供应商发票-----采购订单数据
    LOOP AT gs_tmp-body INTO DATA(ls_purordref).
      APPEND INITIAL LINE TO ls_create-to_suplrinvcitempurordref-results ASSIGNING FIELD-SYMBOL(<fs_purordref>).
      ls_purordref-taxdeterminationdate = zzcl_comm_tool=>date2iso( ls_purordref-taxdeterminationdate ).
      MOVE-CORRESPONDING ls_purordref TO <fs_purordref>.

      lv_total = lv_total + ls_purordref-supplierinvoiceitemamount.
    ENDLOOP.

    "供应商发票-----tax订单数据 BY HANDTQH 20260206 ADD
    LOOP AT gs_tmp-tax INTO DATA(ls_tax).
      APPEND INITIAL LINE TO ls_create-to_supplierinvoicetax-results ASSIGNING FIELD-SYMBOL(<fs_tax>).
      MOVE-CORRESPONDING ls_tax TO <fs_tax>.
      lv_total = lv_total + ls_tax-taxamount.
    ENDLOOP.

    lv_cyje =  gs_tmp-header-invoicegrossamount - lv_total.
    IF lv_cyje <> 0.
      ls_create-unplanneddeliverycost = abs( lv_cyje ).
      IF lv_cyje < 0.
        ls_create-unplanneddeliverycost = |-{ ls_create-unplanneddeliverycost }|.
      ENDIF.
      CONDENSE ls_create-unplanneddeliverycost NO-GAPS.
    ENDIF.
    "供应商发票----总账数据
*    LOOP AT gs_tmp-glacct INTO DATA(ls_glacct).
*      APPEND INITIAL LINE TO ls_create-to_supplierinvoiceitemglacct-results ASSIGNING FIELD-SYMBOL(<fs_glacct>).
*      MOVE-CORRESPONDING ls_glacct TO <fs_glacct>.
*    ENDLOOP.


*&---接口HTTP 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    gv_srv = 'API_SUPPLIERINVOICE_PROCESS_SRV'.
    gv_entity = 'A_SupplierInvoice'.
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).
        DATA(lv_uri_path) = |/{  gv_srv }/{ gv_entity }| &&
                            |?sap-language={ gv_language }|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_http_client->set_csrf_token(  ).

        lo_request->set_content_type( 'application/json' ).
        "传入数据转JSON
        lv_json = /ui2/cl_json=>serialize(
              data          = ls_create
              compress      = abap_true
              name_mappings = gt_mapping
              ).

        lo_request->set_text( lv_json ).
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
        DATA(lv_res) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).
        lo_http_client->close( ).
        IF status-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  supplierinvoice TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'Success'.
          o_resp-sapnum  = ls_ress-d-supplierinvoice.
          gv_reservation = ls_ress-d-supplierinvoice.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message-value .

        ENDIF.
      CATCH cx_root INTO DATA(lr_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lr_root->get_longtext( ) .
    ENDTRY.
  ENDMETHOD.


  METHOD cancel.

*&---接口http 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    gv_srv = 'API_SUPPLIERINVOICE_PROCESS_SRV'.
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).
        DATA(lv_uri_path) = |/{  gv_srv }/Cancel?| &&
                            |PostingDate=datetime'{ gs_tmp-header-postingdate }'&| &&
                            |ReversalReason='{ gs_tmp-header-reversalreason }'&| &&
                            |FiscalYear='{ gs_tmp-header-fiscalyear }'&| &&
                            |SupplierInvoice='{ gs_tmp-header-supplierinvoice }'&| &&
                            |sap-language={ gv_language }|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_http_client->set_csrf_token(  ).

        lo_request->set_content_type( 'application/json' ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
        DATA(lv_res) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).
        lo_http_client->close( ).
        IF status-code = '200'.
          TYPES:BEGIN OF ty_heads,
                  reversedocument TYPE string,
                  fiscalyear      TYPE string,
                END OF ty_heads,
                BEGIN OF ty_cancel,
                  cancel TYPE ty_heads,
                END OF ty_cancel,
                BEGIN OF ty_ress,
                  d TYPE ty_cancel,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'Success'.
          o_resp-sapnum = ls_ress-d-cancel-reversedocument.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message-value .

        ENDIF.
      CATCH cx_root INTO DATA(lr_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lr_root->get_longtext( ) .
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

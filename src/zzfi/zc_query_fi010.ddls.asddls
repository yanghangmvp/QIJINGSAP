@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: '制费成本结转',
    typeNamePlural: '制费成本结转',
    title: { type: #STANDARD, value: 'BELNR' },
    description: { type: #STANDARD, value: 'BKTXT' }
  }
}
@EndUserText.label: '制费成本结转'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI010'
define root custom entity ZC_QUERY_FI010
{
      @UI.facet                    : [
        {
          id : 'GeneralInfo',
          purpose                  : #STANDARD,
          type                     : #IDENTIFICATION_REFERENCE,
          label                    : '基本信息',
          position                 : 10
        }
       ]

      @UI.hidden                   : true
      @UI.lineItem                 : [{ position: 01,type:#FOR_ACTION, dataAction: 'zzpost', label: '过账', invocationGrouping: #CHANGE_SET },
                                      { position: 02,type:#FOR_ACTION, dataAction: 'zzrev',  label: '冲销', invocationGrouping: #CHANGE_SET }]
  key UUID   : abap.char(200);

      @UI.identification           : [ { position: 10 } ]
      @UI.lineItem                 : [ { position: 10 } ]
      @UI.selectionField           : [ { position: 10 } ]
      @Consumption.filter.mandatory: true
      @Consumption.filter.defaultValue : ''
      @EndUserText.label : '是否已结转'
      ZSFYJZ : abap_boolean;

      @UI.identification           : [ { position: 20 } ]
      @UI.lineItem                 : [ { position: 20 } ]
      @EndUserText.label           : '结转日记账分录'
      @Consumption.semanticObject  : 'AccountingDocument'
      BELNR2 : belnr_d;

      @UI.identification           : [ { position: 30 } ]
      @UI.lineItem                 : [ { position: 30 } ]
      @EndUserText.label           : '结转过账日期'
      BUDAT2 : budat;

      @UI.identification           : [ { position: 40 } ]
      @UI.lineItem                 : [ { position: 40 } ]
      @UI.selectionField           : [ { position: 40 } ]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                  element: 'CompanyCode' }
                                   }]
      @EndUserText.label           : '公司代码'
      BUKRS  : bukrs;

      @UI.identification           : [ { position: 50 } ]
      @UI.lineItem                 : [ { position: 50 } ]
      @UI.selectionField           : [ { position: 50 } ]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @EndUserText.label           : '会计年度'
      GJAHR  : gjahr;

      @UI.identification           : [ { position: 60 } ]
      @UI.lineItem                 : [ { position: 60 } ]
      @UI.selectionField           : [ { position: 60 } ]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @EndUserText.label           : '会计期间'
      MONAT  : monat;

      @UI.identification           : [ { position: 70 } ]
      @UI.lineItem                 : [ { position: 70 } ]
      @EndUserText.label           : '过账日期'
      BUDAT  : budat;

      @UI.identification           : [ { position: 80 } ]
      @UI.lineItem                 : [ { position: 80 } ]
      @EndUserText.label           : '日记账分录类型'
      BLART  : blart;

      @UI.identification           : [ { position: 90 } ]
      @UI.lineItem                 : [ { position: 90 } ]
      @EndUserText.label           : '日记账分录'
      @Consumption.semanticObject  : 'AccountingDocument'
      BELNR  : belnr_d;

      @UI.identification           : [ { position: 100 } ]
      @UI.lineItem                 : [ { position: 100 } ]
      @EndUserText.label           : '日记账分录项目'
      DOCLN  : abap.char(6);

      @UI.identification           : [ { position: 110 } ]
      @UI.lineItem                 : [ { position: 110 } ]
      @EndUserText.label           : '借/贷码'
      SHKZG  : shkzg;

      @UI.identification           : [ { position: 120 } ]
      @UI.lineItem                 : [ { position: 120 } ]
      @EndUserText.label           : '总账科目'
      @ObjectModel.text.element    : [ 'TXT50' ]
      HKONT  : hkont;

      @UI.hidden                   : true
      TXT50  : abap.char(50); //科目名称

      @UI.identification           : [ { position: 130 } ]
      @UI.lineItem                 : [ { position: 130 } ]
      @EndUserText.label           : '公司代码金额-货币'
      @Semantics.amount.currencyCode : 'HWAER'
      DMBTR  : abap.dec(13,2);

      @UI.hidden                   : true
      HWAER  : waers;

      @UI.identification           : [ { position: 140 } ]
      @UI.lineItem                 : [ { position: 140 } ]
      @EndUserText.label           : '成本中心'
      @ObjectModel.text.element    : [ 'KTEXT' ]
      KOSTL  : kostl;

      @UI.hidden                   : true
      KTEXT  : ktext; //成本中心名称

      @UI.identification           : [ { position: 150 } ]
      @UI.lineItem                 : [ { position: 150 } ]
      @EndUserText.label           : '职能范围'
      @ObjectModel.text.element    : [ 'FKBTX' ]
      FKBER  : fkber;

      @UI.hidden                   : true
      FKBTX  : abap.char(25); //职能范围描述

      @UI.identification           : [ { position: 160 } ]
      @UI.lineItem                 : [ { position: 160 } ]
      @EndUserText.label           : '凭证抬头文本'
      BKTXT  : bktxt;

      @UI.identification           : [ { position: 170 } ]
      @UI.lineItem                 : [ { position: 170 } ]
      @EndUserText.label           : '行项目文本'
      SGTXT  : sgtxt;
}

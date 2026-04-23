@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: '制费成本分摊',
    typeNamePlural: '制费成本分摊',
    title: { type: #STANDARD, value: 'MATNR' },
    description: { type: #STANDARD, value: 'MAKTX' }
  }
}
@EndUserText.label: '制费成本分摊'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI011'
define root custom entity ZC_QUERY_FI011
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
      @EndUserText.label : '是否已分摊'
      ZSFYFT : abap_boolean;

      @UI.identification           : [ { position: 20 } ]
      @UI.lineItem                 : [ { position: 20 } ]
      @EndUserText.label           : '分摊日记账分录（发票凭证）'
      BELNR  : belnr_d;

      @UI.identification           : [ { position: 30 } ]
      @UI.lineItem                 : [ { position: 30 } ]
      @EndUserText.label           : '分摊过账日期'
      BUDAT  : budat;

      @UI.identification           : [ { position: 40 } ]
      @UI.lineItem                 : [ { position: 40 } ]
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
      @EndUserText.label           : '待摊总账科目'
      @ObjectModel.text.element    : [ 'TXT50' ]
      HKONT  : hkont;

      @UI.hidden                   : true
      TXT50  : abap.char(50); //科目名称

      @UI.identification           : [ { position: 80 } ]
      @UI.lineItem                 : [ { position: 80 } ]
      @EndUserText.label           : '待摊金额-货币'
      @Semantics.amount.currencyCode : 'HWAER'
      DMBTR  : abap.dec(13,2);

      @UI.identification           : [ { position: 90 } ]
      @UI.lineItem                 : [ { position: 90 } ]
      @UI.selectionField           : [ { position: 90 } ]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH',
                                                  element: 'Plant' }
                                   }]
      @EndUserText.label           : '工厂'
      WERKS  : werks_d;

      @UI.identification           : [ { position: 100 } ]
      @UI.lineItem                 : [ { position: 100 } ]
      @EndUserText.label           : '采购入库整车物料'
      @ObjectModel.text.element    : [ 'MAKTX' ]
      MATNR  : matnr;

      @UI.hidden                   : true
      MAKTX  : abap.char(150); //物料描述

      @UI.identification           : [ { position: 110 } ]
      @UI.lineItem                 : [ { position: 110 } ]
      @EndUserText.label           : '入库数量'
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      MENGE  : abap.dec(13,3);

      @UI.identification           : [ { position: 120 } ]
      @UI.lineItem                 : [ { position: 120 } ]
      @EndUserText.label           : '入库金额'
      @Semantics.amount.currencyCode : 'HWAER'
      DMBTR2 : abap.dec(13,2);


      @UI.identification           : [ { position: 130 } ]
      @UI.lineItem                 : [ { position: 130 } ]
      @EndUserText.label           : '入库金额合计'
      @Semantics.amount.currencyCode : 'HWAER'
      DMBTR3 : abap.dec(13,2);

      @UI.identification           : [ { position: 140 } ]
      @UI.lineItem                 : [ { position: 140 } ]
      @EndUserText.label           : '分摊系数'
      ZFTXS  : abap.dec(10,6);

      @UI.identification           : [ { position: 150 } ]
      @UI.lineItem                 : [ { position: 150 } ]
      @EndUserText.label           : '分摊金额'
      @Semantics.amount.currencyCode : 'HWAER'
      DMBTR4 : abap.dec(13,2);

      @UI.hidden                   : true
      MEINS  : meins; //基本单位

      @UI.hidden                   : true
      HWAER  : waers;
}

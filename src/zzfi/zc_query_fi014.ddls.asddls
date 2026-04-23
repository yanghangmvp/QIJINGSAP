/*@Metadata.allowExtensions: true*/
@UI: {
  headerInfo: {
    typeName: '成本收入表',
    typeNamePlural: '成本收入表',
    title: { value: 'CompanyCode' },
    description: { value: 'CompanyCodeName' }
  }
}
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI014'
@EndUserText.label: '成本收入表'

define root custom entity zc_query_fi014
{
      @UI.hidden          : true
  key uuid                : abap.int4;

      @UI.identification  : [ { position: 10 } ]
      @UI.lineItem        : [{ position: 10 }]
      @UI.selectionField  : [ { position: 10 } ]
      @EndUserText.label  : '公司代码'
      @Consumption.filter.defaultValue : 'GH00'
      /*搜索帮助*/
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      /* #SINGLE 单指 #INTERVAL 区间 #RANGE 多选列表*/
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      CompanyCode         : bukrs;

      @UI.identification  : [ { position: 20 } ]
      @UI.lineItem        : [{ position: 20 }]
      @EndUserText.label  : '公司名称'
      CompanyCodeName     : butxt;

      @UI.identification  : [ { position: 30 } ]
      @UI.lineItem        : [{ position: 30 }]
      @UI.selectionField  : [ { position: 20 } ]
      @EndUserText.label  : '会计年度'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      GJAHR               : gjahr;

      @UI.identification  : [ { position: 40 } ]
      @UI.lineItem        : [{ position: 40 }]
      @UI.selectionField  : [ { position: 30 } ]
      @EndUserText.label  : '会计期间'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      MONAT               : monat;


      @UI.identification  : [ { position: 50 } ]
      @UI.lineItem        : [{ position: 50 }]
      @UI.selectionField  : [ { position: 40 } ]
      @EndUserText.label  : '客户'
      /*搜索帮助*/
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer',
                                                     element: 'Customer' }
                                        }]
      @Consumption.filter.selectionType: #RANGE
      Customer            : kunnr;

      @UI.identification  : [ { position: 60 } ]
      @UI.lineItem        : [{ position: 60 }]
      @EndUserText.label  : '客户名称'
      CustomerName        : abap.char(80);

      @UI.identification  : [ { position: 70 } ]
      @UI.lineItem        : [{ position: 70 }]
      @UI.selectionField  : [ { position: 50 } ]
      @EndUserText.label  : '物料'
      /*搜索帮助*/
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductDescription',
                                                     element: 'Product' }
                                        }]
      @Consumption.filter.selectionType: #RANGE
      Material            : matnr;

      @UI.identification  : [ { position: 80 } ]
      @UI.lineItem        : [{ position: 80 }]
      @EndUserText.label  : '物料描述'
      ProductDescription  : maktx;

      @UI.identification  : [ { position: 90 } ]
      @UI.lineItem        : [{ position:90 }]
      @EndUserText.label  : '车型'
      ZZ005               : abap.char(20);

      @UI.identification  : [ { position: 100 } ]
      @UI.lineItem        : [{ position:100 }]
      @EndUserText.label  : '销量'
      /*      @Semantics.quantity.unitOfMeasure: 'BaseUnit'*/
      Quantity            : abap.dec( 13, 3 );

      @UI.identification  : [ { position: 110 } ]
      @UI.lineItem        : [{ position:110 }]
      @EndUserText.label  : '单位'
      BaseUnit            : abap.unit( 3 );

      @UI.identification  : [ { position: 120 } ]
      @UI.lineItem        : [{ position:120 }]
      @EndUserText.label  : '单位名称'
      UnitOfMeasureName   : mseht;

      @UI.identification  : [ { position: 130 } ]
      @UI.lineItem        : [{ position:130 }]
      @EndUserText.label  : '指导价(含税)'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZZDJ_HS             : abap.curr( 23,2);

      @UI.identification  : [ { position: 140 } ]
      @UI.lineItem        : [{ position:140 }]
      @EndUserText.label  : '销售单价'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZXSDJ               : abap.curr( 23,2);

      @UI.identification  : [ { position: 150 } ]
      @UI.lineItem        : [{ position:150 }]
      @EndUserText.label  : '单台标准成本'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZDTBZCB             : abap.curr( 23,2);

      @UI.identification  : [ { position: 160 } ]
      @UI.lineItem        : [{ position:160 }]
      @EndUserText.label  : '单台实际成本'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZDTSJCB             : abap.curr( 23,2);

      @UI.identification  : [ { position: 170 } ]
      @UI.lineItem        : [{ position:170 }]
      @EndUserText.label  : '单台毛利'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZDTML               : abap.curr( 23,2);

      @UI.identification  : [ { position: 180 } ]
      @UI.lineItem        : [{ position:180 }]
      @EndUserText.label  : '收入金额(本币)'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZSRJE_B             : abap.curr( 23,2);

      @UI.identification  : [ { position: 190 } ]
      @UI.lineItem        : [{ position:190 }]
      @EndUserText.label  : '成本金额(本币)'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZCBJE_B             : abap.curr( 23,2);

      @UI.identification  : [ { position: 200 } ]
      @UI.lineItem        : [{ position:200 }]
      @EndUserText.label  : '毛利'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZMAOLI              : abap.curr( 23,2);

      @UI.identification  : [ { position: 210 } ]
      @UI.lineItem        : [{ position:210 }]
      @EndUserText.label  : '毛利率(%)'
      @Semantics.amount.currencyCode : 'CompanyCodeCurrency'
      ZMAOLILV            : abap.curr( 23,2);


      @UI.hidden          : true
      CompanyCodeCurrency : abap.cuky(5);

}

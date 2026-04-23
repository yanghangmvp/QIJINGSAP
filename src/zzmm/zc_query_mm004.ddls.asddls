@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_MM004'
@UI: {
  headerInfo: {
    typeName: '采购收退货明细下发',
    typeNamePlural: '采购收退货明细下发',
    title: { value: 'RECEIVENO' },
    description: { value: 'orderRecSeqNo' }
  }
}
@EndUserText.label: '采购收退货明细下发'
define root custom entity zc_query_mm004
{
      @UI.facet         : [ { label        : '常规信息',
                      id: 'GeneralInfo',
                      purpose      : #STANDARD,
                      position     : 10 ,
                      type         : #IDENTIFICATION_REFERENCE
                     } ]
      @UI.hidden        : true
  key uuid              : abap.char(255);

      @UI.identification: [ { position: 10 } ]
      @UI.lineItem      : [ { position: 10 },
                            { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET } ]
      @EndUserText.label: '条目状态'
      DOFLAG            : abap.char(1);

      @UI.identification: [ { position: 15 } ]
      @UI.lineItem      : [ { position: 15 } ]
      @EndUserText.label: '订单类型'
      @UI.selectionField: [ { position: 15 } ]
      PurchaseOrderType : abap.char(4);

      @UI.identification: [ { position: 20 } ]
      @UI.lineItem      : [ { position: 20 } ]
      @EndUserText.label: '采购组织'
      EKORG             : ekorg;

      @UI.identification: [ { position: 30 } ]
      @UI.lineItem      : [ { position: 30 } ]
      @EndUserText.label: '采购组'
      @UI.selectionField: [ { position: 30 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchasingGroup',
                                                     element: 'PurchasingGroup' }
                                        }]
      ZPARA1            : ekgrp;

      @UI.identification: [ { position: 40 } ]
      @UI.lineItem      : [ { position: 40 } ]
      @EndUserText.label: '公司代码'
      COMPCODE          : bukrs;

      @UI.identification: [ { position: 50 } ]
      @UI.lineItem      : [ { position: 50 } ]
      @EndUserText.label: '工厂代码'
      @UI.selectionField: [ { position: 50 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH',
                                                     element: 'Plant' }
                                        }]
      COMP              : werks_d;

      @UI.identification: [ { position: 60 } ]
      @UI.lineItem      : [ { position: 60 } ]
      @EndUserText.label: '订单号'
      orderNo           : ebeln;

      @UI.identification: [ { position: 70 } ]
      @UI.lineItem      : [ { position: 70 } ]
      @EndUserText.label: '订单行号'
      orderRowNo        : ebelp;

      @UI.identification: [ { position: 80 } ]
      @UI.lineItem      : [ { position: 80 } ]
      @EndUserText.label: '行序号'
      orderRowSeqNo     : abap.numc(4);

      @UI.identification: [ { position: 90 } ]
      @UI.lineItem      : [ { position: 90 } ]
      @EndUserText.label: '收货单号'
      RECEIVENO         : mblnr;

      @UI.identification: [ { position: 100 } ]
      @UI.lineItem      : [ { position: 100 } ]
      @EndUserText.label: '收货行序号'
      orderRecSeqNo     : mblpo;

      @UI.identification: [ { position: 110 } ]
      @UI.lineItem      : [ { position: 110 } ]
      @EndUserText.label: '应付行序号'
      orderPayableSeqNo : abap.numc(4);

      @UI.identification: [ { position: 120 } ]
      @UI.lineItem      : [ { position: 120 } ]
      @EndUserText.label: '零件号'
      @UI.selectionField: [ { position: 120 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH',
                                                     element: 'Product' }
                                        }]
      COMPONENTNO       : matnr;

      @UI.identification: [ { position: 130 } ]
      @UI.lineItem      : [ { position: 130 } ]
      @EndUserText.label: '供应商'
      SUPPLIERNO        : lifre;

      @UI.identification: [ { position: 140 } ]
      @UI.lineItem      : [ { position: 140 } ]
      @EndUserText.label: '过账日期'
      @UI.selectionField: [ { position: 140 } ]
      @Consumption.filter.selectionType: #INTERVAL
      useDate           : budat;

      @UI.identification: [ { position: 150 } ]
      @UI.lineItem      : [ { position: 150 } ]
      @EndUserText.label: '单价'
      //      @Semantics.amount.currencyCode : 'DocumentCurrency'
      price             : abap.dec(15,6);

      @UI.hidden        : true
      priceUnit         : meins; //价格单位

      @UI.identification: [ { position: 160 } ]
      @UI.lineItem      : [ { position: 160 } ]
      @EndUserText.label: '价格类型'
      ZPRSTA            : kscha;

      @UI.identification: [ { position: 170 } ]
      @UI.lineItem      : [ { position: 170 } ]
      @EndUserText.label: '应付数量'
      @Semantics.quantity.unitOfMeasure: 'priceUnit'
      payableNum        : abap.dec(19,3);

      @UI.identification: [ { position: 180 } ]
      @UI.lineItem      : [ { position: 180 } ]
      @EndUserText.label: '应付金额'
      //      @Semantics.amount.currencyCode : 'DocumentCurrency'
      payableAmount     : abap.dec(15,4);

      @UI.identification: [ { position: 183 } ]
      @UI.lineItem      : [ { position: 183 } ]
      @EndUserText.label: '货币'
      DocumentCurrency  : waers; //货币

      @UI.identification: [ { position: 185 } ]
      @UI.lineItem      : [ { position: 185 } ]
      @EndUserText.label: '税率'
      taxRate           : abap.dec(15,0);

      @UI.identification: [ { position: 190 } ]
      @UI.lineItem      : [ { position: 190 } ]
      @EndUserText.label: '来源系统'
      SFROM             : abap.char(20);

      @UI.hidden        : true
      INVOICESTATUS     : abap.char(4); //开票状态

      @UI.hidden        : true
      ZSBD              : abap.char(1); //上年度正式价标识

}

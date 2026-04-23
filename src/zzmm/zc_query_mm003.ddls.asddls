@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_MM003'
@UI: {
  headerInfo: {
    typeName: '采购价格主数据',
    typeNamePlural: '采购价格主数据',
    title: { value: 'PurchasingInfoRecord' },
    description: { value: 'PurchasingInfoRecord' }
  }
}
@EndUserText.label: '采购价格主数据推送'
define root custom entity zc_query_mm003
{
      @UI.facet                      : [ {
                        label        : '常规信息',
                        id           : 'GeneralInfo',
                        purpose      : #STANDARD,
                        position     : 10 ,
                        type         : #IDENTIFICATION_REFERENCE
                   }

                    ]
      @UI.hidden                     : true
  key uuid                           : abap.char(255);
      @UI.identification             : [ { position: 10 } ]
      @UI.lineItem                   : [ { position: 10 } ,
                                      { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }]
      @UI.selectionField             : [ { position: 10 } ]
      @EndUserText.label             : '采购信息记录'
      @Consumption.semanticObject    : 'PurchasingInfoRecord'
      PurchasingInfoRecord           : infnr;
      @UI.identification             : [ { position: 20 } ]
      @UI.lineItem                   : [ { position: 20 } ]
      @EndUserText.label             : '条件记录编号'
      ConditionRecord                : abap.char(10);
      @UI.identification             : [ { position: 30 } ]
      @UI.lineItem                   : [ { position: 30 } ]
      @UI.selectionField             : [ { position: 20 } ]
      @EndUserText.label             : '采购组织'
      PurchasingOrganization         : abap.char(4);
      @UI.identification             : [ { position: 40 } ]
      @UI.lineItem                   : [ { position: 40 } ]
      @EndUserText.label             : '信息记录类别'
      PurchasingInfoRecordCategory   : abap.char(1);
      @UI.identification             : [ { position: 50 } ]
      @UI.lineItem                   : [ { position: 50 } ]
      @UI.selectionField             : [ { position: 30 } ]
      @EndUserText.label             : '工厂'
      Plant                          : abap.char(4);
      @UI.identification             : [ { position: 60 } ]
      @UI.lineItem                   : [ { position: 60 } ]
      @EndUserText.label             : '条件序号'
      ConditionSequentialNumberShort : abap.char(2);
      @UI.identification             : [ { position: 70 } ]
      @UI.lineItem                   : [ { position: 70 } ]
      @UI.selectionField             : [ { position: 40 } ]
      @EndUserText.label             : '条件类型'
      ConditionType                  : abap.char(4);
      @UI.identification             : [ { position: 80 } ]
      @UI.lineItem                   : [ { position: 80 } ]
      @UI.selectionField             : [ { position: 50 } ]
      @EndUserText.label             : '供应商编码'
      Supplier                       : abap.char(10);
      @UI.identification             : [ { position: 90 } ]
      @UI.lineItem                   : [ { position: 90 } ]
      @EndUserText.label             : '信息短文本'
      PurchasingInfoRecordDesc       : abap.char(40);
      @UI.identification             : [ { position: 100 } ]
      @UI.lineItem                   : [ { position: 100 } ]
      @EndUserText.label             : '物料编号'
      Material                       : abap.char(40);
      @UI.identification             : [ { position: 110 } ]
      @UI.lineItem                   : [ { position: 110 } ]
      @EndUserText.label             : '物料组'
      MaterialGroup                  : abap.char(10);
      @UI.identification             : [ { position: 120 } ]
      @UI.lineItem                   : [ { position: 120 } ]
      @EndUserText.label             : '采购订单单位'
      PurgDocOrderQuantityUnit       : abap.char(3);
      @UI.identification             : [ { position: 130 } ]
      @UI.lineItem                   : [ { position: 130 } ]
      @EndUserText.label             : '订单单位项基本单位分子'
      orderitemqtytobaseqtynmrtr     : abap.dec(5);
      @UI.identification             : [ { position: 140 } ]
      @UI.lineItem                   : [ { position: 140 } ]
      @EndUserText.label             : '订单单位项基本单位分目'
      orderitemqtytobaseqtydnmntr    : abap.dec(5);
      @UI.identification             : [ { position: 150 } ]
      @UI.lineItem                   : [ { position: 150 } ]
      @EndUserText.label             : '基本计量单位'
      BaseUnit                       : abap.char(5);
      @UI.identification             : [ { position: 160 } ]
      @UI.lineItem                   : [ { position: 160 } ]
      @EndUserText.label             : '创建日期'
      CreationDate                   : abap.dats;
      @UI.identification             : [ { position: 170 } ]
      @UI.lineItem                   : [ { position: 170 } ]
      @EndUserText.label             : '采购组'
      PurchasingGroup                : abap.char(3);
      @UI.identification             : [ { position: 175 } ]
      @UI.lineItem                   : [ { position: 175 } ]
      @EndUserText.label             : '物料类型'
      producttype                    : abap.char(10);
      @UI.identification             : [ { position: 180 } ]
      @UI.lineItem                   : [ { position: 180 } ]
      @EndUserText.label             : '税码'
      TaxCode                        : abap.char(2);
      @UI.identification             : [ { position: 190 } ]
      @UI.lineItem                   : [ { position: 190 } ]
      @EndUserText.label             : '税率'
      Taxrate                        : abap.dec(11,2);
      @UI.identification             : [ { position: 200 } ]
      @UI.lineItem                   : [ { position: 200 } ]
      @EndUserText.label             : '国际贸易条款'
      IncotermsClassification        : abap.char(3);
      @UI.identification             : [ { position: 210 } ]
      @UI.lineItem                   : [ { position: 210 } ]
      @EndUserText.label             : '国际贸易条款(部分 2)'
      ncotermsTransferLocation       : abap.char(30);
      @UI.identification             : [ { position: 220 } ]
      @UI.lineItem                   : [ { position: 220 } ]
      @EndUserText.label             : '定价日期控制'
      PricingDateControl             : abap.char(1);
      @UI.identification             : [ { position: 230 } ]
      @UI.lineItem                   : [ { position: 230 } ]
      @EndUserText.label             : '有效期至'
      ConditionValidityEndDate       : abap.dats;
      @UI.identification             : [ { position: 240 } ]
      @UI.lineItem                   : [ { position: 240 } ]
      @EndUserText.label             : '有效期自'
      ConditionValidityStartDate     : abap.dats;
      @UI.identification             : [ { position: 250 } ]
      @UI.lineItem                   : [ { position: 250 } ]
      @EndUserText.label             : '条件金额'
      ConditionRateValue             : abap.dec(11,2);
      @UI.identification             : [ { position: 260 } ]
      @UI.lineItem                   : [ { position: 260 } ]
      @EndUserText.label             : '条件货币（条件比例或货币）'
      ConditionRateValueUnit         : abap.char(5);
      @UI.identification             : [ { position: 270 } ]
      @UI.lineItem                   : [ { position: 270 } ]
      @EndUserText.label             : '定价单位'
      ConditionQuantity              : abap.dec(11,3);
      @UI.identification             : [ { position: 280 } ]
      @UI.lineItem                   : [ { position: 280 } ]
      @EndUserText.label             : '计量单位'
      ConditionQuantityUnit          : abap.char(5);
      @UI.identification             : [ { position: 290 } ]
      @UI.lineItem                   : [ { position: 290 } ]
      @EndUserText.label             : '应用程序'
      ConditionApplication           : abap.char(2);
      @UI.identification             : [ { position: 300 } ]
      @UI.lineItem                   : [ { position: 300 } ]
      @EndUserText.label             : '计算类型'
      ConditionCalculationTypeShort  : abap.char(1);
      @UI.identification             : [ { position: 310 } ]
      @UI.lineItem                   : [ { position: 310 } ]
      @EndUserText.label             : '删除标识'
      ConditionIsDeleted             : abap.char(1);
      @UI.identification             : [ { position: 320 } ]
      @UI.lineItem                   : [ { position: 320 } ]
      @EndUserText.label             : '转换的分子'
      ConditionToBaseQtyNmrtr        : abap.dec(5);
      @UI.identification             : [ { position: 330 } ]
      @UI.lineItem                   : [ { position: 330 } ]
      @EndUserText.label             : '转换的分母'
      ConditionToBaseQtyDnmntr       : abap.dec(5);
      @UI.identification             : [ { position: 340 } ]
      @UI.lineItem                   : [ { position: 340 } ]
      @EndUserText.label             : '条件货币'
      ConditionCurrency              : abap.char(5);
      @UI.identification             : [ { position: 350 } ]
      @UI.lineItem                   : [ { position: 350 } ]
      @EndUserText.label             : '价格类型'
      priceType                      : abap.char(5);
      @UI.identification             : [ { position: 360 } ]
      @UI.lineItem                   : [ { position: 360 } ]
      @EndUserText.label             : '基本单位不含税条件价'
      ConditionValueofbaseunit       : abap.char(25);
      @UI.identification             : [ { position: 370 } ]
      @UI.lineItem                   : [ { position: 370 } ]
      @EndUserText.label             : '基本单位含税条件价'
      ConditiontaxValueofbaseunit    : abap.char(25);
}

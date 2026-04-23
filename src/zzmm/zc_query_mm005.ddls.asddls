@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_MM005'
@UI: {
  headerInfo: {
    typeName: '库龄报表',
    typeNamePlural: '库龄报表',
    title: { value: 'CompanyCode' },
    description: { value: 'CompanyCode' }
  }
}
@EndUserText.label: '库龄报表'
define root custom entity zc_query_mm005
{
      @UI.facet             : [ { label        : '常规信息',
                      id    : 'GeneralInfo',
                      purpose      : #STANDARD,
                      position     : 10 ,
                      type  : #IDENTIFICATION_REFERENCE
                     } ]
      @UI.hidden            : true
  key uuid                  : abap.char(255);
      @UI.identification    : [ { position: 10 } ]
      @UI.lineItem          : [ { position: 10 } ]
      @UI.selectionField    : [ { position: 10 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                               element: 'CompanyCode' }
                                  }]
      @Consumption.filter.defaultValue : 'GH00'
      @EndUserText.label    : '公司代码'
      CompanyCode           : bukrs;
      @UI.identification    : [ { position: 20 } ]
      @UI.lineItem          : [ { position: 20 } ]
      @UI.selectionField    : [ { position: 20 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH',
                                               element: 'Plant' }
                                  }]
      @EndUserText.label    : '工厂'
      Plant                 : werks_d;
      @UI.identification    : [ { position: 30 } ]
      @UI.lineItem          : [ { position: 30 } ]
      @UI.selectionField    : [ { position: 30 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH',
                                               element: 'Product' }
                                  }]
      @EndUserText.label    : '物料'
      Material              : matnr;
      @UI.identification    : [ { position: 40 } ]
      @UI.lineItem          : [ { position: 40 } ]
      @EndUserText.label    : '物料名称'
      ProductDescription_ZH : maktx;
      @UI.identification    : [ { position: 50 } ]
      @UI.lineItem          : [ { position: 50 } ]
      @EndUserText.label    : '英文名称'
      ProductDescription_en : maktx;
      @UI.identification    : [ { position: 60 } ]
      @UI.lineItem          : [ { position: 60 } ]
      @EndUserText.label    : '基本计量单位'
      MaterialBaseUnit      : meins;
      @UI.identification    : [ { position: 70 } ]
      @UI.lineItem          : [ { position: 70 } ]
      @EndUserText.label    : '库存数量'
      TotalStock            : abap.dec(13,3);
      @UI.identification    : [ { position: 80 } ]
      @UI.lineItem          : [ { position: 80 } ]
      @EndUserText.label    : '物料凭证'
      MaterialDocument      : mblnr;
      @UI.identification    : [ { position: 90 } ]
      @UI.lineItem          : [ { position: 90 } ]
      @EndUserText.label    : '物料凭证行号'
      MaterialDocumentItem  : mblpo;
      @UI.identification    : [ { position: 100 } ]
      @UI.lineItem          : [ { position: 100 } ]
      @EndUserText.label    : '收货数量'
      QuantityInBaseUnit    : abap.dec(13,3);
      @UI.identification    : [ { position: 110 } ]
      @UI.lineItem          : [ { position: 110 } ]
      @UI.selectionField    : [ { position: 40 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_GoodsMovementType',
                                               element: 'GoodsMovementType' }
                                  }]
      @Consumption.filter.defaultValue : '101'
      @EndUserText.label    : '移动类型'
      GoodsMovementType     : abap.char(3);
      @UI.identification    : [ { position: 120 } ]
      @UI.lineItem          : [ { position: 120 } ]
      @EndUserText.label    : '收货日期'
      ReceiveDate           : abap.dats;
      @UI.identification    : [ { position: 130 } ]
      @UI.lineItem          : [ { position: 130 } ]
      @EndUserText.label    : '库龄天数'
      InventoryAgeDate      : abap.int2;
      @UI.identification    : [ { position: 140 } ]
      @UI.lineItem          : [ { position: 140 } ]
      @EndUserText.label    : '库龄数量'
      StockQuantity         : abap.dec(13,3);
      @UI.identification    : [ { position: 150 } ]
      @UI.lineItem          : [ { position: 150 } ]
      @EndUserText.label    : '单价'
      Price                 : abap.dec(13,2);
      @UI.identification    : [ { position: 160 } ]
      @UI.lineItem          : [ { position: 160 } ]
      @EndUserText.label    : '库龄金额'
      StockValue            : abap.dec(13,2);
      @UI.identification    : [ { position: 170 } ]
      @UI.lineItem          : [ { position: 170 } ]
      @EndUserText.label    : '币别'
      CompanyCodeCurrency   : waers;
      @UI.identification    : [ { position: 180 } ]
      @UI.lineItem          : [ { position: 180 } ]
      @EndUserText.label    : '物料组'
      ProductGroup          : abap.char(10);
      @UI.identification    : [ { position: 190 } ]
      @UI.lineItem          : [ { position: 190 } ]
      @EndUserText.label    : '物料类型'
      ProductType           : abap.char(10);
      @UI.identification    : [ { position: 200 } ]
      @UI.lineItem          : [ { position: 200 } ]
      @EndUserText.label    : 'VIN码'
      SerialNumber          : abap.char(18);


}

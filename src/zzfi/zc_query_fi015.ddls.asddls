@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: '在建工程明细表',
    typeNamePlural: '在建工程明细表',
    title: { type: #STANDARD, value: 'MasterFixedAsset' },
    description: { type: #STANDARD, value: 'FixedAssetDescription' }
  }
}
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI015'
@EndUserText.label: '在建工程明细表'
define root custom entity zc_query_fi015
{
      @UI.facet                    : [
        {
          id                       : 'GeneralInfo',
          purpose                  : #STANDARD,
          type                     : #IDENTIFICATION_REFERENCE,
          label                    : '基本信息',
          position                 : 10
        }
       ]

      @UI.lineItem                 : [ { position: 10 } ]
      @UI.selectionField           : [ { position: 10 } ]
      @EndUserText.label           : '公司代码'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
  key CompanyCode                  : bukrs;

      @UI.lineItem                 : [ { position: 20 } ]
      @UI.selectionField           : [ { position: 20 } ]
      @EndUserText.label           : '年度'
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
  key FirstAcquisitionFiscalYear   : gjahr;

      @UI.lineItem                 : [ { position: 30 } ]
      @UI.selectionField           : [ { position: 30 } ]
      @EndUserText.label           : '期间'
      @Consumption.filter.mandatory: true
      @Consumption.filter.selectionType: #SINGLE
  key FirstAcquisitionFiscalPeriod : poper;

      @UI.lineItem                 : [ { position: 40 } ]
      @EndUserText.label           : '在建工程'
      @UI.selectionField           : [ { position: 40 } ]
  key MasterFixedAsset             : anln1;

      @UI.lineItem                 : [ { position: 50 } ]
      @EndUserText.label           : '项目名称'
      FixedAssetDescription        : abap.char(50);

      @UI.lineItem                 : [ { position: 50 } ]
      @EndUserText.label           : '合同号'
      AssetAdditionalDescription   : abap.char(50);

      @UI.lineItem                 : [ { position: 60 } ]
      @EndUserText.label           : '供应商'
      @ObjectModel.text.element    : [ 'SupplierName' ]
      Supplier                     : lifnr;

      @UI.hidden                   : true
      SupplierName                 : text80; //供应商

      @UI.lineItem                 : [ { position: 70 } ]
      @EndUserText.label           : '期初余额'
      Amount_qc                    : abap.dec( 23, 2 );

      @UI.lineItem                 : [ { position: 80 } ]
      @EndUserText.label           : '本期增加金额'
      Amount_zj                    : abap.dec( 23, 2 );

      @UI.lineItem                 : [ { position: 90 } ]
      @EndUserText.label           : '本期转固金额'
      Amount_zg                    : abap.dec( 23, 2 );

      @UI.lineItem                 : [ { position: 100 } ]
      @EndUserText.label           : '本期其他减少'
      Amount_js                    : abap.dec( 23, 2 );

      @UI.lineItem                 : [ { position: 110 } ]
      @EndUserText.label           : '期末余额'
      Amount_qm                    : abap.dec( 23, 2 );

      @UI.lineItem                 : [ { position: 120 } ]
      @EndUserText.label           : '累计利息资本化金额'
      Amount_ljlx                  : abap.dec( 23, 2 );

      @UI.lineItem                 : [ { position: 130 } ]
      @EndUserText.label           : '本期利息资本化金额'
      Amount_bqlx                  : abap.dec( 23, 2 );

}

@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_MM002'
@UI: {
  headerInfo: {
    typeName: '物料主数据',
    typeNamePlural: '物料主数据',
    title: { value: 'Product' },
    description: { value: 'YY1_PartVer_PRD' }
  }
}
@EndUserText.label: '物料主数据推送'
define root custom entity zc_query_mm002
{

      @UI.facet              : [ {
                        label: '常规信息',
                        id   : 'GeneralInfo',
                        purpose   : #STANDARD,
                        position  : 10 ,
                        type : #IDENTIFICATION_REFERENCE
                   }]
      @UI.hidden             : true
  key UUID                   : abap.char(255);
      @UI.identification     : [ { position: 10 } ]
      @UI.lineItem           : [ { position: 10 },
                                 { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET } ]
      @EndUserText.label     : '物料编号编码'
      @UI.selectionField     : [ { position: 10 } ]
      @Consumption.semanticObject : 'Material'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH',
                                                     element: 'Product' }
                                        }]
      Product                : matnr;

      @UI.identification     : [ { position: 20 } ]
      @UI.lineItem           : [ { position: 20 } ]
      @EndUserText.label     : '工厂（采购收货仓库）编码'
      @UI.selectionField     : [ { position: 20 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH',
                                                     element: 'Plant' }
                                        }]
      Plant                  : werks_d;

      @UI.identification     : [ { position: 30 } ]
      @UI.lineItem           : [ { position: 30 } ]
      @EndUserText.label     : '物料类型'
      @UI.selectionField     : [ { position: 30 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductTypeVH',
                                                     element: 'ProductType' }
                                        }]
      ProductTYPE            : mtart;

      @UI.identification     : [ { position: 40 } ]
      @UI.lineItem           : [ { position: 40 } ]
      @EndUserText.label     : '物料中文名称'
      YY1_PartVer_PRD        : abap.char( 150 );

      @UI.identification     : [ { position: 50 } ]
      @UI.lineItem           : [ { position: 50 } ]
      @EndUserText.label     : '是否可采购'
      isPurchase             : abap.char( 1 );

      @UI.identification     : [ { position: 60 } ]
      @UI.lineItem           : [ { position: 60 } ]
      @EndUserText.label     : '是否可销售'
      isSale                 : abap.char( 1 );

      @UI.identification     : [ { position: 70 } ]
      @UI.lineItem           : [ { position: 70 } ]
      @EndUserText.label     : '计量单位'
      BaseUnit               : abap.char( 3 );

      @UI.identification     : [ { position: 80 } ]
      @UI.lineItem           : [ { position: 80 } ]
      @EndUserText.label     : '归属公司(货主)'
      CompanyCode            : bukrs;

      @UI.identification     : [ { position: 90 } ]
      @UI.lineItem           : [ { position: 90 } ]
      @EndUserText.label     : '车型编码'
      YY1_ModelCode_PRD      : abap.char( 150 );

      @UI.identification     : [ { position: 100 } ]
      @UI.lineItem           : [ { position: 100 } ]
      @EndUserText.label     : '配置版本'
      YY1_ConfigVersion_PRD  : abap.char( 40 );

      @UI.identification     : [ { position: 110 } ]
      @UI.lineItem           : [ { position: 110 } ]
      @EndUserText.label     : '销售代码'
      YY1_SALESCODE_PRD      : abap.char( 250 );

      @UI.identification     : [ { position: 120 } ]
      @UI.lineItem           : [ { position: 120 } ]
      @EndUserText.label     : '零件状态'
      YY1_PartStatusDesc_PRD : abap.char( 20 );

      @UI.identification     : [ { position: 130 } ]
      @UI.lineItem           : [ { position: 130 } ]
      @EndUserText.label     : '零件质量kg/单位'
      YY1_Weight_PRD         : abap.dec( 13,2 );

      @UI.identification     : [ { position: 140 } ]
      @UI.lineItem           : [ { position: 140 } ]
      @EndUserText.label     : '材料'
      YY1_RawNum_PRD         : abap.char( 256 );

      @UI.identification     : [ { position: 150 } ]
      @UI.lineItem           : [ { position: 150 } ]
      @EndUserText.label     : '成本'
      YY1_Cost_PRD           : abap.char( 40 );

      @UI.identification     : [ { position: 160 } ]
      @UI.lineItem           : [ { position: 160 } ]
      @EndUserText.label     : '造型控制码'
      YY1_ModelCtrCode_PRD   : abap.char( 40 );

      @UI.identification     : [ { position: 170 } ]
      @UI.lineItem           : [ { position: 170 } ]
      @EndUserText.label     : '零件重要度'
      YY1_KeyPart_PRD        : abap.char( 4 );

      @UI.identification     : [ { position: 180 } ]
      @UI.lineItem           : [ { position: 180 } ]
      @EndUserText.label     : '硬件号'
      YY1_HardwareCode_PRD   : abap.char( 40 );

      @UI.identification     : [ { position: 190 } ]
      @UI.lineItem           : [ { position: 190 } ]
      @EndUserText.label     : '软件号'
      YY1_SoftwareCode_PRD   : abap.char( 40 );

      @UI.identification     : [ { position: 200 } ]
      @UI.lineItem           : [ { position: 200 } ]
      @EndUserText.label     : '零件类型'
      YY1_PartType_PRD       : abap.char( 40 );

      @UI.identification     : [ { position: 210 } ]
      @UI.lineItem           : [ { position: 210 } ]
      @EndUserText.label     : '数据种别'
      YY1_MaterialType_PRD   : abap.char( 10 );

      @UI.identification     : [ { position: 220 } ]
      @UI.lineItem           : [ { position: 220 } ]
      @EndUserText.label     : '物料英文名称'
      YY1_PartVer_en_PRD     : abap.char( 150 );

      @UI.identification     : [ { position: 230 } ]
      @UI.lineItem           : [ { position: 230 } ]
      @EndUserText.label     : '序列号参数文件'
      SerialNumberProfile    : abap.char( 4 );

      @UI.identification     : [ { position: 240 } ]
      @UI.lineItem           : [ { position: 240 } ]
      @EndUserText.label     : '更改时间戳'
      LastChangeDateTime     : abp_lastchange_tstmpl;

}

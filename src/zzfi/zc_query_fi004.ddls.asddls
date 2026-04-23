@EndUserText.label: '综合管理维度'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI004'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '综合管理维度',
    typeNamePlural: '综合管理维度',
    title: { type: #STANDARD, value: 'VOUCHER' },
    description: { type: #STANDARD, value: 'LINE' }
  }
}
define root custom entity zc_query_FI004
{
      @UI.facet   : [
       {
         id       : 'GeneralInfo',
         purpose  : #STANDARD,
         type     : #IDENTIFICATION_REFERENCE,
         label    : '基本信息',
         position : 10
       }
      ]

      @UI.hidden  : true
  key UUID        : abap.char( 255 );


      @UI         : {
        lineItem  : [{ position: 10 },
                    { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET },
                    { type : #FOR_ACTION, dataAction: 'zchange', label: '修改数据', invocationGrouping: #CHANGE_SET }
                   ],
        identification     : [{ position: 10 }],
        selectionField     : [{ position: 10 }]
      }
      @EndUserText.label   : '年份'
      @Consumption.filter.selectionType: #SINGLE
      ZZYEAR      : gjahr;

      @UI         : {
        lineItem  : [{ position: 20 }],
        identification     : [{ position: 20 }],
        selectionField     : [{ position: 20 }]
      }
      @EndUserText.label   : '月份'
      @Consumption.filter.selectionType: #SINGLE
      ZZMONTH     : monat;

      @UI         : {
        lineItem  : [{ position: 25 }],
        identification     : [{ position: 25 }],
        selectionField     : [{ position: 25 }]
      }
      @EndUserText.label   : '核算系统公司'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @ObjectModel.text.element     : [ 'ENT_DES' ] //标记文本字段
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ENT_COD     : bukrs;

      @UI         : {
      lineItem    : [{ position: 30 }],
      identification     : [{ position: 30 }]
      }
      @EndUserText.label   : '会计凭证编号'
      VOUCHER     : belnr_d;

      @UI         : {
      lineItem    : [{ position: 40 }],
      identification     : [{ position: 40 }]
      }
      @EndUserText.label   : '会计凭证行项目'
      LINE        : abap.char( 6 );

      @UI         : {
      lineItem    : [{ position: 50 }],
      identification     : [{ position: 50 }]
      }
      @EndUserText.label   : '核算系统'
      SYS_ID      : abap.char( 20 );

      @UI         : {
      lineItem    : [{ position: 60 }],
      identification     : [{ position: 60 }]
      }
      @EndUserText.label   : '集团统一公司'
      @ObjectModel.text.element     : [ 'GP_ENT_DES' ] //标记文本字段
      GP_ENT_COD  : abap.char( 4 );

      @UI.hidden  : true
      GP_ENT_DES  : abap.char( 100 ); //集团统一公司名称

      @UI.hidden  : true
      ENT_DES     : butxt; //核算系统公司名称

      @UI         : {
      lineItem    : [{ position: 100 }],
      identification     : [{ position: 100 }]
      }
      @EndUserText.label   : '项目类型'
      TYPE        : abap.char( 4 );

      @UI         : {
      lineItem    : [{ position: 110 }],
      identification     : [{ position: 110 }]
      }
      @EndUserText.label   : '项目'
      @ObjectModel.text.element     : [ 'PROJ_NAME' ] //标记文本字段
      PROJ_COD    : abap.char( 24 );

      @UI.hidden  : true
      PROJ_NAME   : abap.char( 60 ); //项目名称

      @UI         : {
      lineItem    : [{ position: 130 }],
      identification     : [{ position: 130 }]
      }
      @EndUserText.label   : '核算字段'
      @ObjectModel.text.element     : [ 'SUB_DES' ] //标记文本字段
      SUB_COD     : abap.char( 10 );

      @UI.hidden  : true
      SUB_DES     : abap.char( 100 ); //核算字段名称

      @UI         : {
      lineItem    : [{ position: 150 }],
      identification     : [{ position: 150 }]
      }
      @EndUserText.label   : '金额'
      AMOUNT      : abap.dec(27,9);

      @UI         : {
      lineItem    : [{ position: 160 }],
      identification     : [{ position: 160 }]
      }
      @EndUserText.label   : '文本'
      NOTE        : sgtxt;

      @UI.hidden  : true
      DATEUPD     : abap.char(14);

      @UI.hidden  : true
      zzedit      : abap_boolean;

      @UI.hidden  : true
      zzmandatory : abap_boolean;

}

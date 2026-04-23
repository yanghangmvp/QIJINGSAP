@EndUserText.label: '账龄原值'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI007'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '账龄原值',
    typeNamePlural: '账龄原值',
    title: { type: #STANDARD, value: 'BR_ACC_COD' },
    description: { type: #STANDARD, value: 'BR_ACC_DES' }
  }
}
define root custom entity zc_query_FI007
{
      @UI.facet  : [
       {
         id      : 'GeneralInfo',
         purpose : #STANDARD,
         type    : #IDENTIFICATION_REFERENCE,
         label   : '基本信息',
         position: 10
       }
      ]

      @UI.hidden : true
  key UUID       : abap.char( 255 );

      @UI        : {
        lineItem : [{ position: 10 },
                      { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }],
        identification     : [{ position: 10 }],
        selectionField     : [{ position: 10 }]
      }
      @EndUserText.label   : '年份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ZZYEAR     : gjahr;

      @UI        : {
        lineItem : [{ position: 20 }],
        identification     : [{ position: 20 }],
        selectionField     : [{ position: 20 }]
      }
      @EndUserText.label   : '月份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ZZMONTH    : poper;

      @UI        : {
      lineItem   : [{ position: 30 }],
      identification     : [{ position: 30 }]
      }
      @EndUserText.label   : '集团统一公司代码'
      @ObjectModel.text.element     : [ 'GP_ENT_DES' ] //标记文本字段
      GP_ENT_COD : abap.char(4);

      @UI.hidden : true
      GP_ENT_DES : abap.char(100); //集团统一公司名称

      @UI        : {
        lineItem : [{ position: 40 }],
        identification     : [{ position: 40 }],
        selectionField     : [{ position: 40 }]
      }
      @EndUserText.label   : '核算系统公司'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @ObjectModel.text.element     : [ 'ENT_DES' ] //标记文本字段
      @Consumption.filter.mandatory: true
      ENT_COD    : bukrs;

      @UI.hidden : true
      ENT_DES    : butxt; //核算系统公司名称

      @UI        : {
        lineItem : [{ position: 50 }],
        identification     : [{ position: 50 }]
      }
      @EndUserText.label   : '集团统一科目'
      @ObjectModel.text.element     : [ 'GP_ACC_DES' ] //标记文本字段
      GP_ACC_COD : abap.char(20);

      @UI.hidden : true
      GP_ACC_DES : abap.char(100); //集团统一科目名称

      @UI        : {
        lineItem : [{ position: 60 }],
        identification     : [{ position: 60 }]
      }
      @EndUserText.label   : '核算系统科目'
      @ObjectModel.text.element     : [ 'BR_ACC_DES' ] //标记文本字段
      BR_ACC_COD : belnr_d;

      @UI.hidden : true
      BR_ACC_DES : txt20_skat; //核算系统科目名称

      @UI        : {
        lineItem : [{ position: 70 }],
        identification     : [{ position: 70 }]
      }
      @EndUserText.label   : '核算系统客商编码'
      @ObjectModel.text.element     : [ 'BR_CTP_DES' ] //标记文本字段
      BR_CTP_COD : kunnr;

      @UI.hidden : true
      BR_CTP_DES : text80; //核算系统客商名称

      @UI        : {
        lineItem : [{ position: 80 }],
        identification     : [{ position: 80 }]
      }
      @EndUserText.label   : '集团统一客商编码'
      @ObjectModel.text.element     : [ 'GP_CTP_DES' ] //标记文本字段
      GP_CTP_COD : abap.char(10);

      @UI.hidden : true
      GP_CTP_DES : abap.char(100); //集团统一客商名称

      @UI        : {
        lineItem : [{ position: 90 }],
        identification     : [{ position: 90 }]
      }
      @EndUserText.label   : '时间区间'
      TD         : abap.char(10);

      @UI.hidden : true
      CURRENCY   : waers; //币种（本位币）

      @UI        : {
        lineItem : [{ position: 100 }],
        identification     : [{ position: 100 }]
      }
      @EndUserText.label   : '期末余额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      AMOUNT     : dmbtr;

      @UI        : {
        lineItem : [{ position: 110 }],
        identification     : [{ position: 110 }]
      }
      @EndUserText.label   : '业务系统'
      SYS_ID     : abap.char( 20 );

      @UI.hidden : true
      DATEUPD    : abap.char(14);
}

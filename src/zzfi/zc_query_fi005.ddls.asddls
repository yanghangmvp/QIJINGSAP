@EndUserText.label: '科目余额'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI005'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '科目余额',
    typeNamePlural: '科目余额',
    title: { type: #STANDARD, value: 'BR_ACC_COD' },
    description: { type: #STANDARD, value: 'BR_ACC_DES' }
  }
}
define root custom entity zc_query_FI005
{
      @UI.facet    : [
       {
         id        : 'GeneralInfo',
         purpose   : #STANDARD,
         type      : #IDENTIFICATION_REFERENCE,
         label     : '基本信息',
         position  : 10
       }
      ]

      @UI.hidden   : true
  key UUID         : abap.char( 255 );

      @UI          : {
        lineItem   : [{ position: 10 },
                      { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }],
        identification     : [{ position: 10 }],
        selectionField     : [{ position: 10 }]
      }
      @EndUserText.label   : '年份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ZZYEAR       : gjahr;

      @UI          : {
        lineItem   : [{ position: 20 }],
        identification     : [{ position: 20 }],
        selectionField     : [{ position: 20 }]
      }
      @EndUserText.label   : '月份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ZZMONTH      : poper;

      @UI          : {
        lineItem   : [{ position: 30 }],
        identification     : [{ position: 30 }],
        selectionField     : [{ position: 30 }]
      }
      @EndUserText.label   : '核算系统公司'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @ObjectModel.text.element     : [ 'BR_ENT_DES' ] //标记文本字段
      @Consumption.filter.mandatory: true
      BR_ENT_COD   : bukrs;

      @UI          : {
        lineItem   : [{ position: 40 }],
        identification     : [{ position: 40 }]
      }
      @EndUserText.label   : '业务系统'
      SYS_ID       : abap.char( 20 );

      @UI          : {
        lineItem   : [{ position: 50 }],
        identification     : [{ position: 50 }]
      }
      @EndUserText.label   : '核算系统科目'
      @ObjectModel.text.element     : [ 'BR_ACC_DES' ] //标记文本字段
      BR_ACC_COD   : belnr_d;

      @UI          : {
        lineItem   : [{ position: 60 }],
        identification     : [{ position: 60 }]
      }
      @EndUserText.label   : '集团统一公司'
      @ObjectModel.text.element     : [ 'GP_ENT_DES' ] //标记文本字段
      GP_ENT_COD   : abap.char(4);

      @UI.hidden   : true
      GP_ENT_DES   : abap.char(100); //集团统一公司名称

      @UI.hidden   : true
      BR_ENT_DES   : butxt; //核算系统公司名称

      @UI          : {
        lineItem   : [{ position: 70 }],
        identification     : [{ position: 70 }]
      }
      @EndUserText.label   : '集团统一科目'
      @ObjectModel.text.element     : [ 'GP_ACC_DES' ] //标记文本字段
      GP_ACC_COD   : abap.char(20);

      @UI.hidden   : true
      GP_ACC_DES   : abap.char(100); //集团统一科目名称

      @UI.hidden   : true
      BR_ACC_DES   : txt20_skat; //核算系统科目名称
      
      @UI         : {
      lineItem    : [{ position: 75 }],
      identification     : [{ position: 75 }]
      }
      @EndUserText.label   : '功能范围'
      BR_ACC_AREA : fkber;

      @UI.hidden   : true
      CURRENCY     : waers; //币种（本位币）

      @UI          : {
        lineItem   : [{ position: 80 }],
        identification     : [{ position: 80 }]
      }
      @EndUserText.label   : '年初余额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      BEGINBL_Y    : dmbtr;

      @UI          : {
        lineItem   : [{ position: 90 }],
        identification     : [{ position: 90 }]
      }
      @EndUserText.label   : '期初余额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      BEGINBL      : dmbtr;

      @UI          : {
        lineItem   : [{ position: 100 }],
        identification     : [{ position: 100 }]
      }
      @EndUserText.label   : '本期借方金额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      DEBITBL      : dmbtr;

      @UI          : {
        lineItem   : [{ position: 110 }],
        identification     : [{ position: 110 }]
      }
      @EndUserText.label   : '本期贷方金额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      CREDITBL     : dmbtr;

      @UI          : {
        lineItem   : [{ position: 120 }],
        identification     : [{ position: 130 }]
      }
      @EndUserText.label   : '借方累计金额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      DEBITBL_A    : dmbtr;

      @UI          : {
        lineItem   : [{ position: 130 }],
        identification     : [{ position: 130 }]
      }
      @EndUserText.label   : '贷方累计金额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      CREDITBL_A   : dmbtr;

      @UI          : {
        lineItem   : [{ position: 140 }],
        identification     : [{ position: 140 }]
      }
      @EndUserText.label   : '期末余额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      ENDBL        : dmbtr;

      @UI.hidden   : true
      CURRENCY_T   : waers; //币种（交易货币）

      @UI          : {
        lineItem   : [{ position: 150 }],
        identification     : [{ position: 150 }]
      }
      @EndUserText.label   : '年初余额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      BEGINBL_Y_T  : dmbtr;

      @UI          : {
        lineItem   : [{ position: 160 }],
        identification     : [{ position: 160 }]
      }
      @EndUserText.label   : '期初余额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      BEGINBL_T    : dmbtr;

      @UI          : {
        lineItem   : [{ position: 170 }],
        identification     : [{ position: 170 }]
      }
      @EndUserText.label   : '本期借方金额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      DEBITBL_T    : dmbtr;

      @UI          : {
        lineItem   : [{ position: 180 }],
        identification     : [{ position: 180 }]
      }
      @EndUserText.label   : '本期贷方金额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      CREDITBL_T   : dmbtr;

      @UI          : {
        lineItem   : [{ position: 190 }],
        identification     : [{ position: 190 }]
      }
      @EndUserText.label   : '借方累计金额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      DEBITBL_A_T  : dmbtr;

      @UI          : {
        lineItem   : [{ position: 200 }],
        identification     : [{ position: 200 }]
      }
      @EndUserText.label   : '贷方累计金额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      CREDITBL_A_T : dmbtr;

      @UI          : {
        lineItem   : [{ position: 210 }],
        identification     : [{ position: 210 }]
      }
      @EndUserText.label   : '期末余额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      ENDBL_T      : dmbtr;

      @UI.hidden   : true
      DATEUPD      : abap.char(14);

}

@EndUserText.label: '凭证明细'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI003'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '凭证明细',
    typeNamePlural: '凭证明细',
    title: { type: #STANDARD, value: 'VOUCHER' },
    description: { type: #STANDARD, value: 'LINE' }
  }
}
define root custom entity zc_query_FI003
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
                      { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }],
        identification     : [{ position: 10 }],
        selectionField     : [{ position: 10 }]
      }
      @EndUserText.label   : '年份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ZZYEAR      : gjahr;

      @UI         : {
      lineItem    : [{ position: 20 }],
      identification     : [{ position: 20 }],
      selectionField     : [{ position: 20 }]
      }
      @EndUserText.label   : '月份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      ZZMONTH     : poper;

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
      LINE        : buzei;

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
      @EndUserText.label   : '集团统一公司代码'
      @ObjectModel.text.element     : [ 'GP_ENT_DES' ] //标记文本字段
      GP_ENT_COD  : abap.char(4);

      @UI.hidden  : true
      GP_ENT_DES  : abap.char(100); //集团统一公司名称

      @UI.hidden  : true
      ENT_DES     : butxt; //核算系统公司名称

      @UI         : {
      lineItem    : [{ position: 100 }],
      identification     : [{ position: 100 }]
      }
      @EndUserText.label   : '过账日期'
      @Consumption.filter.selectionType: #INTERVAL
      POST_DATE   : budat;

      @UI         : {
      lineItem    : [{ position: 110 }],
      identification     : [{ position: 110 }]
      }
      @EndUserText.label   : '凭证日期'
      DOC_DATE    : bldat;

      @UI         : {
      lineItem    : [{ position: 120 }],
      identification     : [{ position: 120 }]
      }
      @EndUserText.label   : '借贷方向'
      DIRECTION   : abap.char(2);

      @UI         : {
      lineItem    : [{ position: 130 }],
      identification     : [{ position: 130 }]
      }
      @EndUserText.label   : '集团统一科目'
      @ObjectModel.text.element     : [ 'GP_ACC_DES' ] //标记文本字段
      GP_ACC_COD  : abap.char(20);

      @UI.hidden  : true
      GP_ACC_DES  : abap.char(100); //集团统一科目名称

      @UI         : {
      lineItem    : [{ position: 150 }],
      identification     : [{ position: 150 }]
      }
      @EndUserText.label   : '核算系统入账科目'
      @ObjectModel.text.element     : [ 'BR_ACC_DES' ] //标记文本字段
      BR_ACC_COD  : hkont;

      @UI.hidden  : true
      BR_ACC_DES  : txt20_skat; //核算系统入账科目名称

      @UI         : {
      lineItem    : [{ position: 160 }],
      identification     : [{ position: 160 }]
      }
      @EndUserText.label   : '功能范围'
      BR_ACC_AREA : fkber;

      @UI         : {
      lineItem    : [{ position: 170 }],
      identification     : [{ position: 170 }]
      }
      @EndUserText.label   : '核算系统客商主键'
      BR_CTP_KEY  : kunnr;

      @UI         : {
      lineItem    : [{ position: 180 }],
      identification     : [{ position: 180 }]
      }
      @EndUserText.label   : '核算系统客户'
      @ObjectModel.text.element     : [ 'BR_CUS_DES' ] //标记文本字段
      BR_CUS_COD  : kunnr;

      @UI.hidden  : true
      BR_CUS_DES  : abap.char(80); //核算系统客户名称

      @UI         : {
      lineItem    : [{ position: 200 }],
      identification     : [{ position: 200 }]
      }
      @EndUserText.label   : '集团统一客商'
      @ObjectModel.text.element     : [ 'GP_CTP_DES' ] //标记文本字段
      GP_CTP_COD  : rassc;

      @UI.hidden  : true
      GP_CTP_DES  : abap.char(100); //集团统一客商名称

      @UI         : {
      lineItem    : [{ position: 220 }],
      identification     : [{ position: 220 }]
      }
      @EndUserText.label   : '统一社会信用代码'
      CREDIT_NUM  : stceg;

      @UI         : {
      lineItem    : [{ position: 230 }],
      identification     : [{ position: 230 }]
      }
      @EndUserText.label   : '核算系统供应商'
      @ObjectModel.text.element     : [ 'BR_SUP_DES' ] //标记文本字段
      BR_SUP_COD  : lifnr;

      @UI.hidden  : true
      BR_SUP_DES  : abap.char(80); //核算系统供应商名称

      @UI         : {
      lineItem    : [{ position: 250 }],
      identification     : [{ position: 250 }]
      }
      @EndUserText.label   : '变动维度'
      ZZMOVE      : abap.char(10);

      @UI         : {
      lineItem    : [{ position: 260 }],
      identification     : [{ position: 260 }]
      }
      @EndUserText.label   : '现金流量编码'
      CF_COD      : abap.char(3);

      @UI         : {
      lineItem    : [{ position: 270 }],
      identification     : [{ position: 270 }]
      }
      @EndUserText.label   : '摘要'
      TEXT        : sgtxt;

      @UI.hidden  : true
      CURRENCY    : hwaer;

      @UI         : {
      lineItem    : [{ position: 290 }],
      identification     : [{ position: 290 }]
      }
      @EndUserText.label   : '金额（本位币）'
      @Semantics.amount.currencyCode : 'CURRENCY'
      AMOUNT      : dmbtr;

      @UI.hidden  : true
      CURRENCY_T  : waers;

      @UI         : {
      lineItem    : [{ position: 310 }],
      identification     : [{ position: 310 }]
      }
      @EndUserText.label   : '金额（交易货币）'
      @Semantics.amount.currencyCode : 'CURRENCY_T'
      AMOUNT_T    : wrbtr;

      @UI.hidden  : true
      DATEUPD     : abap.char(14);
}

@EndUserText.label: '司库银行科目余额推送'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI009'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '司库科目余额推送',
    typeNamePlural: '司库科目余额推送',
    title: { value: 'glaccount' },
    description: { value: 'glaccountname' }
}
}
define root custom entity ZC_QUERY_FI009
{
      @UI.facet     : [
      {
       id           : 'GeneralInfo',
       purpose      : #STANDARD,
       type         : #IDENTIFICATION_REFERENCE,
       label        : '基本信息',
       position     : 10
      }
      ]

      @UI.hidden    : true
  key UUID          : abap.char( 255 );

      @UI           : {
        lineItem    : [{ position: 10 },
                      { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }],
        identification     : [{ position: 10 }],
        selectionField     : [{ position: 10 }]
      }
      @EndUserText.label   : '查询日期'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true   
      postdate   : budat;      
      @UI           : {
        lineItem    : [{ position: 20 }],
        identification     : [{ position: 20 }],
        selectionField     : [{ position: 20 }]
      }
      @EndUserText.label   : '公司编码'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @Consumption.filter.mandatory: true
      companycode   : bukrs;
      @UI           : {
        lineItem    : [{ position: 30 }],
        identification     : [{ position: 30 }]
      }
      @EndUserText.label   : '公司名称'
      companyname   : butxt;
      @UI           : {
        lineItem    : [{ position: 40 }],
        identification     : [{ position: 40 }]
      }
      @EndUserText.label   : '会计科目编码'
      glaccount     : saknr;
      @UI           : {
      lineItem      : [{ position: 50 }],
      identification: [{ position: 50 }]
      }
      @EndUserText.label   : '会计科目名称'
      glaccountname : txt20_skat;
      @UI           : {
      lineItem      : [{ position: 60 }],
      identification: [{ position: 60 }]
      }
      @EndUserText.label   : '银行帐户'
      bankaccount   : abap.char( 50 );
      @UI           : {
      lineItem      : [{ position: 70 }],
      identification: [{ position: 70 }]
      }
      @EndUserText.label   : '原币币种'
      currency      : waers;
      @UI           : {
      lineItem      : [{ position: 80 }],
      identification: [{ position: 80 }]
      }
      @EndUserText.label   : '期初余额'
      @Semantics.amount.currencyCode : 'CURRENCY'
      beginBalance  : dmbtr;
      @UI           : {
      lineItem      : [{ position: 90 }],
      identification: [{ position: 90 }]
      }
      @EndUserText.label   : '期初余额方向'
      beginDirect   : abap.char( 1 );
      @UI           : {
      lineItem      : [{ position: 100 }],
      identification: [{ position: 100 }]
      }
      @EndUserText.label   : '期末余额'
      @Semantics.amount.currencyCode : 'CURRENCY'
      endBalance    : dmbtr;
      @UI           : {
      lineItem      : [{ position: 110 }],
      identification: [{ position: 110 }]
      }
      @EndUserText.label   : '期末余额方向'
      endDirect     : abap.char( 1 );
  //     @UI           : {
  //   lineItem      : [{ position: 120 }],
  //    identification: [{ position: 120 }]
  //    }
  //    @EndUserText.label   : '余额日期'
  //    balanceDate   : abap.dats;
      @UI           : {
      lineItem      : [{ position: 130 }],
      identification: [{ position: 130 }]
      }
      @EndUserText.label   : '时间戳'
      timestamp     : timestamp;


}

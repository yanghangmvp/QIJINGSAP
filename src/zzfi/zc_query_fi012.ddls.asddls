@EndUserText.label: '司库银行日记账凭证推送'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI012'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '司库银行日记账凭证推送',
    typeNamePlural: '司库银行日记账凭证推送',
    title: { value: 'AccountingDocument' },
    description: { value: 'LedgerGLLineItem' }
}
}
define root custom entity ZC_QUERY_FI012
{
      @UI.facet                  : [
      {
       id                        : 'GeneralInfo',
       purpose                   : #STANDARD,
       type                      : #IDENTIFICATION_REFERENCE,
       label                     : '基本信息',
       position                  : 10
      }
      ]

      @UI.hidden                 : true
  key UUID                       : abap.char( 255 );
      @UI                        : {
        lineItem                 : [{ position: 10 },
                      { type     : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }],
        identification           : [{ position: 10 }],
        selectionField           : [{ position: 10 }]
      }
      @EndUserText.label         : '过账日期'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      postdate                   : budat;
      @UI                        : {
        lineItem                 : [{ position: 20 }],
        identification           : [{ position: 20 }],
        selectionField           : [{ position: 20 }]
      }
      @EndUserText.label         : '公司编码'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @Consumption.filter.mandatory: true
      companycode                : bukrs;
      @UI                        : {
      lineItem                   : [{ position: 30 }],
      identification             : [{ position: 30 }]
      }
      @EndUserText.label         : '数据来源'
      datasource                 : zzedatasource; 
      @UI                        : {
      lineItem                   : [{ position: 40 }],
      identification             : [{ position: 40 }]
      }
      @EndUserText.label         : '来源系统唯一标识'
      reference1indocumentheader : zzdrefheader; 
      @UI                        : {
        lineItem                 : [{ position: 50 }],
        identification           : [{ position: 50 }]
      }
      @EndUserText.label         : '总账科目'
      glaccount                  : saknr;
      @UI                        : {
      lineItem                   : [{ position: 60 }],
      identification             : [{ position: 60 }]
      }
      @EndUserText.label         : '业务范围'
      BusinessArea               : gsber; 
//      @UI                        : {
//      lineItem                   : [{ position: 70 }],
//      identification             : [{ position: 70 }]
//      }
//      @EndUserText.label         : '记账日期'
//      PostingDate                : budat; 
      @UI                        : {
      lineItem                   : [{ position: 70 }],
      identification             : [{ position: 70 }]
      }
      @EndUserText.label         : '录入日期'
      CreationDate               : budat; 
      @UI                        : {
      lineItem                   : [{ position: 80 }],
      identification             : [{ position: 80 }]
      }
      @EndUserText.label         : '会计凭证号'
      AccountingDocument         : belnr_d; 
      @UI                        : {
      lineItem                   : [{ position: 90 }],
      identification             : [{ position: 90 }]
      }
      @EndUserText.label         : '会计凭证行号'
      LedgerGLLineItem           : abap.char( 6 );       
      @UI                        : {
      lineItem                   : [{ position: 100 }],
      identification             : [{ position: 100 }]
      }
      @EndUserText.label         : '冲销会计凭证号'
      ReversalReferenceDocument  : belnr_d; 
      @UI                        : {
      lineItem                   : [{ position: 110 }],
      identification             : [{ position: 110 }]
      }
      @EndUserText.label         : '本方银行帐号'
      bankaccount                : abap.char( 50 );
      @UI                        : {
      lineItem                   : [{ position: 120 }],
      identification             : [{ position: 120 }]
      }
      @EndUserText.label         : '货币类别'
      currency                   : waers;
      @UI                        : {
      lineItem                   : [{ position: 130 }],
      identification             : [{ position: 130 }]
      }
      @EndUserText.label         : '借贷方向'
      DebitCreditCode            : shkzg; 
      @UI                        : {
      lineItem                   : [{ position: 140 }],
      identification             : [{ position: 140 }]
      }
      @EndUserText.label         : '借方金额'
      @Semantics.amount.currencyCode : 'CURRENCY'
      DebitAmountInTransCrcy     : dmbtr;
      @UI                        : {
      lineItem                   : [{ position: 150 }],
      identification             : [{ position: 150 }]
      }
      @EndUserText.label         : '贷方金额'
      @Semantics.amount.currencyCode : 'CURRENCY'
      CreditAmountInTransCrcy    : dmbtr;
      @UI                        : {
      lineItem                   : [{ position: 160 }],
      identification             : [{ position: 160 }]
      }
      @EndUserText.label         : '凭证摘要'
      DocumentItemText           : bktxt; 
      @UI                        : {
      lineItem                   : [{ position: 170 }],
      identification             : [{ position: 170 }]
      }
      @EndUserText.label         : '记账类型'
      AccountingDocumentType     : blart; 
      @UI                        : {
      lineItem                   : [{ position: 180 }],
      identification             : [{ position: 180 }]
      }
      @EndUserText.label         : '记账会计'
      AccountingDocCreatedByUser : usnam; 
      @UI                        : {
      lineItem                   : [{ position: 190 }],
      identification             : [{ position: 190 }]
      }
      @EndUserText.label         : '时间戳'
      timestamp                  : timestamp;


}

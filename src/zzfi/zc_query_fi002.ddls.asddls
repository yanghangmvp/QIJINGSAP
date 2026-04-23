@EndUserText.label: '客商主数据'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI002'
@UI: {
  headerInfo: {
    typeName: '客商主数据',
    typeNamePlural: '客商主数据',
    title: { value: 'BR_CTP_KEY' },
    description: { value: 'BR_CTP_DES' }
  }
}
define root custom entity zc_query_FI002
{
      @UI.facet    : [
       {
         id        : 'BR_CTP_KEY',
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
        identification     : [{ position: 10 }]
      }
      @EndUserText.label   : '客商类别'
      TYPE         : abap.char( 1 );

      @UI          : {
        lineItem   : [{ position: 20 }],
        identification     : [{ position: 20 }]
      }
      @EndUserText.label   : '核算系统客商键值'
      BR_CTP_KEY   : kunnr;

      @UI          : {
        lineItem   : [{ position: 30 }],
        identification     : [{ position: 30 }]
      }
      @EndUserText.label   : '核算系统客商编码'
      BR_CTP_COD   : kunnr;

      @UI          : {
        lineItem   : [{ position: 40 }],
        identification     : [{ position: 40 }]
      }
      @EndUserText.label   : '核算系统'
      SYS_ID       : abap.char( 20 );

      @UI          : {
        lineItem   : [{ position: 50 }],
        identification     : [{ position: 50 }]
      }
      @EndUserText.label   : '核算系统客商名称'
      BR_CTP_DES   : text80;

      @UI          : {
        lineItem   : [{ position: 60 }],
        identification     : [{ position: 60 }]
      }
      @EndUserText.label   : '统一社会信用代码'
      CREDIT_NUM   : stceg;

      @UI          : {
        lineItem   : [{ position: 70 }],
        identification     : [{ position: 70 }]
      }
      @EndUserText.label   : '国家'
      COUNTRY      : land1;

      @UI          : {
        lineItem   : [{ position: 80 }],
        identification     : [{ position: 80 }]
      }
      @EndUserText.label   : '城市'
      CITY         : text35;

      @UI          : {
        lineItem   : [{ position: 90 }],
        identification     : [{ position: 90 }]
      }
      @EndUserText.label   : '企业性质'
      PROPERTY     : abap.char( 20 );

      @UI          : {
        selectionField     : [{ position: 100 }]
      }
      @EndUserText.label   : '公司代码'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @Consumption.filter.mandatory: true
      CompanyCode  : bukrs;

      @UI          : {
        selectionField     : [{ position: 110 }]
      }
      @Consumption.filter.selectionType: #INTERVAL
      @EndUserText.label   : '创建日期'
      CreationDate : erdat_rf;

      @UI.hidden   : true
      DATEUPD      : abap.char(14);
}

@EndUserText.label: '现金流量表-V1'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI001'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['ItemText'] //设置列高亮

@UI: {
  headerInfo: {
    typeName: '现金流量表',
    typeNamePlural: '现金流量表',
    title: { type: #STANDARD, value: 'ItemText' },
    description: { type: #STANDARD, value: 'ItemText' }
  }
}
define custom entity zc_query_FI001
{
      @UI.facet            : [
           {
             id            : 'GeneralInfo',
             purpose       : #STANDARD,
             type          : #IDENTIFICATION_REFERENCE,
             label         : '基本信息',
             position      : 10
           }
         ]

       // 公司代码
      @UI                  : {
        selectionField     : [{ position: 10 }]
      }
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @EndUserText.label   : '公司代码'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
  key CompanyCode          : bukrs;

      @UI                  : {
          selectionField   : [{ position: 20 }]
        }
      @EndUserText.label   : '期间从'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @Consumption.valueHelpDefinition: [
      { entity             :  { name:    'I_FiscalCalendarDate',
                    element: 'FiscalYearPeriod'
                  }
      }]
      //      @Consumption.derivation: { lookupEntity: 'I_FiscalCalendarDate',
      //                               resultElement: 'FiscalYearPeriod',
      //                               binding:      [ { targetElement : 'CalendarDate'      , type : #SYSTEM_FIELD,  value : '#SYSTEM_DATE' } ,
      //                                               { targetElement : 'FiscalYearVariant' , type : #CONSTANT  ,  value : 'K4'     } ]
      //                              }
  key FiscalYearPeriodFrom : fins_fyearperiod;
      @UI                  : {
              selectionField     : [{ position: 30 }]
            }
      @EndUserText.label   : '期间至'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @Consumption.valueHelpDefinition: [
      { entity             :  { name:    'I_FiscalCalendarDate',
                    element: 'FiscalYearPeriod'
                  }
      }]
      //      @Consumption.derivation: { lookupEntity: 'I_FiscalCalendarDate',
      //                               resultElement: 'FiscalYearPeriod',
      //                               binding:      [ { targetElement : 'CalendarDate'      , type : #SYSTEM_FIELD,  value : '#SYSTEM_DATE' } ,
      //                                               { targetElement : 'FiscalYearVariant' , type : #CONSTANT  ,  value : 'K4'     } ]
      //                              }
  key FiscalYearPeriodTo   : fins_fyearperiod;
      //项目
      @UI                  : {
        lineItem           : [{ position: 10 }],
        identification     : [{ position: 10 }],
        hidden             :true
      }
      @EndUserText.label   : '项目'
  key ItemNo               : zzefiitem;
      //项目
      @UI                  : {
        lineItem           : [{ position: 20 }],
        identification     : [{ position: 20 }]
      }
      @EndUserText.label   : '项目'
  key ItemText             : zzefitext;
      //本期金额
      @UI                  : {
        lineItem           : [{ position: 30 }],
        identification     : [{ position: 30 }]
      }
      @EndUserText.label   : '本期金额'
      Amount               : abap.dec( 21 , 6 );
      //上年同期金额
      @UI                  : {
        lineItem           : [{ position: 40 }],
        identification     : [{ position: 40 }]
      }
      @EndUserText.label   : '上年同期金额'
      AmountLastYear       : abap.dec( 21 , 6 );
}

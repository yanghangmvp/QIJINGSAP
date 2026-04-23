@EndUserText.label: '回款类型'
define root abstract entity ZA_POP_FI007_HKLX
{
  @EndUserText.label            : '回款类型'
  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZR_VH_REYPE_DATASOURCE' , element: 'value' }, useForValidation: true}]
  receivablestype : zzereceivablestype;
  @EndUserText.label            : '账户类型'
  @Consumption.valueHelpDefinition: [{ entity: {name: 'ZR_VH_ACCOUNTTYPE_DATASOURCE' , element: 'value' }, useForValidation: true}]
  Accounttype     : zzeaccounttype;
  @EndUserText.label            : '客商编码'
  @Consumption.valueHelpDefinition: [{ entity: {name: 'I_customer_VH' , element: 'Customer' }, useForValidation: true}]
  merchantnumber  : kunnr;
  @EndUserText.label            : '门店编码'
  @Consumption.valueHelpDefinition: [ { entity: {name: 'ZR_VH_STORE' , element: 'BPCustomerNumber' },
  additionalBinding: [{
               localElement   : 'merchantnumber',  // 值帮助的字段
               element        : 'Customer',   // 当前实体的字段
               usage          : #FILTER            // 用于过滤值帮助结果
              }]}

   ]
  storecode       : kunnr;
}

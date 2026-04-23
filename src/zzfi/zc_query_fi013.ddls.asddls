@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: '固定资产变动明细表',
    typeNamePlural: '固定资产变动明细表',
    title: { type: #STANDARD, value: 'zzxm' },
    description: { type: #STANDARD, value: 'zzxm' }
  }
}
@ObjectModel.semanticKey: ['zzxm'] //设置列高亮
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI013'
@EndUserText.label: '固定资产变动明细表'

define root custom entity zc_query_fi013
{

      @UI.hidden: true
  key uuid    : abap.int1;
      @UI.lineItem    : [{ position: 10 }]
      @EndUserText.label   : '项目'
      zzxm    : abap.char(50);
      @UI.lineItem    : [{ position: 20 }]
      @EndUserText.label   : '房屋及建筑物'
      line01  : abap.dec(13,2);
      @UI.lineItem    : [{ position: 30 }]
      @EndUserText.label   : '机器设备'
      line02  : abap.dec(13,2);
      @UI.lineItem    : [{ position: 40 }]
      @EndUserText.label   : '运输工具'
      line03  : abap.dec(13,2);
      @UI.lineItem    : [{ position: 50 }]
      @EndUserText.label   : '办公设备'
      line04  : abap.dec(13,2);
      @UI.lineItem    : [{ position: 60 }]
      @EndUserText.label   : '模具'
      line05  : abap.dec(13,2);
      @UI.lineItem    : [{ position: 70 }]
      @EndUserText.label   : '其他设备'
      line06  : abap.dec(13,2);
      @UI.lineItem    : [{ position: 80 }]
      @EndUserText.label   : '合计'
      total   : abap.dec(13,2);

      @UI     : {  selectionField     : [{ position: 10 }] }
      @EndUserText.label   : '公司代码'
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                     element: 'CompanyCode' }
                                        }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      bukrs   : bukrs;
      @UI     : {  selectionField     : [{ position: 20 }] }
      @EndUserText.label   : '年份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      zzyear  : gjahr;
      @UI     : {  selectionField     : [{ position: 30 }] }
      @EndUserText.label   : '月份'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      zzpoper : poper;
}

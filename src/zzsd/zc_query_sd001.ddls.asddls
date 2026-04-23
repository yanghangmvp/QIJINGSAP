@EndUserText.label: '客户主数据'
@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_SD001'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['Customer'] //设置列高亮

@UI: {
  headerInfo: {
    typeName: '客户主数据',
    typeNamePlural: '客户主数据',
    title: { type: #STANDARD, value: 'Customer' },
    description: { type: #STANDARD, value: 'Customer' }
  }
}

define root custom entity zc_query_sd001
{
      @UI.identification          : [ { position: 10 } ]
      @UI.lineItem                : [ { position: 10 } ,
                                      { type : #FOR_ACTION, dataAction: 'zpush', label: '推送数据', invocationGrouping: #CHANGE_SET }]
      @UI.selectionField          : [ { position: 10 } ]
      @EndUserText.label          : '客户编号'
      @Consumption.semanticObject : 'BusinessPartner'
  key Customer                    : kunnr;

      @UI.identification          : [ { position: 20 } ]
      @UI.lineItem                : [ { position: 20 } ]
      @EndUserText.label          : '客户名称'
      CustomerName                : abap.char(80);
      @UI.identification          : [ { position: 30 } ]
      @UI.lineItem                : [ { position: 30 } ]
      @EndUserText.label          : '业务伙伴类别'
      BusinessPartnerCategory     : abap.char(1);
      @UI.identification          : [ { position: 40 } ]
      @UI.lineItem                : [ { position: 40 } ]
      @EndUserText.label          : '业务伙伴分组'
      BusinessPartnerGrouping     : abap.char(4);
      @UI.identification          : [ { position: 50 } ]
      @UI.lineItem                : [ { position: 50 } ]
      @EndUserText.label          : '业务伙伴分组名称'
      BusinessPartnerGroupingText : abap.char(20);
      @UI.identification          : [ { position: 60 } ]
      @UI.lineItem                : [ { position: 60 } ]
      @EndUserText.label          : '科目组'
      CustomerAccountGroup        : abap.char(4);


      @UI.identification          : [ { position: 65 } ]
      @UI.lineItem                : [ { position: 65 } ]
      @EndUserText.label          : 'DUNS编号'
      BPIdentificationNumber      : abap.char(60);
      @UI.identification          : [ { position: 68 } ]
      @UI.lineItem                : [ { position: 68 } ]
      @EndUserText.label          : '销售组织'
      SalesOrganization           : vkorg;

      @UI.identification          : [ { position: 70 } ]
      @UI.lineItem                : [ { position: 70 } ]
      @EndUserText.label          : '搜索项1'
      AddressSearchTerm1          : abap.char(20);
      @UI.identification          : [ { position: 80 } ]
      @UI.lineItem                : [ { position: 80 } ]
      @EndUserText.label          : '国家代码'
      Country                     : abap.char(3);
      @UI.identification          : [ { position: 90 } ]
      @UI.lineItem                : [ { position: 90 } ]
      @EndUserText.label          : '地区编码'
      Region                      : abap.char(3);
      @UI.identification          : [ { position: 100 } ]
      @UI.lineItem                : [ { position: 100 } ]
      @EndUserText.label          : '地区名称'
      RegionName                  : abap.char(20);
      @UI.identification          : [ { position: 110 } ]
      @UI.lineItem                : [ { position: 110 } ]
      @EndUserText.label          : '街道'
      StreetName                  : abap.char(35);
      @UI.identification          : [ { position: 130 } ]
      @UI.lineItem                : [ { position: 130 } ]
      @EndUserText.label          : '邮政编码'
      PostalCode                  : abap.char(6);
      @UI.identification          : [ { position: 140 } ]
      @UI.lineItem                : [ { position: 140 } ]
      @EndUserText.label          : '城市'
      CityName                    : abap.char(35);
      @UI.identification          : [ { position: 150 } ]
      @UI.lineItem                : [ { position: 150 } ]
      @EndUserText.label          : '语言'
      Language                    : abap.char(1);
      @UI.identification          : [ { position: 160 } ]
      @UI.lineItem                : [ { position: 160 } ]
      @EndUserText.label          : '固定电话'
      PhoneNumber1                : abap.char(16);
      @UI.identification          : [ { position: 170 } ]
      @UI.lineItem                : [ { position: 170 } ]
      @EndUserText.label          : '移动电话'
      PhoneNumber2                : abap.char(16);
      @UI.identification          : [ { position: 180 } ]
      @UI.lineItem                : [ { position: 180 } ]
      @EndUserText.label          : '传真'
      FaxNumber                   : abap.char(20);
      @UI.identification          : [ { position: 190 } ]
      @UI.lineItem                : [ { position: 190 } ]
      @EndUserText.label          : '邮箱'
      EmailAddress                : abap.char(100);
      @UI.identification          : [ { position: 200 } ]
      @UI.lineItem                : [ { position: 200 } ]
      @EndUserText.label          : '税类别'
      TaxNumberType               : abap.char(5);
      @UI.identification          : [ { position: 210 } ]
      @UI.lineItem                : [ { position: 210 } ]
      @EndUserText.label          : '税号'
      TaxNumberResponsible        : abap.char(20);

      @UI.identification          : [ { position: 215 } ]
      @UI.lineItem                : [ { position: 215 } ]
      @EndUserText.label          : '主店代码'
      BPCustomerNumber            : abap.char(10);
      @UI.identification          : [ { position: 220 } ]
      @UI.lineItem                : [ { position: 220 } ]
      @EndUserText.label          : '订单货币'
      PurchaseOrderCurrency       : abap.char(5);
      @UI.identification          : [ { position: 230 } ]
      @UI.lineItem                : [ { position: 230 } ]
      @EndUserText.label          : '银行明细标识'
      BankIdentification          : abap.char(3);
      @UI.identification          : [ { position: 240 } ]
      @UI.lineItem                : [ { position: 240 } ]
      @EndUserText.label          : '银行国家'
      BankCountryKey              : abap.char(15);
      @UI.identification          : [ { position: 250 } ]
      @UI.lineItem                : [ { position: 250 } ]
      @EndUserText.label          : '银行代码'
      BankNumber                  : abap.char(20);
      @UI.identification          : [ { position: 255 } ]
      @UI.lineItem                : [ { position: 255 } ]
      @EndUserText.label          : '银行名称'
      BankName                    : abap.char(30);
      @UI.identification          : [ { position: 260 } ]
      @UI.lineItem                : [ { position: 260 } ]
      @EndUserText.label          : '账户持有人'
      BankAccountHolderName       : abap.char(60);
      @UI.identification          : [ { position: 270 } ]
      @UI.lineItem                : [ { position: 270 } ]
      @EndUserText.label          : '银行账户'
      BankAccount                 : abap.char(18);
      @UI.identification          : [ { position: 280 } ]
      @UI.lineItem                : [ { position: 280 } ]
      @EndUserText.label          : '参考细节'
      BankAccountReferenceText    : abap.char(20);
      @UI.identification          : [ { position: 290 } ]
      @UI.lineItem                : [ { position: 290 } ]
      @EndUserText.label          : '银行完整账号'
      BankAccountFull             : abap.char(40);
      @UI.identification          : [ { position: 300 } ]
      @UI.lineItem                : [ { position: 300 } ]
      @EndUserText.label          : '上次更改时间'
      LastChangeDateTime          : abp_lastchange_tstmpl;
}

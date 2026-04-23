@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '门店搜索帮助'
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #XL
@ObjectModel.usageType.dataClass: #MASTER
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_VH_STORE
  as select from    I_CustSalesPartnerFunc as a
    left outer join I_Customer             as md on md.Customer = a.BPCustomerNumber
    left outer join I_Customer             as kh on kh.Customer = a.Customer
{
      @UI.lineItem: [ { position: 10  } ]
      @ObjectModel.text.element: ['khCustomerName']
      @EndUserText.label            : '客户编码'
  key a.Customer,
      @UI.lineItem: [ { position: 30  } ]
      @ObjectModel.text.element: ['mdCustomerName']
      @EndUserText.label            : '门店编码'
  key a.BPCustomerNumber,
      @UI.lineItem: [ { position: 20  } ]
      @EndUserText.label            : '客户名称'
      kh.CustomerName as khCustomerName,
      @UI.lineItem: [ { position: 40  } ]
      @EndUserText.label            : '门店名称'
      md.CustomerName as mdCustomerName
}

where
      a.SalesOrganization = 'GH00'
  and a.PartnerFunction   = 'WE'

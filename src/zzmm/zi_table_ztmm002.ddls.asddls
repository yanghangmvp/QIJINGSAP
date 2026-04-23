@EndUserText.label: '物料主数据配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TABLE_Ztmm002
  as select from zztmm002
  association        to parent ZI_TABLE_Ztmm002_S    as _Ztmm002All                 on $projection.SingletonID = _Ztmm002All.SingletonID
  association [0..*] to I_ConfignDeprecationCodeText as _ConfignDeprecationCodeText on $projection.ConfigDeprecationCode = _ConfignDeprecationCodeText.ConfigurationDeprecationCode
{
  key producttype                                                                                     as Producttype,
  key plant                                                                                           as Plant,
      industrysector                                                                                  as Industrysector,
      productgroup                                                                                    as Productgroup,
      division                                                                                        as Division,
      productsalesorg                                                                                 as Productsalesorg,
      productdistributionchnl                                                                         as Productdistributionchnl,
      supplyingplant                                                                                  as Supplyingplant,
      country                                                                                         as Country,
      taxcategory                                                                                     as Taxcategory,
      taxclassification                                                                               as Taxclassification,
      pricespecificationproductgroup                                                                  as Pricespecificationproductgroup,
      accountdetnproductgroup                                                                         as Accountdetnproductgroup,
      conventionalitemcategorygroup                                                                   as Conventionalitemcategorygroup,
      itemcategorygroup                                                                               as Itemcategorygroup,
      transportationgroup                                                                             as Transportationgroup,
      loadinggroup                                                                                    as Loadinggroup,
      serialnumberprofile                                                                             as Serialnumberprofile,
      purchasinggroup                                                                                 as Purchasinggroup,
      isautopurordcreationallowed                                                                     as Isautopurordcreationallowed,
      profilecode                                                                                     as Profilecode,
      issourcelistrequired                                                                            as Issourcelistrequired,
      manufacturerpartprofile                                                                         as Manufacturerpartprofile,
      isbatchmanagementrequired                                                                       as Isbatchmanagementrequired,
      procurementtype                                                                                 as Procurementtype,
      procurementsubtype                                                                              as Procurementsubtype,
      productioninvtrymanagedloc                                                                      as Productioninvtrymanagedloc,
      dfltstoragelocationextprocmt                                                                    as Dfltstoragelocationextprocmt,
      mrptype                                                                                         as Mrptype,
      dependentrequirementstype                                                                       as Dependentrequirementstype,
      availabilitychecktype                                                                           as Availabilitychecktype,
      mrpresponsible                                                                                  as Mrpresponsible,
      lotsizingprocedure                                                                              as Lotsizingprocedure,
      valuationarea                                                                                   as Valuationarea,
      currency                                                                                        as Currency,
      inventoryvaluationprocedure                                                                     as Inventoryvaluationprocedure,
      priceunitqty                                                                                    as Priceunitqty,
      valuationclass                                                                                  as Valuationclass,
      pricedeterminationcontrol                                                                       as Pricedeterminationcontrol,
      costinglotsize                                                                                  as Costinglotsize,
      productiscostingrelevant                                                                        as Productiscostingrelevant,
      ismaterialcostedwithqtystruc                                                                    as Ismaterialcostedwithqtystruc,
      ismaterialrelatedorigin                                                                         as Ismaterialrelatedorigin,
      profitcenter                                                                                    as Profitcenter,
      @ObjectModel.text.association: '_ConfignDeprecationCodeText'
      @Consumption.valueHelpDefinition: [ {
        entity: {
          name: 'I_ConfignDeprecationCode',
          element: 'ConfigurationDeprecationCode'
        },
        useForValidation: true
      } ]
      configdeprecationcode                                                                           as ConfigDeprecationCode,
      @Semantics.user.createdBy: true
      created_by                                                                                      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                                                                      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                                                                                 as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                                                                 as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.hidden: true
      local_last_changed_at                                                                           as LocalLastChangedAt,
      @Consumption.hidden: true
      1                                                                                               as SingletonID,
      _Ztmm002All,
      case when configdeprecationcode = 'W' then 2 when configdeprecationcode = 'E' then 1 else 3 end as ConfigDeprecationCode_Critlty,
      _ConfignDeprecationCodeText
}

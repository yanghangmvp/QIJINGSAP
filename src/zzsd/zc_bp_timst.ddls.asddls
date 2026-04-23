@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BP更改时间戳'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_BP_TIMST
  as select from I_BusinessPartner as bp
{
  key bp.BusinessPartner,
      case bp.LastChangeDate when '00000000'
      then cast (dats_tims_to_tstmp( bp.CreationDate,bp.CreationTime,'UTC',$session.client,'NULL' )  as timestampl )
      else cast (dats_tims_to_tstmp( bp.LastChangeDate,bp.LastChangeTime,'UTC',$session.client,'NULL' ) as timestampl )
      end as LastChangeDateTime
}

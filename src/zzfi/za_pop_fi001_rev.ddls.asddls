@EndUserText.label: '冲销'
define root abstract entity ZA_POP_FI001_REV
{
  @EndUserText.label            : '冲销原因'
  @Consumption.valueHelpDefinition: [{ entity: {name: 'I_ReversalReasonValueHelp' , element: 'ReversalReason' }, useForValidation: true}]
  @UI.defaultValue:'01'
  ReversalReason : stgrd;
  @EndUserText.label            : '过账日期'
  PostingDate    : budat;
}

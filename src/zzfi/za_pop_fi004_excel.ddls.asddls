@EndUserText.label: '综合管理维度-前台传入数据'
define abstract entity ZA_POP_FI004_EXCEL
{
  fiscalyear         : gjahr;
  companycode        : bukrs;
  accountingdocument : belnr_d;
  ledgergllineitem   : abap.char(6);
  zzitemtype         : zzeitemtype;
  zzcode             : zzecode;
  zzdefault          : abap.char(200);
  zzdefault_dec      : abap.dec(27,9);

}

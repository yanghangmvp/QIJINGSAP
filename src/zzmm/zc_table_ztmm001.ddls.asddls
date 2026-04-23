@EndUserText.label: '复制 车型记录表'
define abstract entity ZC_TABLE_ZTMM001
{
  @EndUserText.label: '新建 车型'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Modelcode' )
  Modelcode : ZZEMODELCODE;
}

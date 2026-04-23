@EndUserText.label: '复制 科目与变动维度映射表'
define abstract entity ZD_table_Ztfi009
{
  @EndUserText.label: '新建 总账科目'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Glaccount' )
  Glaccount : SAKNR;
}

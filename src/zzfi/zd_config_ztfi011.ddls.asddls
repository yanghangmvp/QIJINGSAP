@EndUserText.label: '复制 综合管理维度项目配置表'
define abstract entity ZD_config_Ztfi011
{
  @EndUserText.label: '新建 总账科目'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: GlaccountFrom' )
  GlaccountFrom : SAKNR;
  @EndUserText.label: '新建 总账科目'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: GlaccountTo' )
  GlaccountTo : SAKNR;
  @EndUserText.label: '新建 综合管理项目类型'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Zzitemtype' )
  Zzitemtype : ZZEITEMTYPE;
  @EndUserText.label: '新建 核算字段编码'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Zzcode' )
  Zzcode : ZZECODE;
}

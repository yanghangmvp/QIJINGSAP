@ObjectModel.query.implementedBy: 'ABAP:ZZCL_QUERY_FI008'
@Metadata.allowExtensions: true

@UI: {
  headerInfo: {
    typeName: '销售暂估收入过账',
    typeNamePlural: '销售暂估收入过账',
    title: { type: #STANDARD, value: 'deliverydocument' },
    description: { type: #STANDARD, value: 'deliverydocument' }
  }
}
@EndUserText.label: '销售暂估收入过账'
define root custom entity zc_query_fi008
{

      @UI.facet                    : [
        {
          id                       : 'GeneralInfo',
          purpose                  : #STANDARD,
          type                     : #IDENTIFICATION_REFERENCE,
          label                    : '基本信息',
          position                 : 10
        }
       ]

      @UI.hidden                   : true
      @UI.lineItem                 : [{ position: 01,type:#FOR_ACTION, dataAction: 'zzpost', label: '过账', invocationGrouping: #CHANGE_SET },
                                      { position: 02,type:#FOR_ACTION, dataAction: 'zzrev',  label: '冲销', invocationGrouping: #CHANGE_SET }]
  key uuid                         : abap.char(200);
      @UI.identification           : [ { position: 10 } ]
      @UI.lineItem                 : [ { position: 10 } ]
      @UI.selectionField           : [ { position: 10 } ]
      @Consumption.filter.mandatory: true
      @Consumption.filter.defaultValue : ''
      @EndUserText.label           : '是否已处理'
      hasitbeenprocessed           : abap_boolean;
      @UI.identification           : [ { position: 20 } ]
      @UI.lineItem                 : [ { position: 20 } ]
      @EndUserText.label           : '暂估收入日记账分录'
      @Consumption.semanticObject  : 'AccountingDocument'
      accountingdocument1          : belnr_d;
      @UI.identification           : [ { position: 30 } ]
      @UI.lineItem                 : [ { position: 30 } ]
      @EndUserText.label           : '暂估收入过账日期'
      postingdate1                 : budat;
      @UI.identification           : [ { position: 40 } ]
      @UI.lineItem                 : [ { position: 40 } ]
      @EndUserText.label           : '冲销暂估收入日记账分录'
      @Consumption.semanticObject  : 'AccountingDocument'
      accountingdocument2          : belnr_d;
      @UI.identification           : [ { position: 50 } ]
      @UI.lineItem                 : [ { position: 50 } ]
      @EndUserText.label           : '冲销暂估收入过账日期'
      postingdate2                 : budat;
      @UI.identification           : [ { position: 60 } ]
      @UI.lineItem                 : [ { position: 60 } ]
      @UI.selectionField           : [ { position: 20 } ]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @Consumption.filter.defaultValue : 'GH00'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH',
                                                element: 'CompanyCode' }
                                   }]
      @EndUserText.label           : '公司代码'
      companycode                  : bukrs;
      @UI.identification           : [ { position: 70 } ]
      @UI.lineItem                 : [ { position: 70 } ]
      @UI.selectionField           : [ { position: 30 } ]
      @EndUserText.label           : '会计年度'
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      fiscalyear                   : calendaryear;
      @UI.identification           : [ { position: 80 } ]
      @UI.lineItem                 : [ { position: 80 } ]
      @UI.selectionField           : [ { position: 40 } ]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
      @EndUserText.label           : '会计期间'
      fiscalperiod                 : calendarmonth;
      @UI.identification           : [ { position: 90 } ]
      @UI.lineItem                 : [ { position: 90 } ]
      @EndUserText.label           : '客户'
      soldtoparty                  : kunag;
      @UI.identification           : [ { position: 100 } ]
      @UI.lineItem                 : [ { position: 100 } ]
      @EndUserText.label           : '客户名称'
      customername                 : abap.char(30);
      @UI.identification           : [ { position: 110 } ]
      @UI.lineItem                 : [ { position: 110 } ]
      @EndUserText.label           : '交货单创建日期'
      creationdate                 : erdat;
      @UI.identification           : [ { position: 120 } ]
      @UI.lineItem                 : [ { position: 120 } ]
      @EndUserText.label           : '交货单'
      @Consumption.semanticObject  : 'OutboundDelivery'
      deliverydocument             : vbeln_vl;
      @UI.identification           : [ { position: 130 } ]
      @UI.lineItem                 : [ { position: 130 } ]
      @EndUserText.label           : '交货项目'
      deliverydocumentitem         : posnr_vl;
      @UI.identification           : [ { position: 140 } ]
      @UI.lineItem                 : [ { position: 140 } ]
      @EndUserText.label           : '工厂'
      plant                        : werks_d;
      @UI.identification           : [ { position: 150 } ]
      @UI.lineItem                 : [ { position: 150 } ]
      @EndUserText.label           : '物料'
      material                     : matnr;
      @UI.identification           : [ { position: 160 } ]
      @UI.lineItem                 : [ { position: 160 } ]
      @EndUserText.label           : '项目描述'
      deliverydocumentitemtext     : arktx;
      @UI.identification           : [ { position: 170 } ]
      @UI.lineItem                 : [ { position: 170 } ]
      @EndUserText.label           : '物料科目分配组'
      accountdetnproductgroup      : ktgrm;
      @UI.identification           : [ { position: 180 } ]
      @UI.lineItem                 : [ { position: 180 } ]
      @EndUserText.label           : 'POD状态'
      proofofdeliverystatus        : abap.char(1);
      @UI.identification           : [ { position: 190 } ]
      @UI.lineItem                 : [ { position: 190 } ]
      @EndUserText.label           : '交货相关开票状态'
      deliveryrelatedbillingstatus : abap.char(1);
      @UI.identification           : [ { position: 200 } ]
      @UI.lineItem                 : [ { position: 200 } ]
      @EndUserText.label           : '销售订单'
      @Consumption.semanticObject  : 'SalesDocument'
      referencesddocument          : vgbel;
      @UI.identification           : [ { position: 210 } ]
      @UI.lineItem                 : [ { position: 210 } ]
      @EndUserText.label           : '销售订单行项目'
      referencesddocumentitem      : vgpos;
      @UI.identification           : [ { position: 220 } ]
      @UI.lineItem                 : [ { position: 220 } ]
      @EndUserText.label           : '已交货数量'
      actualdeliveryquantity       : abap.dec(13,3);
      @UI.identification           : [ { position: 230 } ]
      @UI.lineItem                 : [ { position: 230 } ]
      @EndUserText.label           : '销售订单数量'
      orderquantity                : abap.dec(13,3);
      @UI.identification           : [ { position: 240 } ]
      @UI.lineItem                 : [ { position: 240 } ]
      @EndUserText.label           : '销售单位'
      deliveryquantityunit         : vrkme;
      @UI.identification           : [ { position: 250 } ]
      @UI.lineItem                 : [ { position: 250 } ]
      @EndUserText.label           : '销售收入（净值）'
      netamount                    : abap.dec(13,2);
      @UI.identification           : [ { position: 260 } ]
      @UI.lineItem                 : [ { position: 260 } ]
      @EndUserText.label           : '销售税额'
      taxamount                    : abap.dec(13,2);
      @UI.identification           : [ { position: 270 } ]
      @UI.lineItem                 : [ { position: 270 } ]
      @EndUserText.label           : '销售价税合计金额'
      totalsalesamount             : abap.dec(13,2);
      @UI.identification           : [ { position: 280 } ]
      @UI.lineItem                 : [ { position: 280 } ]
      @EndUserText.label           : '暂估收入（净值）'
      estimatedrevenue             : abap.dec(13,2);
      @UI.identification           : [ { position: 290 } ]
      @UI.lineItem                 : [ { position: 290 } ]
      @EndUserText.label           : '暂估税额'
      estimatedtaxamount           : abap.dec(13,2);
      @UI.identification           : [ { position: 300 } ]
      @UI.lineItem                 : [ { position: 300 } ]
      @EndUserText.label           : '暂估价税合计金额'
      estimatedtotalamount         : abap.dec(13,2);
      @UI.identification           : [ { position: 310 } ]
      @UI.lineItem                 : [ { position: 310 } ]
      @EndUserText.label           : '销售货币'
      transactioncurrency          : waers;


}

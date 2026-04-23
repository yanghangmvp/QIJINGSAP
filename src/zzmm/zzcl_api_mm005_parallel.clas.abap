CLASS zzcl_api_mm005_parallel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "接口传入结构
    TYPES: BEGIN OF ty_billheader,
             zguid         TYPE string,
             mtco          TYPE string,     "MTCO编码
             mtconame      TYPE string,     "MTCO描述
             positioncode  TYPE string,     "生产组织
             modelcode     TYPE string,     "车型编码
             configversion TYPE string,     "配置版本
             createtime    TYPE string,     "创建时间
             effouttime    TYPE string,     "失效时间
             salescode     TYPE string,     "销售代码
           END OF ty_billheader,
           BEGIN OF ty_bill,
             doflag     TYPE string,
             billheader TYPE ty_billheader,
           END OF ty_bill,
           BEGIN OF tty_bill,
             bill TYPE TABLE OF ty_bill WITH EMPTY KEY,
           END OF tty_bill,
           BEGIN OF ty_interface,
             interface TYPE tty_bill,
           END OF ty_interface.

    "物料主数据
    TYPES: BEGIN OF ty_description,
             product            TYPE string, "物料号
             language           TYPE string, "语言
             productdescription TYPE string, "描述
           END OF ty_description,
           BEGIN OF ty_descriptions,
             results TYPE TABLE OF ty_description WITH EMPTY KEY,
           END OF ty_descriptions,

           BEGIN OF ty_plantsales,
             product      TYPE string, "物料号
             plant        TYPE string, "工厂
             loadinggroup TYPE string, "装货组
           END OF ty_plantsales,

           BEGIN OF ty_productplantcosting,
             product                  TYPE string, "物料号
             plant                    TYPE string, "工厂
             costinglotsize           TYPE string, "成本核算批量
             productiscostingrelevant TYPE abap_bool, "不计算成本
           END OF ty_productplantcosting,

           BEGIN OF ty_productplantprocurement,
             product                     TYPE string, "物料号
             plant                       TYPE string, "工厂
             isautopurordcreationallowed TYPE abap_bool, "自动采购单
             issourcelistrequired        TYPE abap_bool, "源清单
           END OF ty_productplantprocurement,

           BEGIN OF ty_productsupplyplanning,
             product                      TYPE string, "物料号
             plant                        TYPE string, "工厂
             mrptype                      TYPE string, "MRP类型
             mrpresponsible               TYPE string, "MRP控制员
             lotsizingprocedure           TYPE string, "批量确定程序
             procurementtype              TYPE string, "采购类型
             procurementsubtype           TYPE string, "特殊采购类型
             availabilitychecktype        TYPE string, "可用性检查
             dfltstoragelocationextprocmt TYPE string, "采购库存地点
             dependentrequirementstype    TYPE string, "独立集中
           END OF ty_productsupplyplanning,

           BEGIN OF ty_plant,
             product                    TYPE string, "物料号
             plant                      TYPE string, "工厂
             purchasinggroup            TYPE string, "采购组
             productioninvtrymanagedloc TYPE string, "生产库存地点
             isbatchmanagementrequired  TYPE abap_bool, "批次管理-工厂
             profitcenter               TYPE string, "利润中心
             mrptype                    TYPE string, "MRP类型
             serialnumberprofile        TYPE string, "序列号参数文件
             profilevaliditystartdate   TYPE string, "特定物料状态生效日期
             to_plantsales              TYPE ty_plantsales,
             to_productplantcosting     TYPE ty_productplantcosting,
             to_productplantprocurement TYPE ty_productplantprocurement,
             to_productsupplyplanning   TYPE ty_productsupplyplanning,
           END OF ty_plant,
           BEGIN OF ty_plants,
             results TYPE TABLE OF ty_plant WITH EMPTY KEY,
           END OF ty_plants,

           BEGIN OF ty_productsales,
             product             TYPE string, "物料号
             transportationgroup TYPE string, "运输组
           END OF ty_productsales,

           BEGIN OF ty_salestax,
             product           TYPE string, "物料号
             country           TYPE string, "启运国
             taxcategory       TYPE string, "税收类型
             taxclassification TYPE string, "税分类
           END OF ty_salestax,
           BEGIN OF ty_salestaxs,
             results TYPE TABLE OF ty_salestax WITH EMPTY KEY,
           END OF ty_salestaxs,

           BEGIN OF ty_salesdelivery,
             product                        TYPE string, "物料号
             productsalesorg                TYPE string, "销售组织
             productdistributionchnl        TYPE string, "分销渠道
             supplyingplant                 TYPE string, "交货工厂
             pricespecificationproductgroup TYPE string, "物料价格组
             accountdetnproductgroup        TYPE string, "物料科目分配组
             itemcategorygroup              TYPE string, "项目类别组
             to_salestax                    TYPE ty_salestaxs,
           END OF ty_salesdelivery,
           BEGIN OF ty_salesdeliverys,
             results TYPE TABLE OF ty_salesdelivery WITH EMPTY KEY,
           END OF ty_salesdeliverys,

           BEGIN OF ty_valuationcosting,
             product                      TYPE string, "物料号
             valuationarea                TYPE string, "评估范围
             ismaterialcostedwithqtystruc TYPE abap_bool, "用QS的成本估算
             ismaterialrelatedorigin      TYPE string, "物料来源
           END OF ty_valuationcosting,

           BEGIN OF ty_valuation,
             product                     TYPE string, "物料号
             valuationarea               TYPE string, "评估范围
             valuationclass              TYPE string, "评估分类
             pricedeterminationcontrol   TYPE string, "价格确定
             priceunitqty                TYPE string, "价格单位
             inventoryvaluationprocedure TYPE string, "价格控制
             currency                    TYPE string, "货币
             to_valuationcosting         TYPE ty_valuationcosting,
           END OF ty_valuation,
           BEGIN OF ty_valuations,
             results TYPE TABLE OF ty_valuation WITH EMPTY KEY,
           END OF ty_valuations,

           BEGIN OF ty_product,
             product                   TYPE string, "物料号
             producttype               TYPE string, "物料类型
             productgroup              TYPE string, "物料组
             baseunit                  TYPE string, "基本单位
             itemcategorygroup         TYPE string, "常规项目类别组
             division                  TYPE string, "产品组
             isbatchmanagementrequired TYPE string, "批次管理
             manufacturerpartprofile   TYPE string, "制造商部件参数文件
             industrysector            TYPE string, "行业
             yy1_partver_prd           TYPE string, "物料名称
             yy1_modelcode_prd         TYPE string, "车型编码
             yy1_salescode_prd         TYPE string, "销售代码
             yy1_configversion_prd     TYPE string, "配置版本

             to_description            TYPE ty_descriptions,
             to_plant                  TYPE ty_plants,
             to_productsales           TYPE ty_productsales,
             to_salesdelivery          TYPE ty_salesdeliverys,
             to_valuation              TYPE ty_valuations,
           END OF ty_product,

           "修改
           BEGIN OF ty_product_u,
             yy1_partver_prd       TYPE string, "物料名称
             yy1_modelcode_prd     TYPE string, "车型编码
             yy1_salescode_prd     TYPE string, "销售代码
             yy1_configversion_prd TYPE string, "配置版本
           END OF ty_product_u,

           BEGIN OF ty_description_u,
             productdescription TYPE string, "描述
           END OF ty_description_u,

           BEGIN OF ty_plant_u,
             profilevaliditystartdate TYPE string, "特定物料状态生效日期
           END OF ty_plant_u,

           BEGIN OF ty_product_ud,
             d TYPE ty_product_u,
           END OF ty_product_ud,

           BEGIN OF ty_description_ud,
             d TYPE ty_description_u,
           END OF ty_description_ud,

           BEGIN OF ty_plant_ud,
             d TYPE ty_plant_u,
           END OF ty_plant_ud.

    TYPES: BEGIN OF ty_productplantbasic,
             product TYPE i_productplantbasic-product,
           END OF ty_productplantbasic.

    DATA: gt_productplantbasic TYPE TABLE OF ty_productplantbasic.

    DATA: gt_mapping       TYPE /ui2/cl_json=>name_mappings,
          gt_mapping_entry TYPE /ui2/cl_json=>name_mappings.

    DATA: gv_language TYPE i_language-languageisocode.

    DATA: gs_billheader TYPE ty_billheader.
    DATA: gs_resp TYPE zzs_rest_out.

    INTERFACES if_abap_parallel.

    METHODS:constructor
      IMPORTING is_billheader TYPE ty_billheader.

    METHODS zzcreate
      IMPORTING
        i_req  TYPE ty_billheader OPTIONAL.

    METHODS zzupdate
      IMPORTING
        i_req  TYPE ty_billheader OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm005_parallel IMPLEMENTATION.


  METHOD constructor.
    gt_mapping_entry = VALUE #(
         ( abap = 'doflag'     json = '@DoFlag'   )
     ).

    gt_mapping = VALUE #(
         ( abap = 'Product'                                   json = 'Product' )
         ( abap = 'ProductType'                               json = 'ProductType' )
         ( abap = 'ProductGroup'                              json = 'ProductGroup' )
         ( abap = 'BaseUnit'                                  json = 'BaseUnit' )
         ( abap = 'ItemCategoryGroup'                         json = 'ItemCategoryGroup' )
         ( abap = 'Division'                                  json = 'Division' )
         ( abap = 'IsBatchManagementRequired'                 json = 'IsBatchManagementRequired' )
         ( abap = 'ManufacturerPartProfile'                   json = 'ManufacturerPartProfile' )
         ( abap = 'IndustrySector'                            json = 'IndustrySector' )
         ( abap = 'to_Description'                            json = 'to_Description' )
         ( abap = 'results'                                   json = 'results' )
         ( abap = 'Language'                                  json = 'Language' )
         ( abap = 'ProductDescription'                        json = 'ProductDescription' )
         ( abap = 'to_Plant'                                  json = 'to_Plant' )
         ( abap = 'Plant'                                     json = 'Plant' )
         ( abap = 'PurchasingGroup'                           json = 'PurchasingGroup' )
         ( abap = 'ProductionInvtryManagedLoc'                json = 'ProductionInvtryManagedLoc' )
         ( abap = 'ProfitCenter'                              json = 'ProfitCenter' )
         ( abap = 'MRPType'                                   json = 'MRPType' )
         ( abap = 'SerialNumberProfile'                       json = 'SerialNumberProfile' )
         ( abap = 'to_PlantSales'                             json = 'to_PlantSales' )
         ( abap = 'LoadingGroup'                              json = 'LoadingGroup' )
         ( abap = 'to_ProductPlantCosting'                    json = 'to_ProductPlantCosting' )
         ( abap = 'CostingLotSize'                            json = 'CostingLotSize' )
         ( abap = 'to_ProductPlantProcurement'                json = 'to_ProductPlantProcurement' )
         ( abap = 'IsAutoPurOrdCreationAllowed'               json = 'IsAutoPurOrdCreationAllowed' )
         ( abap = 'IsSourceListRequired'                      json = 'IsSourceListRequired' )
         ( abap = 'to_ProductSupplyPlanning'                  json = 'to_ProductSupplyPlanning' )
         ( abap = 'MRPResponsible'                            json = 'MRPResponsible' )
         ( abap = 'LotSizingProcedure'                        json = 'LotSizingProcedure' )
         ( abap = 'ProcurementType'                           json = 'ProcurementType' )
         ( abap = 'ProcurementSubType'                        json = 'ProcurementSubType' )
         ( abap = 'AvailabilityCheckType'                     json = 'AvailabilityCheckType' )
         ( abap = 'DfltStorageLocationExtProcmt'              json = 'DfltStorageLocationExtProcmt' )
         ( abap = 'DependentRequirementsType'                 json = 'DependentRequirementsType' )
         ( abap = 'to_ProductSales'                           json = 'to_ProductSales' )
         ( abap = 'TransportationGroup'                       json = 'TransportationGroup' )
         ( abap = 'to_SalesTax'                               json = 'to_SalesTax' )
         ( abap = 'Country'                                   json = 'Country' )
         ( abap = 'TaxCategory'                               json = 'TaxCategory' )
         ( abap = 'TaxClassification'                         json = 'TaxClassification' )
         ( abap = 'to_SalesDelivery'                          json = 'to_SalesDelivery' )
         ( abap = 'ProductSalesOrg'                           json = 'ProductSalesOrg' )
         ( abap = 'ProductDistributionChnl'                   json = 'ProductDistributionChnl' )
         ( abap = 'SupplyingPlant'                            json = 'SupplyingPlant' )
         ( abap = 'PriceSpecificationProductGroup'            json = 'PriceSpecificationProductGroup' )
         ( abap = 'AccountDetnProductGroup'                   json = 'AccountDetnProductGroup' )
         ( abap = 'to_Valuation'                              json = 'to_Valuation' )
         ( abap = 'ValuationArea'                             json = 'ValuationArea' )
         ( abap = 'ValuationClass'                            json = 'ValuationClass' )
         ( abap = 'PriceDeterminationControl'                 json = 'PriceDeterminationControl' )
         ( abap = 'PriceUnitQty'                              json = 'PriceUnitQty' )
         ( abap = 'InventoryValuationProcedure'               json = 'InventoryValuationProcedure' )
         ( abap = 'Currency'                                  json = 'Currency' )
         ( abap = 'to_ValuationCosting'                       json = 'to_ValuationCosting' )
         ( abap = 'IsMaterialCostedWithQtyStruc'              json = 'IsMaterialCostedWithQtyStruc' )
         ( abap = 'IsMaterialRelatedOrigin'                   json = 'IsMaterialRelatedOrigin' )
         ( abap = 'ProfileCode'                               json = 'ProfileCode' )
         ( abap = 'ProfileValidityStartDate'                  json = 'ProfileValidityStartDate' )
         ( abap = 'YY1_PartStatusDesc_PRD'                    json = 'YY1_PartStatusDesc_PRD' )
         ( abap = 'YY1_HardwareCode_PRD'                      json = 'YY1_HardwareCode_PRD' )
         ( abap = 'YY1_ConfigVersion_PRD'                     json = 'YY1_ConfigVersion_PRD' )
         ( abap = 'YY1_RawNum_PRD'                            json = 'YY1_RawNum_PRD' )
         ( abap = 'YY1_ModelCtrCode_PRD'                      json = 'YY1_ModelCtrCode_PRD' )
         ( abap = 'YY1_Cost_PRD'                              json = 'YY1_Cost_PRD' )
         ( abap = 'YY1_SoftwareCode_PRD'                      json = 'YY1_SoftwareCode_PRD' )
         ( abap = 'YY1_Weight_PRD'                            json = 'YY1_Weight_PRD' )
         ( abap = 'YY1_PartVer_PRD'                           json = 'YY1_PartVer_PRD' )
         ( abap = 'YY1_KeyPart_PRD'                           json = 'YY1_KeyPart_PRD' )
         ( abap = 'YY1_ModelCode_PRD'                         json = 'YY1_ModelCode_PRD' )
         ( abap = 'YY1_PartType_PRD'                          json = 'YY1_PartType_PRD' )
         ( abap = 'YY1_MaterialType_PRD'                      json = 'YY1_MaterialType_PRD' )
         ( abap = 'YY1_PartVer_en_PRD'                        json = 'YY1_PartVer_en_PRD' )
         ( abap = 'YY1_SALESCODE_PRD'                         json = 'YY1_SALESCODE_PRD' )
         ( abap = 'd'                                         json = 'd' )

     ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = @sy-langu
      INTO @gv_language.

    gs_billheader = is_billheader.
  ENDMETHOD.


  METHOD if_abap_parallel~do.

    SELECT COUNT(*)
      FROM i_product WITH PRIVILEGED ACCESS
     WHERE productexternalid = @gs_billheader-mtco.

    IF sy-subrc <> 0.
      me->zzcreate(
        EXPORTING
            i_req = gs_billheader
      ).
    ELSE.
      me->zzupdate(
        EXPORTING
            i_req = gs_billheader
      ).
    ENDIF.

    gs_resp-uuid = gs_billheader-zguid.
  ENDMETHOD.

  METHOD zzcreate.

    DATA: ls_product       TYPE ty_product,
          lt_description   TYPE TABLE OF ty_description,
          ls_description   TYPE ty_description,
          lt_plant         TYPE TABLE OF ty_plant,
          ls_plant         TYPE ty_plant,
          lt_salestax      TYPE TABLE OF ty_salestax,
          ls_salestax      TYPE ty_salestax,
          lt_salesdelivery TYPE TABLE OF ty_salesdelivery,
          ls_salesdelivery TYPE ty_salesdelivery,
          lt_valuation     TYPE TABLE OF ty_valuation,
          ls_valuation     TYPE ty_valuation.

    DATA: lv_modelcode TYPE zzemodelcode.

    DATA: ls_billheader TYPE ty_billheader.

    DATA: lv_null(2) TYPE c VALUE 'NA'.

    DATA: lv_json TYPE string.

    DATA: lv_productdescription(40) TYPE c.
    DATA: lv_datum TYPE string.

    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

    ls_billheader = i_req.

    IF ls_billheader-modelcode IS INITIAL.
      gs_resp-msgty = 'E'.
      gs_resp-msgtx = '请传入车型'.
      RETURN.
    ELSE.
      lv_modelcode = ls_billheader-modelcode.
    ENDIF.

    "检查自建表中是否有传入车型
    SELECT COUNT(*)
      FROM zztmm001 WITH PRIVILEGED ACCESS
     WHERE modelcode = @lv_modelcode.
    IF sy-subrc <> 0.
      gs_resp-msgty = 'S'.
      gs_resp-msgtx = '无关车型，不需要处理'.
      RETURN.
    ENDIF.

    "获取全部工厂
    SELECT plant
      FROM i_plant WITH PRIVILEGED ACCESS
      INTO TABLE @DATA(lt_iplant).
    SORT lt_iplant BY plant.

    "查找对应工厂的配置值
    SELECT *
      FROM zztmm002 WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_iplant
     WHERE producttype = 'Z001'
       AND plant = @lt_iplant-plant
      INTO TABLE @DATA(lt_zztmm002).
    SORT lt_zztmm002 BY plant.

    CLEAR: ls_product.
    CLEAR: lt_description, lt_plant, lt_salestax, lt_salesdelivery, lt_valuation.

    IF ls_billheader-mtconame IS NOT INITIAL.
      CLEAR: ls_description, lv_productdescription.
      lv_productdescription = ls_billheader-mtconame.
      ls_description-product = ls_billheader-mtco.                   "物料号
      ls_description-language = 'ZH'.                                "语言
      ls_description-productdescription = lv_productdescription.     "中文描述
      APPEND ls_description TO lt_description.
    ENDIF.

    LOOP AT lt_zztmm002 INTO DATA(ls_zztmm002).
      DATA(ls_save) = ls_zztmm002.

      CLEAR: ls_plant.
      ls_plant-product                    = ls_billheader-mtco.                   "物料号
      ls_plant-plant                      = ls_save-plant.                        "工厂
      ls_plant-purchasinggroup            = ls_save-purchasinggroup.              "采购组
      ls_plant-productioninvtrymanagedloc = ls_save-productioninvtrymanagedloc.   "生产库存地点
      ls_plant-isbatchmanagementrequired  = ls_save-isbatchmanagementrequired.    "批次管理-工厂
      ls_plant-profitcenter               = ls_save-profitcenter.                 "利润中心
      ls_plant-mrptype                    = ls_save-mrptype.                      "MRP类型
      ls_plant-serialnumberprofile        = ls_save-serialnumberprofile.          "序列号参数文件

      "特定物料状态生效日期
*      IF ls_billheader-effouttime IS NOT INITIAL.
*        lv_datum = ls_billheader-effouttime+0(4) && ls_billheader-effouttime+5(2) && ls_billheader-effouttime+8(2).
*        ls_plant-profilevaliditystartdate = zzcl_comm_tool=>date2iso(
*                                                iv_date = lv_datum ).
*      ENDIF.

      ls_plant-to_plantsales-product      = ls_billheader-mtco.                   "物料号
      ls_plant-to_plantsales-plant        = ls_save-plant.                        "工厂
      ls_plant-to_plantsales-loadinggroup = ls_save-loadinggroup.                 "装货组

      ls_plant-to_productplantcosting-product                  = ls_billheader-mtco.                  "物料号
      ls_plant-to_productplantcosting-plant                    = ls_save-plant.                       "工厂
      ls_plant-to_productplantcosting-costinglotsize           = ls_save-priceunitqty.              "成本核算批量
      CONDENSE ls_plant-to_productplantcosting-costinglotsize NO-GAPS.
      ls_plant-to_productplantcosting-productiscostingrelevant = ls_save-productiscostingrelevant.    "不计算成本

      ls_plant-to_productplantprocurement-product                     = ls_billheader-mtco.                   "物料号
      ls_plant-to_productplantprocurement-plant                       = ls_save-plant.                        "工厂
      ls_plant-to_productplantprocurement-isautopurordcreationallowed = ls_save-isautopurordcreationallowed.  "自动采购单
      ls_plant-to_productplantprocurement-issourcelistrequired        = ls_save-issourcelistrequired.         "源清单

      ls_plant-to_productsupplyplanning-product                      = ls_billheader-mtco.                    "物料号
      ls_plant-to_productsupplyplanning-plant                        = ls_save-plant.                         "工厂
      ls_plant-to_productsupplyplanning-mrptype                      = ls_save-mrptype.                       "MRP类型
      ls_plant-to_productsupplyplanning-mrpresponsible               = ls_save-mrpresponsible.                "MRP控制员
      ls_plant-to_productsupplyplanning-lotsizingprocedure           = ls_save-lotsizingprocedure.            "批量确定程序
      ls_plant-to_productsupplyplanning-procurementtype              = ls_save-procurementtype.               "采购类型
      ls_plant-to_productsupplyplanning-procurementsubtype           = ls_save-procurementsubtype.            "特殊采购类型
      ls_plant-to_productsupplyplanning-availabilitychecktype        = ls_save-availabilitychecktype.         "可用性检查
      ls_plant-to_productsupplyplanning-dfltstoragelocationextprocmt = ls_save-dfltstoragelocationextprocmt.  "采购库存地点
      ls_plant-to_productsupplyplanning-dependentrequirementstype    = ls_save-dependentrequirementstype.     "独立集中
      APPEND ls_plant TO lt_plant.

      IF ls_save-productdistributionchnl IS NOT INITIAL.
        CLEAR: ls_salestax, lt_salestax.
        ls_salestax-product           = ls_billheader-mtco.          "物料号
        ls_salestax-country           = ls_save-country.             "启运国
        ls_salestax-taxcategory       = ls_save-taxcategory.         "税收类型
        ls_salestax-taxclassification = ls_save-taxclassification.   "税分类
        APPEND ls_salestax TO lt_salestax.

        CLEAR: ls_salesdelivery.
        ls_salesdelivery-product                        = ls_billheader-mtco.                     "物料号
        ls_salesdelivery-productsalesorg                = ls_save-productsalesorg.                "销售组织
        ls_salesdelivery-productdistributionchnl        = ls_save-productdistributionchnl.        "分销渠道
        ls_salesdelivery-supplyingplant                 = ls_save-supplyingplant.                 "交货工厂
        ls_salesdelivery-pricespecificationproductgroup = ls_save-pricespecificationproductgroup. "物料价格组
        ls_salesdelivery-accountdetnproductgroup        = ls_save-accountdetnproductgroup.        "物料科目分配组
        ls_salesdelivery-itemcategorygroup              = ls_save-itemcategorygroup.              "项目类别组
        ls_salesdelivery-to_salestax-results            = lt_salestax.
        APPEND ls_salesdelivery TO lt_salesdelivery.
      ENDIF.

      CLEAR: ls_valuation.
      ls_valuation-product                     = ls_billheader-mtco.                    "物料号
      ls_valuation-valuationarea               = ls_save-valuationarea.                 "评估范围
      ls_valuation-valuationclass              = ls_save-valuationclass.                "评估分类
      ls_valuation-pricedeterminationcontrol   = ls_save-pricedeterminationcontrol.     "价格确定
      ls_valuation-priceunitqty                = ls_save-priceunitqty.                  "价格单位
      CONDENSE ls_valuation-priceunitqty NO-GAPS.
      ls_valuation-inventoryvaluationprocedure = ls_save-inventoryvaluationprocedure.   "价格控制
      ls_valuation-currency                    = ls_save-currency.                      "货币

      ls_valuation-to_valuationcosting-product                      = ls_billheader-mtco.                   "物料号
      ls_valuation-to_valuationcosting-valuationarea                = ls_save-valuationarea.                "评估范围
      ls_valuation-to_valuationcosting-ismaterialcostedwithqtystruc = ls_save-ismaterialcostedwithqtystruc. "用QS的成本估算
      ls_valuation-to_valuationcosting-ismaterialrelatedorigin      = ls_save-ismaterialrelatedorigin.      "物料来源
      APPEND ls_valuation TO lt_valuation.

      AT LAST.

        ls_product-product                             = ls_billheader-mtco.                      "物料号
        ls_product-producttype                         = ls_save-producttype.                     "物料类型
        ls_product-productgroup                        = ls_save-productgroup.                    "物料组
        ls_product-baseunit                            = 'PCS'.                                   "基本单位
        IF ls_save-productdistributionchnl IS NOT INITIAL.
          ls_product-itemcategorygroup                   = ls_save-conventionalitemcategorygroup. "常规项目类别组
        ENDIF.
        ls_product-division                            = ls_save-division.                        "产品组
        ls_product-isbatchmanagementrequired           = ls_save-isbatchmanagementrequired.       "批次管理
        ls_product-manufacturerpartprofile             = ls_save-manufacturerpartprofile.         "制造商部件参数文件
        ls_product-industrysector                      = ls_save-industrysector.                  "行业
        ls_product-yy1_partver_prd                     = ls_billheader-mtconame.                  "物料名称
        ls_product-yy1_modelcode_prd                   = ls_billheader-modelcode.                 "车型编码
        ls_product-yy1_salescode_prd                   = ls_billheader-salescode.                 "销售代码
        ls_product-yy1_configversion_prd               = ls_billheader-configversion.             "配置版本

        ls_product-to_description-results              = lt_description.
        ls_product-to_plant-results                    = lt_plant.

        ls_product-to_productsales-product             = ls_billheader-mtco.                      "物料号
        ls_product-to_productsales-transportationgroup = ls_save-transportationgroup.             "运输组

        ls_product-to_salesdelivery-results            = lt_salesdelivery.
        ls_product-to_valuation-results                = lt_valuation.


      ENDAT.

    ENDLOOP.

*&---接口http 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_PRODUCT_SRV/A_Product?sap-language=zh|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).

        lo_request->set_content_type( 'application/json' ).
        "传入数据转JSON
        lv_json = /ui2/cl_json=>serialize(
              data          = ls_product
              compress      = abap_true
              name_mappings = gt_mapping ).

        lo_request->set_text( lv_json ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code = '201'.
          gs_resp-msgty  = 'S'.
          gs_resp-msgtx  = 'success'.
          gs_resp-sapnum = ls_billheader-mtco.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          gs_resp-msgty = 'E'.
          gs_resp-sapnum = ls_billheader-mtco.
          LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
            gs_resp-msgtx = gs_resp-msgtx && '/' && ls_errordetails-message.
          ENDLOOP.

        ENDIF.

        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD zzupdate.
    DATA: ls_product     TYPE ty_product_ud,
          ls_description TYPE ty_description_ud,
          ls_plant       TYPE ty_plant_ud.

    DATA: ls_billheader TYPE ty_billheader.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    DATA: lv_json TYPE string.
    DATA: lv_productdescription(40) TYPE c.
    DATA: lv_modelcode TYPE zzemodelcode.
    DATA: lv_datum TYPE string.

    ls_billheader = i_req.

    IF ls_billheader-modelcode IS INITIAL.
      gs_resp-msgty = 'E'.
      gs_resp-msgtx = '请传入车型'.
      RETURN.
    ELSE.
      lv_modelcode = ls_billheader-modelcode.
    ENDIF.

    "检查自建表中是否有传入车型
    SELECT COUNT(*)
      FROM zztmm001 WITH PRIVILEGED ACCESS
     WHERE modelcode = @lv_modelcode.
    IF sy-subrc <> 0.
      gs_resp-msgty = 'S'.
      gs_resp-msgtx = '无关车型，不需要处理'.
      RETURN.
    ENDIF.

    "修改增强字段
    CLEAR: ls_product.
    ls_product-d-yy1_partver_prd       = ls_billheader-mtconame.                  "物料名称
    ls_product-d-yy1_modelcode_prd     = ls_billheader-modelcode.                 "车型编码
    ls_product-d-yy1_salescode_prd     = ls_billheader-salescode.                 "销售代码
    ls_product-d-yy1_configversion_prd = ls_billheader-configversion.             "配置版本

    IF ls_product-d IS NOT INITIAL.
*&---接口http 链接调用
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_uri_path) = |/API_PRODUCT_SRV/A_Product('{ ls_billheader-mtco }')?sap-language=zh|.
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
          lo_http_client->set_csrf_token(  ).

          lo_request->set_content_type( 'application/json' ).
          "传入数据转JSON
          lv_json = /ui2/cl_json=>serialize(
                data          = ls_product
                compress      = abap_true
                name_mappings = gt_mapping ).

          lo_request->set_text( lv_json ).

*&---执行http patch 方法
          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>patch ).
*&---获取http reponse 数据
          DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
          DATA(status) = lo_response->get_status( ).
          IF status-code <> '204'.
            DATA:ls_rese TYPE zzs_odata_fail.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_rese ).
            gs_resp-msgty = 'E'.
            LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
              gs_resp-msgtx = gs_resp-msgtx && '/' && ls_errordetails-message.
            ENDLOOP.

          ENDIF.

          lo_http_client->close( ).
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          RETURN.
      ENDTRY.

    ENDIF.

    "修改描述
    IF ls_billheader-mtconame IS NOT INITIAL.
      CLEAR: ls_description, lv_productdescription.
      lv_productdescription = ls_billheader-mtconame.
      ls_description-d-productdescription = lv_productdescription.
*&---接口http 链接调用
      TRY.
          lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          lo_request = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          lv_uri_path = |/API_PRODUCT_SRV/A_ProductDescription(Product='{ ls_billheader-mtco }',Language='ZH')?sap-language=zh|.
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
          lo_http_client->set_csrf_token(  ).

          lo_request->set_content_type( 'application/json' ).
          "传入数据转JSON
          lv_json = /ui2/cl_json=>serialize(
                data          = ls_description
                compress      = abap_true
                name_mappings = gt_mapping ).

          lo_request->set_text( lv_json ).

*&---执行http patch 方法
          lo_response = lo_http_client->execute( if_web_http_client=>patch ).
*&---获取http reponse 数据
          lv_res = lo_response->get_text(  ).
*&---确定http 状态
          status = lo_response->get_status( ).
          IF status-code <> '204'.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_rese ).
            gs_resp-msgty = 'E'.
            LOOP AT ls_rese-error-innererror-errordetails INTO ls_errordetails WHERE severity = 'error'.
              gs_resp-msgtx = gs_resp-msgtx && '/' && ls_errordetails-message.
            ENDLOOP.

          ENDIF.

          lo_http_client->close( ).
        CATCH cx_web_http_client_error INTO lx_web_http_client_error.
          RETURN.
      ENDTRY.
    ENDIF.

    "修改特定物料状态生效日期
*    IF ls_billheader-effouttime IS NOT INITIAL.
*      READ TABLE gt_productplantbasic TRANSPORTING NO FIELDS WITH KEY product = ls_billheader-mtco BINARY SEARCH.
*      IF sy-subrc = 0.
*        LOOP AT gt_productplantbasic INTO DATA(ls_productplantbasic) FROM sy-tabix.
*          IF ls_productplantbasic-product = ls_billheader-mtco.
*
*            CLEAR: ls_plant.
*            lv_datum = ls_billheader-effouttime+0(4) && ls_billheader-effouttime+5(2) && ls_billheader-effouttime+8(2).
*            ls_plant-d-profilevaliditystartdate = zzcl_comm_tool=>date2iso(
*                                                      iv_date = lv_datum ).
**&---接口http 链接调用
*            TRY.
*                lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
*                lo_request = lo_http_client->get_http_request(   ).
*                lo_http_client->enable_path_prefix( ).
*
*                lv_uri_path = |/API_PRODUCT_SRV/A_ProductDescription(Product='{ ls_billheader-mtco }',Plant='{ ls_productplantbasic-plant }')?sap-language=zh|.
*                lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
*                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
*                "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
*                lo_http_client->set_csrf_token(  ).
*
*                lo_request->set_content_type( 'application/json' ).
*                "传入数据转JSON
*                lv_json = /ui2/cl_json=>serialize(
*                      data          = ls_plant
*                      compress      = abap_true
*                      name_mappings = gt_mapping ).
*
*                lo_request->set_text( lv_json ).
*
**&---执行http patch 方法
*                lo_response = lo_http_client->execute( if_web_http_client=>patch ).
**&---获取http reponse 数据
*                lv_res = lo_response->get_text(  ).
**&---确定http 状态
*                status = lo_response->get_status( ).
*                IF status-code <> '204'.
*                  /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
*                                              CHANGING data  = ls_rese ).
*                  o_resp-msgty = 'E'.
*                  LOOP AT ls_rese-error-innererror-errordetails INTO ls_errordetails WHERE severity = 'error'.
*                    o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
*                  ENDLOOP.
*
*                ENDIF.
*
*                lo_http_client->close( ).
*              CATCH cx_web_http_client_error INTO lx_web_http_client_error.
*                RETURN.
*            ENDTRY.
*
*          ELSE.
*            EXIT.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.

    gs_resp-sapnum = ls_billheader-mtco.
    IF gs_resp-msgty <> 'E'.
      gs_resp-msgty = 'S'.
      gs_resp-msgtx  = 'success'.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

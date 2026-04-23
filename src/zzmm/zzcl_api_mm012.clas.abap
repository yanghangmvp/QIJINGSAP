CLASS zzcl_api_mm012 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "接口传入结构
    TYPES: BEGIN OF ty_data,
             uuid                     TYPE string,
             flag                     TYPE string,
             materialcode             TYPE string,  "物料编码
             materialname             TYPE string,  "物料名称
             factory                  TYPE string,  "工厂专用
             unitname                 TYPE string,  "主计量单位
             model                    TYPE string,  "型号
             purchasetype             TYPE string,  "采购类型
             levelonename             TYPE string,  "一级分类名称
             brandname                TYPE string,  "品牌
             createby                 TYPE string,  "创建人（人员姓名）
             materialgroup            TYPE string,  "物料组
             status                   TYPE string,  "物料状态
             importancelevel          TYPE string,  "重要等级
             levelonecode             TYPE string,  "一级分类编码
             leveltwocode             TYPE string,  "二级分类编码
             leveltwoname             TYPE string,  "二级分类名称
             levelthreecode           TYPE string,  "三级分类编码
             levelthreename           TYPE string,  "三级分类名称
             upperlevelcode           TYPE string,  "末级分类编码
             upperlevelname           TYPE string,  "末级分类名称
             postsalemid              TYPE string,  "售后零部件标识
             createdate               TYPE string,  "创建时间
             updateby                 TYPE string,  "最近一次修改人（人员姓名）
             updatedate               TYPE string,  "最近一次修改时间
             realproductattribute     TYPE string,  "物料性质
             realproductattributetype TYPE string,  "实物物料属性
             virtualproductattribute  TYPE string,  "虚拟物料属性
             modeldescription         TYPE string,  "规格说明
             businessattribute        TYPE string,  "业务属性
             unitusetype              TYPE string,  "计量单位设置规则

           END OF ty_data.

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
             sizeordimensiontext       TYPE string, "大小/纲量
             industrystandardname      TYPE string, "项目类别
             brand                     TYPE string, "品牌
             productoldid              TYPE string, "品牌
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
           tty_zztmm002 TYPE TABLE OF zztmm002.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_rest_cpi OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi012_resp.

    METHODS zzcreate
      IMPORTING
        i_req  TYPE ty_data OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS zzupdate
      IMPORTING
        i_req  TYPE ty_data OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS zzcreate_tax
      IMPORTING
        i_req     TYPE tty_zztmm002 OPTIONAL
        i_product TYPE i_product-product OPTIONAL
      EXPORTING
        o_resp    TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm012 IMPLEMENTATION.


  METHOD inbound.

    DATA: ls_data_json TYPE string.
*    DATA: lt_req TYPE TABLE OF ty_data WITH EMPTY KEY.
    DATA: ls_req TYPE ty_data.
    DATA: ls_resp TYPE zzs_rest_out.

    TYPES: BEGIN OF ty_mtco,
             mtco TYPE i_productplantbasic-product,
           END OF ty_mtco.

    DATA: lt_mtco TYPE TABLE OF ty_mtco.

    ls_data_json = i_req-data.

    /ui2/cl_json=>deserialize( EXPORTING json        = ls_data_json
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data        = ls_req ).


*    lt_mtco = VALUE #( FOR req IN lt_req
*                         ( mtco = req-materialcode )
*                     ).
*
*    IF lt_mtco IS NOT INITIAL.
*      SELECT a~product
*        FROM @lt_mtco AS b
*        JOIN i_product WITH PRIVILEGED ACCESS AS a ON a~product = b~mtco
*        INTO TABLE @DATA(lt_product).
*      SORT lt_product BY product.
*    ENDIF.


*    LOOP AT lt_req INTO DATA(ls_req).
*      CLEAR: ls_resp.
*      READ TABLE lt_product INTO DATA(ls_product) WITH KEY product = ls_req-materialcode BINARY SEARCH.

    SELECT COUNT(*)
      FROM i_product WITH PRIVILEGED ACCESS
     WHERE productexternalid = @ls_req-materialcode.
    IF sy-subrc <> 0.

      me->zzcreate(
        EXPORTING
            i_req = ls_req
        IMPORTING
            o_resp = ls_resp
      ).

    ELSE.
      me->zzupdate(
        EXPORTING
            i_req = ls_req
        IMPORTING
            o_resp = ls_resp
      ).

    ENDIF.

    IF ls_resp-msgty = 'E'.
      o_resp-msgty = 'E'.
      o_resp-msgtx = 'fail'.
    ELSE.
      o_resp-msgty = 'S'.
      o_resp-msgtx = 'success'.
    ENDIF.

    ls_resp-uuid = ls_req-uuid.
    APPEND ls_resp TO o_resp-out.

*    ENDLOOP.

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

    TYPES:BEGIN OF ty_factory,
            plant TYPE i_plant-plant,
          END OF ty_factory.

    DATA: lt_factory TYPE TABLE OF ty_factory.

    DATA: lv_producttype TYPE i_producttype-producttype.

    DATA: ls_req TYPE ty_data.

    DATA: lv_json TYPE string.

    DATA: lv_productdescription(40) TYPE c.
    DATA: lv_datum TYPE string.

    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

    ls_req = i_req.

    IF ls_req-factory IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请传入工厂'.
      RETURN.
    ELSE.
      "拆分传入工厂
      SPLIT ls_req-factory AT '/' INTO TABLE lt_factory.
    ENDIF.

    "检查是否有对应工厂
    SELECT plant
      FROM i_plant WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_factory
     WHERE plant = @lt_factory-plant
      INTO TABLE @DATA(lt_iplant).
    SORT lt_iplant BY plant.
    IF sy-subrc <> 0.
      o_resp-msgty = 'E'.
      o_resp-msgtx = |工厂{ ls_req-factory }不属于当前系统|.
      RETURN.
    ENDIF.

    "检查物料类型
    CLEAR: lv_producttype.
    lv_producttype = ls_req-materialgroup.
    SELECT SINGLE COUNT(*)
      FROM i_producttype WITH PRIVILEGED ACCESS
     WHERE producttype = @lv_producttype.
    IF sy-subrc <> 0.
      CASE ls_req-levelonename.
        WHEN '售后件'.
          lv_producttype = 'Z002'.
        WHEN '精品或汽车用品'.
          lv_producttype = 'Z003'.
        WHEN OTHERS.
          IF ls_req-materialcode+0(1) = '5'.
            lv_producttype = 'Z002'.
          ELSEIF ls_req-materialcode+0(2) = 'ZJ'.
            lv_producttype = 'Z003'.
          ELSEIF ls_req-materialcode+0(3) = 'NED'.
            lv_producttype = 'Z002'.
          ELSEIF ls_req-materialcode+0(4) = 'NEM7'.
            lv_producttype = 'Z004'.
          ELSE.
            lv_producttype = 'Z006'.
          ENDIF.
      ENDCASE.
    ENDIF.

    "查找对应工厂的配置值
    SELECT *
      FROM zztmm002 WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_iplant
     WHERE producttype = @lv_producttype
       AND plant = @lt_iplant-plant
      INTO TABLE @DATA(lt_zztmm002).
    IF sy-subrc <> 0.
      o_resp-msgty = 'E'.
      o_resp-msgtx = |物料类型规则配置表缺少物料类型{ lv_producttype }工厂{ ls_req-factory }的配置数据，请联系SAP系统管理员处理|.
      RETURN.
    ENDIF.
    IF lines( lt_zztmm002 ) < lines( lt_iplant ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = |物料类型规则配置表缺少物料类型{ lv_producttype }工厂{ ls_req-factory }的配置数据，请联系SAP系统管理员处理|.
      RETURN.
    ENDIF.

    SORT lt_zztmm002 BY plant.

    CLEAR: ls_product.
    CLEAR: lt_description, lt_plant, lt_salestax, lt_salesdelivery, lt_valuation.

    IF ls_req-materialname IS NOT INITIAL.
      CLEAR: ls_description, lv_productdescription.
      lv_productdescription = ls_req-materialname.
      ls_description-product = ls_req-materialcode.                  "物料号
      ls_description-language = 'ZH'.                                "语言
      ls_description-productdescription = lv_productdescription.     "中文描述
      APPEND ls_description TO lt_description.
    ENDIF.

    LOOP AT lt_zztmm002 INTO DATA(ls_zztmm002).
      DATA(ls_save) = ls_zztmm002.

      CLEAR: ls_plant.
      ls_plant-product                    = ls_req-materialcode.                  "物料号
      ls_plant-plant                      = ls_save-plant.                        "工厂
      ls_plant-purchasinggroup            = ls_save-purchasinggroup.              "采购组
      ls_plant-productioninvtrymanagedloc = ls_save-productioninvtrymanagedloc.   "生产库存地点
      ls_plant-isbatchmanagementrequired  = ls_save-isbatchmanagementrequired.    "批次管理-工厂
      ls_plant-profitcenter               = ls_save-profitcenter.                 "利润中心
      ls_plant-mrptype                    = ls_save-mrptype.                      "MRP类型
      ls_plant-serialnumberprofile        = ls_save-serialnumberprofile.          "序列号参数文件

      "特定物料状态生效日期
*      IF ls_req-effouttime IS NOT INITIAL.
*        lv_datum = ls_req-effouttime+0(4) && ls_req-effouttime+5(2) && ls_req-effouttime+8(2).
*        ls_plant-profilevaliditystartdate = zzcl_comm_tool=>date2iso(
*                                                iv_date = lv_datum ).
*      ENDIF.

      ls_plant-to_plantsales-product      = ls_req-materialcode.                   "物料号
      ls_plant-to_plantsales-plant        = ls_save-plant.                        "工厂
      ls_plant-to_plantsales-loadinggroup = ls_save-loadinggroup.                 "装货组

      ls_plant-to_productplantcosting-product                  = ls_req-materialcode.                  "物料号
      ls_plant-to_productplantcosting-plant                    = ls_save-plant.                       "工厂
      ls_plant-to_productplantcosting-costinglotsize           = ls_save-priceunitqty.              "成本核算批量
      CONDENSE ls_plant-to_productplantcosting-costinglotsize NO-GAPS.
      ls_plant-to_productplantcosting-productiscostingrelevant = ls_save-productiscostingrelevant.    "不计算成本

      ls_plant-to_productplantprocurement-product                     = ls_req-materialcode.                   "物料号
      ls_plant-to_productplantprocurement-plant                       = ls_save-plant.                        "工厂
      ls_plant-to_productplantprocurement-isautopurordcreationallowed = ls_save-isautopurordcreationallowed.  "自动采购单
      ls_plant-to_productplantprocurement-issourcelistrequired        = ls_save-issourcelistrequired.         "源清单

      ls_plant-to_productsupplyplanning-product                      = ls_req-materialcode.                    "物料号
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
        ls_salestax-product           = ls_req-materialcode.         "物料号
        ls_salestax-country           = ls_save-country.             "启运国
        ls_salestax-taxcategory       = ls_save-taxcategory.         "税收类型
        ls_salestax-taxclassification = ls_save-taxclassification.   "税分类
        APPEND ls_salestax TO lt_salestax.

        CLEAR: ls_salesdelivery.
        ls_salesdelivery-product                        = ls_req-materialcode.                     "物料号
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
      ls_valuation-product                     = ls_req-materialcode.                   "物料号
      ls_valuation-valuationarea               = ls_save-valuationarea.                 "评估范围
      ls_valuation-valuationclass              = ls_save-valuationclass.                "评估分类
      ls_valuation-pricedeterminationcontrol   = ls_save-pricedeterminationcontrol.     "价格确定
      ls_valuation-priceunitqty                = ls_save-priceunitqty.                  "价格单位
      CONDENSE ls_valuation-priceunitqty NO-GAPS.
      ls_valuation-inventoryvaluationprocedure = ls_save-inventoryvaluationprocedure.   "价格控制
      ls_valuation-currency                    = ls_save-currency.                      "货币

      ls_valuation-to_valuationcosting-product                      = ls_req-materialcode.                   "物料号
      ls_valuation-to_valuationcosting-valuationarea                = ls_save-valuationarea.                "评估范围
      ls_valuation-to_valuationcosting-ismaterialcostedwithqtystruc = ls_save-ismaterialcostedwithqtystruc. "用QS的成本估算
      ls_valuation-to_valuationcosting-ismaterialrelatedorigin      = ls_save-ismaterialrelatedorigin.      "物料来源
      APPEND ls_valuation TO lt_valuation.

      AT LAST.
        ls_product-product                             = ls_req-materialcode.                     "物料号
        ls_product-producttype                         = ls_save-producttype.                     "物料类型
        ls_product-productgroup                        = ls_save-productgroup.                    "物料组
        ls_product-baseunit                            = ls_req-unitname.                         "基本单位
        IF ls_save-productdistributionchnl IS NOT INITIAL.
          ls_product-itemcategorygroup                   = ls_save-conventionalitemcategorygroup. "常规项目类别组
        ENDIF.
        ls_product-division                            = ls_save-division.                        "产品组
        ls_product-isbatchmanagementrequired           = ls_save-isbatchmanagementrequired.       "批次管理
        ls_product-manufacturerpartprofile             = ls_save-manufacturerpartprofile.         "制造商部件参数文件
        ls_product-industrysector                      = ls_save-industrysector.                  "行业
        ls_product-sizeordimensiontext                 = ls_req-model.                            "大小/纲量
        ls_product-industrystandardname                = ls_req-levelonename.                     "项目类别
*        ls_product-brand                               = ls_req-brandname.                        "品牌
        ls_product-productoldid                        = ls_req-brandname.                        "品牌
        ls_product-yy1_partver_prd                     = ls_req-materialname.                     "物料名称

        ls_product-to_description-results              = lt_description.
        ls_product-to_plant-results                    = lt_plant.

        ls_product-to_productsales-product             = ls_req-materialcode.                     "物料号
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
          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          o_resp-sapnum = ls_req-materialcode.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-sapnum = ls_req-materialcode.
          LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
            o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
          ENDLOOP.

        ENDIF.

        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD zzupdate.
    DATA: ls_req TYPE ty_data.
    DATA: lv_product TYPE i_product-product.
    DATA: ls_resp_tax TYPE zzs_rest_out.
    DATA: lv_productdescription(40) TYPE c.
    DATA: lv_component TYPE string VALUE 'Product'.
    DATA: ls_producttype TYPE ty_product.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    DATA: lv_json TYPE string.

    TYPES:BEGIN OF ty_factory,
            plant TYPE i_plant-plant,
          END OF ty_factory.

    DATA: lt_factory TYPE TABLE OF ty_factory.

    ls_req = i_req.
    lv_product = ls_req-materialcode.
    lv_productdescription = ls_req-materialname.

    IF ls_req-factory IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请传入工厂'.
      RETURN.
    ELSE.
      "拆分传入工厂
      SPLIT ls_req-factory AT '/' INTO TABLE lt_factory.
    ENDIF.

    "检查是否有对应工厂
    SELECT plant
      FROM i_plant WITH PRIVILEGED ACCESS
       FOR ALL ENTRIES IN @lt_factory
     WHERE plant = @lt_factory-plant
      INTO TABLE @DATA(lt_iplant).
    SORT lt_iplant BY plant.
    IF sy-subrc <> 0.
      o_resp-msgty = 'E'.
      o_resp-msgtx = |工厂{ ls_req-factory }不属于当前系统|.
      RETURN.
    ENDIF.

    "判断物料是否存在
    SELECT SINGLE
           product,
           producttype
      FROM i_product WITH PRIVILEGED ACCESS
     WHERE productexternalid = @lv_product
*      INTO @DATA(lv_producttype).
      INTO ( @DATA(lv_product_in), @DATA(lv_producttype) ).
*    IF sy-subrc <> 0.
*      me->zzcreate(
*        EXPORTING
*            i_req = ls_req
*        IMPORTING
*            o_resp = o_resp
*      ).
*      RETURN.
*    ENDIF.

    "判断是否需要扩工厂
    SELECT plant
      FROM i_productplantbasic WITH PRIVILEGED ACCESS
     WHERE product = @lv_product_in
      INTO TABLE @DATA(lt_plantbasic).
    SORT lt_plantbasic BY plant.

    LOOP AT lt_iplant INTO DATA(ls_iplant).
      READ TABLE lt_plantbasic TRANSPORTING NO FIELDS WITH KEY plant = ls_iplant-plant BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE lt_iplant.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    "begin 查找对应工厂的配置值，扩工厂
    IF lt_iplant IS NOT INITIAL.
      SELECT *
        FROM zztmm002 WITH PRIVILEGED ACCESS
         FOR ALL ENTRIES IN @lt_iplant
       WHERE producttype = @lv_producttype
         AND plant = @lt_iplant-plant
        INTO TABLE @DATA(lt_zztmm002).
      IF sy-subrc <> 0.
        o_resp-msgty = 'E'.
        o_resp-msgtx = |物料类型规则配置表缺少物料类型{ lv_producttype }工厂{ ls_req-factory }的配置数据，请联系SAP系统管理员处理|.
        RETURN.
      ENDIF.
      IF lines( lt_zztmm002 ) < lines( lt_iplant ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = |物料类型规则配置表缺少物料类型{ lv_producttype }工厂{ ls_req-factory }的配置数据，请联系SAP系统管理员处理|.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(lt_zztmm002_tax) = lt_zztmm002.
    DELETE lt_zztmm002_tax WHERE productsalesorg IS INITIAL.
    SORT lt_zztmm002 BY plant.
    SORT lt_zztmm002_tax BY country taxcategory taxclassification.
    DELETE ADJACENT DUPLICATES FROM lt_zztmm002_tax COMPARING country taxcategory taxclassification.

    "取税码，如果扩的工厂存在新税码，需要单独创建
    SELECT DISTINCT
           country,
           taxcategory,
           taxclassification
      FROM i_productsalestax WITH PRIVILEGED ACCESS
     WHERE product = @lv_product_in
      INTO TABLE @DATA(lt_tax).
    SORT lt_tax BY country taxcategory taxclassification.

    LOOP AT lt_zztmm002_tax INTO DATA(ls_zztmm002_tax).
      READ TABLE lt_tax TRANSPORTING NO FIELDS WITH KEY country = ls_zztmm002_tax-country
                                                        taxcategory = ls_zztmm002_tax-taxcategory
                                                        taxclassification = ls_zztmm002_tax-taxclassification
                                                        BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE lt_zztmm002_tax.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    "新建税码
    IF lt_zztmm002_tax IS NOT INITIAL.
      me->zzcreate_tax(
        EXPORTING
            i_req     = lt_zztmm002_tax
            i_product = lv_product
        IMPORTING
            o_resp = ls_resp_tax
      ).
    ENDIF.

    LOOP AT lt_zztmm002 INTO DATA(ls_zztmm002).
      IF ls_zztmm002-productdistributionchnl IS INITIAL.
        CLEAR: ls_zztmm002-productsalesorg,
               ls_zztmm002-productdistributionchnl,
               ls_zztmm002-supplyingplant,
               ls_zztmm002-country,
               ls_zztmm002-taxcategory,
               ls_zztmm002-taxclassification,
               ls_zztmm002-pricespecificationproductgroup,
               ls_zztmm002-accountdetnproductgroup,
               ls_zztmm002-conventionalitemcategorygroup,
               ls_zztmm002-itemcategorygroup.

      ENDIF.

      MODIFY ENTITIES OF i_producttp_2 PRIVILEGED

          ENTITY product

          CREATE BY \_productplant AUTO FILL CID WITH VALUE #( (
                  product = lv_product_in "物料编号
                  %target = VALUE #( (  %cid = 'Plant'
                                        product = lv_product_in "物料编号
                                        plant = ls_zztmm002-plant "工厂
                                        isbatchmanagementrequired  = ls_zztmm002-isbatchmanagementrequired "批次管理
                                        serialnumberprofile  = ls_zztmm002-serialnumberprofile "序列号参数文件
                                        profitcenter  = |{ ls_zztmm002-profitcenter ALPHA = IN }| "利润中心
                                      ) )
           ) )
         CREATE BY \_productsalesdelivery  AUTO FILL CID WITH VALUE #( (
              product = lv_product_in "物料编号
              %target = VALUE #( (  %cid = 'SalesDelivery'
                                     product = lv_product_in "物料编号
                                     productsalesorg = ls_zztmm002-productsalesorg "销售组织
                                     productdistributionchnl = ls_zztmm002-productdistributionchnl "分销渠道
                                     supplyingplant = ls_zztmm002-supplyingplant "交货工厂
                                     itemcategorygroup = ls_zztmm002-itemcategorygroup "项目类别组
                                     pricespecificationproductgroup = ls_zztmm002-pricespecificationproductgroup "物料价格组
                                     accountdetnproductgroup = ls_zztmm002-accountdetnproductgroup "科目分配组
                                            ) )
           ) )

        CREATE BY \_productvaluation AUTO FILL CID WITH VALUE #( (
              product = lv_product_in "物料编号
               %target = VALUE #(  ( %cid = 'Valuation'
                                     product = lv_product_in"物料编号
                                     valuationarea = ls_zztmm002-valuationarea "评估范围
                                     pricedeterminationcontrol = ls_zztmm002-pricedeterminationcontrol "价格确定
                                     valuationclass = ls_zztmm002-valuationclass "评估类
                                     inventoryvaluationprocedure = ls_zztmm002-inventoryvaluationprocedure "价格控制
                                     currency = ls_zztmm002-currency "货币
                                     productpriceunitquantity = ls_zztmm002-priceunitqty "价格单位
                                 ) )
               ) )


         ENTITY productplant
         CREATE BY \_productplantprocurement FROM VALUE #( (
              %cid_ref = 'Plant'
              product = lv_product_in "物料编号
              plant = ls_zztmm002-plant
                 %target = VALUE #( (  %cid = 'rodProc'
                                       product = lv_product_in "物料编号
                                       plant = ls_zztmm002-plant "工厂
                                       purchasinggroup = ls_zztmm002-purchasinggroup "采购组
                                       isautopurordcreationallowed = ls_zztmm002-isautopurordcreationallowed "自动采购单
                                       issourcelistrequired = ls_zztmm002-issourcelistrequired "源清单
                                    ) )
          ) )

        CREATE BY \_productplantsupplyplanning  FROM VALUE #( (
              %cid_ref = 'Plant'
              product = lv_product_in "物料编号
              plant = ls_zztmm002-plant
                 %target = VALUE #( (  %cid = 'ProdSupplyPlan'
                                       product = lv_product_in "物料编号
                                       plant = ls_zztmm002-plant "工厂
                                       dfltstoragelocationextprocmt = ls_zztmm002-dfltstoragelocationextprocmt "外部采购仓储地点
                                       mrptype = ls_zztmm002-mrptype "MRP类型
                                       mrpresponsible = ls_zztmm002-mrpresponsible "物料需求计划控制员
                                       availabilitychecktype = ls_zztmm002-availabilitychecktype "可用性检查
                                       lotsizingprocedure = ls_zztmm002-lotsizingprocedure "批量程序
                                       procurementtype = ls_zztmm002-procurementtype "采购类型
                                       procurementsubtype = ls_zztmm002-procurementsubtype "特殊采购类
                                       productioninvtrymanagedloc = ls_zztmm002-productioninvtrymanagedloc "生产库存地点
                                       dependentrequirementstype = ls_zztmm002-dependentrequirementstype "独立集中
                                       baseunit = ls_req-unitname "基本计量单位
                                    ) )
          ) )

       CREATE BY \_productplantsales FROM VALUE #( (
              %cid_ref = 'Plant'
              product = lv_product_in "物料编号
              plant = ls_zztmm002-plant
               %target = VALUE #( (  %cid = 'ProductPlantSales '
                                     product = lv_product_in "物料编号
                                     plant = ls_zztmm002-plant "工厂
                                     loadinggroup = ls_zztmm002-loadinggroup "装载组
                                  ) )

          ) )
       CREATE BY \_productplantcosting  FROM VALUE #( (
              %cid_ref = 'Plant'
              product = lv_product_in "物料编号
              plant = ls_zztmm002-plant
               %target = VALUE #( (  %cid = 'ProductPlantCosting '
                                     product = lv_product_in "物料编号
                                     plant = ls_zztmm002-plant "工厂
                                     costingspecialprocurementtype = ls_zztmm002-procurementsubtype "特殊采购类
                                     costinglotsize = ls_zztmm002-costinglotsize "成本核算批量
                                     productiscostingrelevant = ls_zztmm002-productiscostingrelevant "不计算成本
                                     baseunit = ls_req-unitname "基本计量单位
                                  ) )

          ) )


      ENTITY productsalesdelivery

      CREATE BY \_prodsalesdeliverysalestax  FROM VALUE #( (
              %cid_ref = 'SalesDelivery'
              product = lv_product_in "物料编号
              productsalesorg = ls_zztmm002-productsalesorg "销售组织
              productdistributionchnl = ls_zztmm002-productdistributionchnl "分销渠道
               %target = VALUE #( (  %cid = 'ProdSalesDeliverySalesTax '
                                     product = lv_product_in "物料编号
                                     productsalesorg = ls_zztmm002-productsalesorg "销售组织
                                     productdistributionchnl = ls_zztmm002-productdistributionchnl "分销渠道
                                     country = ls_zztmm002-country "税分类国家
                                     productsalestaxcategory = ls_zztmm002-taxcategory "税收类别
                                     producttaxclassification = ls_zztmm002-taxclassification "税分类
                                  ) )

          ) )

      ENTITY productvaluation
       CREATE BY \_productvaluationcosting  FROM VALUE #( (
              %cid_ref = 'Valuation'
              product = lv_product_in "物料编号
              valuationarea = ls_zztmm002-valuationarea "评估范围
               %target = VALUE #( (  %cid = 'productvaluationcosting '
                    product = lv_product_in "物料编号
                    valuationarea = ls_zztmm002-valuationarea "评估范围
                    currency = ls_zztmm002-currency "货币
                    ismaterialrelatedorigin = ls_zztmm002-ismaterialrelatedorigin "产品相关来源
                    productiscostedwithqtystruc = ls_zztmm002-ismaterialcostedwithqtystruc "用QS的成本估算
                                  ) )

          ) )
      CREATE BY \_productvaluationaccounting  FROM VALUE #( (
              %cid_ref = 'Valuation'
              product = lv_product_in "物料编号
              valuationarea = ls_zztmm002-valuationarea "评估范围
               %target = VALUE #( (  %cid = 'ProductValuationAccounting '
                     product = lv_product_in "物料编号
                     valuationarea = ls_zztmm002-valuationarea "评估范围
                                  ) )

          ) )
       MAPPED DATA(ls_mapped)
       REPORTED DATA(ls_reported)
       FAILED DATA(ls_failed).

      IF ls_failed-productplant IS NOT INITIAL.
        DATA(lv_msg) = zzcl_comm_tool=>get_bo_msg( is_reported = ls_reported iv_component = lv_component ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
      ENDIF.

    ENDLOOP.

    "end 查找对应工厂的配置值，扩工厂

    "begin 修改
    MODIFY ENTITIES OF i_producttp_2 PRIVILEGED
          ENTITY productdescription
          UPDATE FIELDS ( productdescription )
          WITH VALUE #( ( %key-product = lv_product_in "物料编号
                          %key-language = '1'
                          productdescription = lv_productdescription ) )

          ENTITY product
          UPDATE FIELDS ( yy1_partver_prd sizeordimensiontext industrystandardname productoldid )
          WITH VALUE #( ( %key-product = lv_product_in
                          yy1_partver_prd = ls_req-materialname     "物料描述
                          sizeordimensiontext = ls_req-model        "大小/纲量
                          industrystandardname = ls_req-levelonename        "项目类别
                          productoldid = ls_req-brandname           "品牌
*                          producttype = ls_req-materialgroup        "物料类型
                         ) )
       MAPPED DATA(ls_mapped2)
       REPORTED DATA(ls_reported2)
       FAILED DATA(ls_failed2).

    IF ls_failed2-product IS NOT INITIAL.
      lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = ls_reported2 iv_component = lv_component ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
    ENDIF.
    "end 修改

    COMMIT ENTITIES
    RESPONSE OF i_producttp_2
        FAILED DATA(failed_commit)
        REPORTED DATA(reported_commit).

    IF failed_commit-product IS NOT INITIAL.
      lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
    ENDIF.

    "判断物料类型
    IF lv_producttype <> ls_req-materialgroup.
      o_resp-msgty = 'E'.
      o_resp-msgtx = o_resp-msgtx  && '/' && '物料类型不一致请检查'.
    ENDIF.

    IF o_resp-msgty <> 'E'.
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'success'.
    ENDIF.

    o_resp-sapnum = ls_req-materialcode.

  ENDMETHOD.


  METHOD zzcreate_tax.
    DATA: ls_salesdelivery TYPE ty_salesdelivery.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    DATA: lv_json TYPE string.

    LOOP AT i_req INTO DATA(ls_req).
      CLEAR: ls_salesdelivery.

      ls_salesdelivery = VALUE #( product                 = i_product                       "物料编号
                                  productsalesorg         = ls_req-productsalesorg          "销售组织
                                  productdistributionchnl = ls_req-productdistributionchnl  "分销渠道
                                ).

      APPEND VALUE #( product           = i_product                 "物料编号
                      country           = ls_req-country            "税分类国家
                      taxcategory       = ls_req-taxcategory        "税收类别
                      taxclassification = ls_req-taxclassification  "税分类
                 ) TO ls_salesdelivery-to_salestax-results.


*&---接口http 链接调用
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_uri_path) = |/API_PRODUCT_SRV/A_ProductSalesDelivery?sap-language=zh|.
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
          lo_http_client->set_csrf_token(  ).

          lo_request->set_content_type( 'application/json' ).
          "传入数据转JSON
          lv_json = /ui2/cl_json=>serialize(
                data          = ls_salesdelivery
                compress      = abap_true
                name_mappings = gt_mapping ).

          lo_request->set_text( lv_json ).

*&---执行http post 方法
          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
          DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
          DATA(status) = lo_response->get_status( ).
          IF status-code <> '201'.
            DATA:ls_rese TYPE zzs_odata_fail.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_rese ).
            o_resp-msgty = 'E'.
            o_resp-sapnum = i_product.
            LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
              o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
            ENDLOOP.

          ENDIF.

          lo_http_client->close( ).
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          RETURN.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.

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
         ( abap = 'SizeOrDimensionText'                       json = 'SizeOrDimensionText' )
         ( abap = 'IndustryStandardName'                      json = 'IndustryStandardName' )
         ( abap = 'Brand'                                     json = 'Brand' )
         ( abap = 'ProductOldID'                              json = 'ProductOldID' )
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

  ENDMETHOD.
ENDCLASS.

//namespace tables.db;

using {cuid, managed,temporal,Currency} from '@sap/cds/common';

using {own.commfile} from './commons'; // tables.comm is namespace and ./commons is file name (Mine created file)

type Guid : String(32);

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
context tables.db {
    
    context master {

    entity businesspartner {
        key NODE_KEY      : Guid;
            BP_ROLE       : String(2);
            EMAIL_ADDRESS : String(105);
            PHONE_NUMBER  : String(32);
            FAX_NUMBER    : String(32);
            WEB_ADDRESS   : String(44);
            ADDRESS_GUID  : Association to address;
            BP_ID         : String(32);
            COMPANY_NAME  : String(250);
    }

    entity address {
        key NODE_KEY        : Guid;
            CITY            : String(44);
            POSTAL_CODE     : String(8);
            STREET          : String(44);
            BUILDING        : String(128);
            COUNTRY         : String(44);
            ADDRESS_TYPE    : String(44);
            VAL_START_DATE  : Date;
            VAL_END_DATE    : Date;
            LATITUDE        : Decimal;
            LONGITUDE       : Decimal;
            businesspartner : Association to one businesspartner
                                  on businesspartner.ADDRESS_GUID = $self;
    }

    // entity prodtext {
    //     key NODE_KEY   : Guid;
    //         PARENT_KEY : Guid;
    //         LANGUAGE   : String(2);
    //         TEXT       : String(256);
    // }

    entity product {
        key NODE_KEY       : Guid;
            PRODUCT_ID     : String(28);
            TYPE_CODE      : String(2);
            CATEGORY       : String(32);
            // DESC_GUID      : Association to prodtext; // Direct Key Relationship
            DESCRIPTION    : localized String(225);    // Dynamic localization will crate Automatically a Product TEXT table
            SUPPLIER_GUID  : Association to master.businesspartner; // Forgin key relationship
            TAX_TARIF_CODE : Integer;
            MEASURE_UNIT   : String(2);
            WEIGHT_MEASURE : Decimal;
            WEIGHT_UNIT    : String(2);
            CURRENCY_CODE  : String(4);
            PRICE          : Decimal(15, 2);
            WIDTH          : Decimal;
            DEPTH          : Decimal;
            HEIGHT         : Decimal;
            DIM_UNIT       : String(2);
    }

    entity employees : cuid {
        nameFirst     : String(40);
        nameMiddle    : String(40);
        nameLast      : String(40);
        nameInitials  : String(40);
        sex           : commfile.Gender;
        language      : String(1);
        phoneNumber   : commfile.PhoneNumber;
        email         : commfile.Email;
        loginName     : String(12);
        Currency      : Currency;
        salaryAmount  : commfile.AmountT;
        accountNumber : String(16);
        bankId        : String(20);
        bankName      : String(64);
        
    } 
 }

 //////////////////////////////////////////////////////////////////
 //////////////////////////////////////////////////////////////////
    context transaction {

    entity purchaseorder : commfile.Amount, cuid {
        PO_ID            : Integer;
        PARTNER_GUID     : Association to master.businesspartner;
        LIFECYCLE_STATUS : String(1);
        OVERALL_STATUS   : String(1);
        Items            : Composition of many poitems on Items.PARENT_KEY = $self;
        NOTE             : String(256);
        CREATEDBY        : UUID;
        MODIFIEDBY       : UUID;
        CREATEDAT        : Date;
        MODIFIEDAT       : Date;
    }

    entity poitems : commfile.Amount, cuid {
        PARENT_KEY   : Association to purchaseorder;
        PO_ITEM_POS  : Integer;
        PRODUCT_GUID : Association to master.product;

    }

    }

 //////////////////////////////////////////////////////////////////
 //////////////////////////////////////////////////////////////////

    context CDSViews {
    
     define view![POWorklist] as
        select from transaction.purchaseorder {
            key PO_ID                              as![PurchaseOrderId],
                PARTNER_GUID.BP_ID                 as![PartnerId],
                PARTNER_GUID.COMPANY_NAME          as![CompanyName],
                GROSS_AMOUNT                       as![POGrossAmount],
                Currency.code                      as![POCurrencyCode],
                LIFECYCLE_STATUS                   as![POStatus],
            key Items.PO_ITEM_POS                  as![ItemPosition],      //noted
                Items.PRODUCT_GUID.PRODUCT_ID      as![ProductId],         //noted
                Items.PRODUCT_GUID.DESCRIPTION     as![ProductName],        //noted
                PARTNER_GUID.ADDRESS_GUID.CITY     as![City],              //noted
                PARTNER_GUID.ADDRESS_GUID.COUNTRY  as![Country],           //noted
                Items.GROSS_AMOUNT                 as![GrossAmount],       //noted
                Items.NET_AMOUNT                   as![NetAmount],
                Items.TAX_AMOUNT                   as![TaxAmount],
                Items.Currency.code                as![CurrencyCode],

        };


     define view ProductValueHelp as 
        select from master.product{
            @EndUserText.label:[
                {
                    language: 'EN',
                    text: 'Product ID'
                },{
                    language: 'DE',
                    text: 'Prodekt ID'
                }
            ]
            PRODUCT_ID as ![ProductId],
            @EndUserText.label:[
                {
                    language: 'EN',
                    text: 'Product Description'
                },{
                    language: 'DE',
                    text: 'Prodekt Description'
                }
            ]
            DESCRIPTION as ![Description]
        };


     define view![ItemView] as
        select from transaction.poitems {
            PARENT_KEY.PARTNER_GUID.NODE_KEY as![Partner],
            PRODUCT_GUID.NODE_KEY            as![ProductId],
            Currency.code                    as![CurrencyCode],
            GROSS_AMOUNT                     as![GrossAmount],
            NET_AMOUNT                       as![NetAmount],
            TAX_AMOUNT                       as![TaxAmount],
            PARENT_KEY.OVERALL_STATUS        as![POStatus]
        };


     define view ProductViewSub as
        select from master.product as prod{
            PRODUCT_ID as![ProductId],
            texts.DESCRIPTION as![Description],
            (
                select from transaction.poitems as abc{
                    round(SUM(abc.GROSS_AMOUNT),2) as SUM
                } 
                where abc.PRODUCT_GUID.NODE_KEY = prod.NODE_KEY
            ) as PO_SUM: Decimal(10,2)
        };


     define view ProductView as
        select from master.product
        mixin {
            PO_ORDERS : Association[ * ] to ItemView
                            on PO_ORDERS.ProductId = $projection.ProductId
        }
        into {
            NODE_KEY                           as![ProductId],
            DESCRIPTION,
            CATEGORY                           as![Category],
            PRICE                              as![Price],
            TYPE_CODE                          as![TypeCode],
            SUPPLIER_GUID.BP_ID                as![BPId],
            SUPPLIER_GUID.COMPANY_NAME         as![CompanyName],
            SUPPLIER_GUID.ADDRESS_GUID.CITY    as![City],
            SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as![Country],
            //Exposed Association, which means when someone read the view
            //the data for orders wont be read by default
            //until unless someone consume the association
            PO_ORDERS
        };


     define view CProductValuesView as 
        select from ProductView{
            ProductId,
            Country,
            PO_ORDERS.CurrencyCode as![CurrencyCode],
            round(sum(PO_ORDERS.GrossAmount),2) as ![POGrossAmount]: Decimal(10, 2)
        }
        group by ProductId,Country,PO_ORDERS.CurrencyCode
    }

}
//////////////////////////////////////////////////////////////////////////////
// @cds.persistence.calcview
// @cds.persistence.exists
// entity ![PODetails] {
//     ![NODE_KEY]: String(32) @title : 'NODE_KEY: NODE_KEY';
//     ![BP_ROLE]: String(2) @title : 'BP_ROLE: BP_ROLE';
//     ![BP_ID]: String(32) @title : 'BP_ID: BP_ID';
//     ![COMPANY_NAME]: String(250) @title : 'COMPANY_NAME: COMPANY_NAME';
//     ![CITY]: String(44) @title : 'CITY: CITY';
//     ![POSTAL_CODE]: String(8) @title : 'POSTAL_CODE: POSTAL_CODE';
//     ![COUNTRY]: String(44) @title : 'COUNTRY: COUNTRY';
//     ![ID]: String(36) @title : 'ID: ID';
//     ![PARTNER_GUID_NODE_KEY]: String(32) @title : 'PARTNER_GUID_NODE_KEY: PARTNER_GUID_NODE_KEY';
//     ![OVERALL_STATUS]: String(1) @title : 'OVERALL_STATUS: OVERALL_STATUS';
//     ![PO_ID]: Integer @title : 'TodaysDate';
//     ![CURRENCY_CODE]: String(3) @title : 'CURRENCY_CODE: CURRENCY_CODE';
//     ![PO_ITEM_POS]: Integer @title : 'PO_ITEM_POS: PO_ITEM_POS';
//     ![TodaysDate]: Date @title : 'CURRENCY_CODE: CURRENCY_CODE';
//     ![GROSS_AMOUNT]: Decimal(15, 2) @title : 'GROSS_AMOUNT: GROSS_AMOUNT';
//     ![NET_AMOUNT]: Decimal(15, 2) @title : 'NET_AMOUNT: NET_AMOUNT';
//     ![TAX_AMOUNT]: Decimal(15, 2) @title : 'TAX_AMOUNT: TAX_AMOUNT';

// }



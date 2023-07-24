//namespace tables.db;

// using { tables.db.master, tables.db.transaction } from './datamodel';

// context CDSViews {

//     define view![POWorklist] as
//         select from transaction.purchaseorder {
//             key PO_ID                              as![PurchaseOrderId],
//                 PARTNER_GUID.BP_ID                 as![PartnerId],
//                 PARTNER_GUID.COMPANY_NAME          as![CompanyName],
//                 GROSS_AMOUNT                       as![POGrossAmount],
//                 Currency.code                      as![POCurrencyCode],
//                 LIFECYCLE_STATUS                   as![POStatus],
//             key Items.PO_ITEM_POS                  as![ItemPosition],      //noted
//                 Items.PRODUCT_GUID.PRODUCT_ID      as![ProductId],         //noted
//                 Items.PRODUCT_GUID.DESCRIPTION     as![ProductName],        //noted
//                 PARTNER_GUID.ADDRESS_GUID.CITY     as![City],              //noted
//                 PARTNER_GUID.ADDRESS_GUID.COUNTRY  as![Country],           //noted
//                 Items.GROSS_AMOUNT                 as![GrossAmount],       //noted
//                 Items.NET_AMOUNT                   as![NetAmount],
//                 Items.TAX_AMOUNT                   as![TaxAmount],
//                 Items.Currency.code                as![CurrencyCode],

//         }
// }
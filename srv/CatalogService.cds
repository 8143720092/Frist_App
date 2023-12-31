// using { tables.db } from '../db/datamodel';

// service catalogservice {
//     entity BusinessPartnerSet as projection on db.master.businesspartner;
// }



using { tables.db.master, tables.db.transaction,tables.db.CDSViews } from '../db/datamodel';


service CatalogService@(path:'/CatalogService') {

    function sleep() returns Boolean;

    entity BusinessPartnerSet as projection on master.businesspartner;

    entity EmployeeSet as projection on master.employees;

    entity AddressSet as projection on master.address;

    entity ProductSet as projection on master.product;
    

    // entity POs @(
    //     title : '{i18n>poHeader}'
    //     ) as projection on transaction.purchaseorder{
    //      *, 
    //      Items: redirected to POItems,
    // }

    // entity POItems @(title : '{i18n>poItems}' 
    // ) as projection on transaction.poitems{
    //     *,
    //     PARENT_KEY: redirected to POs,
    //     PRODUCT_GUID: redirected to ProductSet,
    // }

 ////////////////////////////////////////////////////////////////////////

    entity POWorklist                         as projection on CDSViews.POWorklist;
    
    entity ProductOrders                      as projection on CDSViews.ProductViewSub;
    entity ProductAggregation                 as projection on CDSViews.CProductValuesView excluding {
        ProductId
    }


    // entity PurchaseOrders as projection on PODetails;


}
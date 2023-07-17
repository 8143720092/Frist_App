namespace tables.db;

using {cuid, managed,temporal,Currency} from '@sap/cds/common';

using {tables.comm} from './commons'; // tables.comm is namespace and ./commons is file name (Mine created file)

type Guid : String(32);


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
        sex           : comm.Gender;
        language      : String(1);
        phoneNumber   : comm.PhoneNumber;
        email         : comm.Email;
        loginName     : String(12);
        Currency      : Currency;
        salaryAmount  : comm.AmountT;
        accountNumber : String(16);
        bankId        : String(20);
        bankName      : String(64);
        
    } 
}

context transaction {

    entity purchaseorder : comm.Amount, cuid {
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

    entity poitems : comm.Amount, cuid {
        PARENT_KEY   : Association to purchaseorder;
        PO_ITEM_POS  : Integer;
        PRODUCT_GUID : Association to master.product;

    }

}
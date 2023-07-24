namespace own.commfile;

using { sap, Currency, temporal, managed } from '@sap/cds/common';

//Creating domen level fixed vslue // enum keyword to declear constant value
type Gender : String(1) enum {
    male = 'M';
    female = 'F';
    noBinary = 'N';
    noDiscloser = 'D';
    selfDescribe = 'S';
};

type AmountT     : Decimal(15, 2) @(
    Semantics.amount.currencyCode: 'CURRENCY_CODE',
    sap.unit                     : 'CURRENCY_CODE'
);

// Creating a structure of Amount and using an Aspact in it as currency
//Abstract entity definitions are deprecated; use aspect definitions instead
abstract entity Amount {
    Currency     : Currency;
    GROSS_AMOUNT : AmountT;
    NET_AMOUNT   : AmountT;
    TAX_AMOUNT   : AmountT;
};

// Aspect Amount {
//     Currency: Currency;
//     GROSS_AMOUNT:AmountT;
//     NET_AMOUNT:AmountT;
//     TAX_AMOUNT:AmountT;
// };

type PhoneNumber : String(30) @assert.format: '^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$';
type Email       : String(255) @assert.format: '^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$';

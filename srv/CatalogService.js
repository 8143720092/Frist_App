const cds = require('@sap/cds');   // to handle all dependencies

//To register all the event handler
module.exports = cds.service.impl(
    async function () {

        this.on('sleep', async () => {
            //get connection from cds
            try{
                const db = await cds.connect.to('db');                               // connection to db
                const dbClass = require('sap-hdbext-promisfied');                        // npm install sap-hdbext-promisfied  module to get dependencies 
                let dbConn = new dbClass(await dbClass.createConnection(db.options.credentials));  //ref obj of dbClass
    
                const hdbext = require('@sap/hdbext');                                         //npm install another module extention of hana db module
                const sp = await dbConn.loadProcedurePromisified( hdbext, null, 'sleep' ); // loaad procidure loadProcedurePromisified from db
                const output = await dbConn.callProcedurePromisified(sp, []);            // call procedure callProcedurePromisified sp withou parameters
                console.log(output);
                return true;
            } catch (error) {
                console.log(error);
                return false;
            }


        });
    }
);

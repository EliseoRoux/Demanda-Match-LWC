@isTest
private class DemandaControllerTest {
    @isTest static void testObtenerDemandas() {
        // 1. Crear datos ficticios (un anuncio y una demanda)
        
        // Crear un anuncio de prueba
        pba__Listing__c anuncio = new pba__Listing__c(
            Name = 'Anuncio Test',
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__ListingPrice_pb__c = 100000,  // Precio del anuncio
            pba__TotalArea_pb__c = 100        // Superficie del anuncio
        );
        insert anuncio;

        // Crear una demanda que coincida con las condiciones
        pba__Request__c demanda = new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            Monthly_Net_Bare_Rent__c = 102000, // Precio dentro del rango
            pba__TotalArea_pb_min__c = 98,     // Superficie dentro del rango
            pba__Status__c = '5% - Primer contacto',
            Keyword__c = 'Prueba'
        );
        insert demanda;

        // 2. Ejecutar el método
        Test.startTest();
        List<pba__Request__c> resultados = DemandaController.obtenerDemandas(anuncio.Id);
        Test.stopTest();

        // 3. Verificar que devuelve 1 resultado
        System.assertEquals(1, resultados.size(), 'Debe devolver 1 demanda que coincida con el anuncio');
    }


    @IsTest
    static void testSinDemandasCoincidientes(){
        // 1. Creamos los datos
        pba__Listing__c anuncio = new pba__Listing__c(
            Name = 'Anuncio Test',
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__ListingPrice_pb__c = 100000,  // Precio del anuncio
            pba__TotalArea_pb__c = 100        // Superficie del anuncio
        );
        //Insertamos el anuncio creado
        insert anuncio;
        
        //Ejecutamos la prueba sin crear demandas ya que no queremos que ninguna coincida
        Test.startTest();
            List<pba__Request__c> resultados = DemandaController.obtenerDemandas(anuncio.Id);
        Test.stopTest();

        //Verificacion de resultados
        System.AssertEquals(0, resultados.size(), 'Debe devolver 0 demanda que coincida con el anuncio');
    }


    @IsTest
    static void testMultiplesCoincidencias(){
        // 1. Creamos los datos del anuncio
        pba__Listing__c anuncio = new pba__Listing__c(
            Name = 'Anuncio Test',
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__ListingPrice_pb__c = 100000,  // Precio del anuncio
            pba__TotalArea_pb__c = 100        // Superficie del anuncio
        );
            //Insertamos el anuncio creado
            insert anuncio;
        
        //Creamos los datos de multiples demandas
        List<pba__Request__c> demanda = new List<pba__Request__c>{
            new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            Monthly_Net_Bare_Rent__c = 102000, // Precio dentro del rango
            pba__TotalArea_pb_min__c = 98,     // Superficie dentro del rango
            pba__Status__c = '5% - Primer contacto',
            Keyword__c = 'Prueba'
            ),

            new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            Monthly_Net_Bare_Rent__c = 100000, // Precio dentro del rango
            pba__TotalArea_pb_min__c = 100,     // Superficie dentro del rango
            pba__Status__c = '5% - Primer contacto',
            Keyword__c = '.'
            ),

            new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            Monthly_Net_Bare_Rent__c = 100000, // Precio dentro del rango
            pba__TotalArea_pb_min__c = 102,     // Superficie dentro del rango
            pba__Status__c = '25% - Análisis de la operación',
            Keyword__c = 'Prueba2'
            )
        };

        //Insertamos las demandas creadas
        insert demanda;

        // 2. Ejecutamos el metodo
        Test.startTest();
            List<pba__Request__c> resultados = DemandaController.obtenerDemandas(anuncio.Id);
        Test.stopTest();

        // 3. Verificamos los resultados
        System.AssertEquals(3, resultados.size(), 'Debe devolver 3 demandas que coincidan con el anuncio');

    }
}

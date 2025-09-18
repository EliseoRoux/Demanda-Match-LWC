
@isTest
private class DemandaTriggerTest {

    @TestSetup
    static void makeData(){
        Contact contactoAsesor = new Contact(LastName = 'Asesor de Pruebas', Email = 'asesor.test@example.com');
        insert contactoAsesor;

        
        Asesor__c asesor = new Asesor__c(Name = 'Asesor General', Asesor_contacto__c = contactoAsesor.Id);
        insert asesor;

        pba__Listing__c anuncio = new pba__Listing__c(
            Name = 'Anuncio Principal de Test',
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__ListingPrice_pb__c = 200000,
            pba__TotalArea_pb__c = 150,
            pba__Status__c = 'Activo',
            Asesor_General__c = asesor.Id,
            EV_Merchant_Agent__c = 'Juan Pérez'
        );
        insert anuncio;
    }

    @isTest
    static void testMatchConDemandaDeVenta() {
        pba__Listing__c anuncio = [SELECT Id FROM pba__Listing__c WHERE Name = 'Anuncio Principal de Test' LIMIT 1];

        Test.startTest();
        pba__Request__c demandaVenta = new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__TotalArea_pb_min__c = 140,
            pba__ListingPrice_pb_max__c = 210000,
            Monthly_Net_Bare_Rent__c = null,
            pba__ListingType__c = 'Oficina',
            pba__Status__c = '5% - Primer contacto'
        );
        insert demandaVenta;
        Test.stopTest();

        System.assertEquals(1, Limits.getEmailInvocations(), 'Debería enviarse un email para la demanda de venta.');
    }

    @isTest
    static void testMatchConDemandaDeAlquiler() {
        pba__Listing__c anuncio = [SELECT Id FROM pba__Listing__c WHERE Name = 'Anuncio Principal de Test' LIMIT 1];
        anuncio.pba__ListingPrice_pb__c = 1500;
        update anuncio;
        
        Test.startTest();
        pba__Request__c demandaAlquiler = new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__TotalArea_pb_min__c = 130,
            Monthly_Net_Bare_Rent__c = 1600,
            pba__ListingPrice_pb_max__c = null,
            pba__ListingType__c = 'Local Comercial',
            pba__Status__c = '25% - Análisis de la operación'
        );
        insert demandaAlquiler;
        Test.stopTest();
        
        System.assertEquals(1, Limits.getEmailInvocations(), 'Debería enviarse un email para la demanda de alquiler.');
    }

    @isTest
    static void testSinMatchPorEstadoInactivo() {
        pba__Listing__c anuncio = [SELECT Id FROM pba__Listing__c WHERE Name = 'Anuncio Principal de Test' LIMIT 1];
        anuncio.pba__Status__c = 'Inactivo';
        update anuncio;

        Test.startTest();
        
        pba__Request__c demanda = new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__TotalArea_pb_min__c = 145,
            pba__ListingPrice_pb_max__c = 200000
        );
        insert demanda;
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'NO debería enviarse un email si el anuncio está inactivo.');
    }

    @isTest
    static void testSinMatchPorPrecioFueraDeRango() {
        pba__Listing__c anuncio = [SELECT Id FROM pba__Listing__c WHERE Name = 'Anuncio Principal de Test' LIMIT 1];

        Test.startTest();
        
        pba__Request__c demanda = new pba__Request__c(
            EV_Merchant_Agent_Department__c = 'Ventas',
            pba__TotalArea_pb_min__c = 145,
            pba__ListingPrice_pb_max__c = 100000
        );
        insert demanda;
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'NO debería enviarse un email si el precio está fuera de rango.');
    }
}
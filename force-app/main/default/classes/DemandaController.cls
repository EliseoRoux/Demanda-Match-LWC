public with sharing class DemandaController {
    @AuraEnabled(cacheable=true)
    public static List<pba__Request__c> obtenerDemandas(Id anuncioId) {
        if(anuncioId == null) return new List<pba__Request__c>();

        // Obtenemos el anuncio con los datos que nos interesan
        pba__Listing__c anuncio = [
            SELECT Id, EV_Merchant_Agent_Department__c, pba__ListingPrice_pb__c, pba__TotalArea_pb__c
            FROM pba__Listing__c
            WHERE Id = :anuncioId
            LIMIT 1 
        ];

        // Calculamos un margen del 5% para el precio y la superficie
        Decimal precioMin = anuncio.pba__ListingPrice_pb__c * 0.80;
        Decimal precioMax = anuncio.pba__ListingPrice_pb__c * 1.20;
        Decimal supMin = anuncio.pba__TotalArea_pb__c * 0.80;
        Decimal supMax = anuncio.pba__TotalArea_pb__c * 1.20;

        // Buscamos demandas con las mismas caracteristicas que el anuncio
        return [
            SELECT 
                Id,
                Name, 
                EV_Merchant_Agent_Department__c, 
                pba__TotalArea_pb_min__c, 
                Monthly_Net_Bare_Rent__c,
                Asesor__c,
                Asesor__r.Name, 
                pba__Contact__c,
                pba__Contact__r.Name
            FROM pba__Request__c
            WHERE EV_Merchant_Agent_Department__c = :anuncio.EV_Merchant_Agent_Department__c
            AND Monthly_Net_Bare_Rent__c >= :precioMin 
            AND Monthly_Net_Bare_Rent__c <= :precioMax
            AND pba__TotalArea_pb_min__c >= :supMin
            AND pba__TotalArea_pb_min__c <= :supMax 
            AND (pba__Status__c = '5% - Primer contacto' 
                OR pba__Status__C = '25% - Análisis de la operación'
                OR pba__Status__c = '50% - Presentación de propiedades'
                OR pba__Status__c = '75% - Negociaciones'
            )
            //Añadimos la condición para evitar mostrar demandas que ya correspondan con el anuncio
            AND (ID_Anuncio__c = null OR ID_Anuncio__c != :anuncioId)
        ];
    }
}

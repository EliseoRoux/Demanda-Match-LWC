
public with sharing class DemandaTriggerHandler {

    public static void handleAfterInsert(List<pba__Request__c> nuevasDemandas) {
        Map<Id, List<pba__Listing__c>> mapaDemandasAAnuncios = buscarAnunciosParaDemandas(nuevasDemandas);

        if (!mapaDemandasAAnuncios.isEmpty()) {
            enviarNotificaciones(mapaDemandasAAnuncios);
        }
    }

    private static Map<Id, List<pba__Listing__c>> buscarAnunciosParaDemandas(List<pba__Request__c> demandas) {
        Map<Id, List<pba__Listing__c>> resultado = new Map<Id, List<pba__Listing__c>>();
        Set<String> estadosActivos = new Set<String>{'Activo', 'Activo - no publicar'};

        for (pba__Request__c demanda : demandas) {
            Decimal precioMin = demanda.Monthly_Net_Bare_Rent__c != null && demanda.Monthly_Net_Bare_Rent__c > 0 
                ? demanda.Monthly_Net_Bare_Rent__c * 0.80
                : demanda.pba__ListingPrice_pb_max__c * 0.80;
            
            Decimal precioMax = demanda.Monthly_Net_Bare_Rent__c != null && demanda.Monthly_Net_Bare_Rent__c > 0
                ? demanda.Monthly_Net_Bare_Rent__c * 1.20
                : demanda.pba__ListingPrice_pb_max__c * 1.20;

            Decimal supMin = demanda.pba__TotalArea_pb_min__c * 0.80;
            Decimal supMax = demanda.pba__TotalArea_pb_min__c * 1.20;

            List<pba__Listing__c> anunciosCoincidentes = [
                SELECT Id, Name, Asesor_General__r.Asesor_contacto__r.Email, EV_Merchant_Agent__c
                FROM pba__Listing__c
                WHERE Asesor_General__r.Asesor_contacto__r.Email != null
                  AND pba__Status__c IN :estadosActivos  
                  AND EV_Merchant_Agent_Department__c = :demanda.EV_Merchant_Agent_Department__c
                  AND pba__ListingPrice_pb__c >= :precioMin
                  AND pba__ListingPrice_pb__c <= :precioMax
                  AND pba__TotalArea_pb__c >= :supMin
                  AND pba__TotalArea_pb__c <= :supMax
            ];

            if (!anunciosCoincidentes.isEmpty()) {
                resultado.put(demanda.Id, anunciosCoincidentes);
            }
        }
        return resultado;
    }

    private static void enviarNotificaciones(Map<Id, List<pba__Listing__c>> mapaDemandasAAnuncios) {
        List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
        
        Map<Id, pba__Request__c> demandas = new Map<Id, pba__Request__c>([
            SELECT Name, Asesor__r.MobilePhone, pba__ListingType__c, pba__TotalArea_pb_min__c, Monthly_Net_Bare_Rent__c, pba__ListingPrice_pb_max__c
            FROM pba__Request__c 
            WHERE Id IN :mapaDemandasAAnuncios.keySet()
        ]);

        for (Id demandaId : mapaDemandasAAnuncios.keySet()) {
            pba__Request__c demandaActual = demandas.get(demandaId);
            
            // Recopilamos los datos de la demanda con control de nulos
            String nombreDemanda = demandaActual.Name;
            String tlf = demandaActual.Asesor__r.MobilePhone != null ? demandaActual.Asesor__r.MobilePhone : 'No disponible';
            String tipoAnuncio = demandaActual.pba__ListingType__c != null ? demandaActual.pba__ListingType__c : 'No especificado';
            Decimal superficie = demandaActual.pba__TotalArea_pb_min__c != null ? demandaActual.pba__TotalArea_pb_min__c : 0;
            Decimal precioRenta = demandaActual.Monthly_Net_Bare_Rent__c != null ? demandaActual.Monthly_Net_Bare_Rent__c : 0;
            Decimal precioVenta = demandaActual.pba__ListingPrice_pb_max__c != null ? demandaActual.pba__ListingPrice_pb_max__c : 0;
            
            for (pba__Listing__c anuncio : mapaDemandasAAnuncios.get(demandaId)) {
                String emailAsesor = anuncio.Asesor_General__r.Asesor_contacto__r.Email;
                String nombreAsesor = anuncio.EV_Merchant_Agent__c != null ? anuncio.EV_Merchant_Agent__c : 'Asesor';

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { emailAsesor });
                mail.setSubject('¡Demanda coincidente para tu anuncio: ' + anuncio.Name + '!');
                
                // Construimos el cuerpo del email con todos los detalles ---
                String body = 'Hola, ' + nombreAsesor + '<br/><br/>';
                body += 'Se ha creado una nueva demanda que coincide con los criterios de tu anuncio: <b>' + anuncio.Name + '</b>.<br/><br/>';
                body += '<b>Detalles de la demanda:</b><br/>';
                body += '<ul>';
                body += '<li><b>Demanda:</b> ' + nombreDemanda + '</li>';
                body += '<li><b>Tipo:</b> ' + tipoAnuncio + '</li>';
                body += '<li><b>Superficie Mínima:</b> ' + superficie + ' m²</li>';

                // Lógica para mostrar el precio correcto
                if (precioRenta > 0) {
                    body += '<li><b>Precio Renta:</b> ' + precioRenta.format() + ' €</li>';
                } else if (precioVenta > 0) {
                    body += '<li><b>Precio Venta:</b> ' + precioVenta.format() + ' €</li>';
                }

                body += '<li><b>Teléfono del Asesor:</b> ' + tlf + '</li>';
                body += '</ul><br/>';
                body += 'Te recomendamos revisarla.<br/>';
                body += '¡Un saludo!';
                
                mail.setHtmlBody(body);
                correos.add(mail);
            }
        }

        if (!correos.isEmpty()) {
            try {
                Messaging.sendEmail(correos);
            } catch (Exception e) {
                System.debug('Error al enviar correos de match: ' + e.getMessage());
            }
        }
    }
}
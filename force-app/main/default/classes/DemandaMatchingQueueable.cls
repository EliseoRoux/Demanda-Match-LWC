public class DemandaMatchingQueueable implements Queueable {

    private Set<Id> demandaIds;

    public DemandaMatchingQueueable(Set<Id> ids) {
        this.demandaIds = ids;
    }

    public void execute(QueueableContext context) {
        List<pba__Request__c> demandas = [
            SELECT Id, EV_Merchant_Agent_Department__c, Monthly_Net_Bare_Rent__c, 
                   pba__ListingPrice_pb_max__c, pba__TotalArea_pb_min__c 
            FROM pba__Request__c 
            WHERE Id IN :demandaIds
        ];
        
        List<pba__Request__c> demandasConDepartamento = new List<pba__Request__c>();
        for (pba__Request__c d : demandas) {
            if (d.EV_Merchant_Agent_Department__c != null) {
                demandasConDepartamento.add(d);
            }
        }
        
        if (!demandasConDepartamento.isEmpty()) {
            Map<Id, List<pba__Listing__c>> mapaDemandasAAnuncios = buscarAnunciosParaDemandas(demandasConDepartamento);
            if (!mapaDemandasAAnuncios.isEmpty()) {
                enviarNotificaciones(mapaDemandasAAnuncios);
            }
        }
    }

    private static Map<Id, List<pba__Listing__c>> buscarAnunciosParaDemandas(List<pba__Request__c> demandas) {
        Map<Id, List<pba__Listing__c>> resultado = new Map<Id, List<pba__Listing__c>>();
        
        Set<String> estadosActivos = new Set<String>{'Active', 'Active - not to publish'};
        
        Set<String> departments = new Set<String>();
        for(pba__Request__c dem : demandas) {
            if(dem.EV_Merchant_Agent_Department__c != null) {
                departments.add(dem.EV_Merchant_Agent_Department__c);
            }
        }

        if(departments.isEmpty()){ return resultado; }

        List<pba__Listing__c> todosLosAnuncios = [
            SELECT Id, Name, Asesor_General__r.Asesor_contacto__r.Email, EV_Merchant_Agent__c,
                   EV_Merchant_Agent_Department__c, pba__ListingPrice_pb__c, pba__TotalArea_pb__c
            FROM pba__Listing__c
            WHERE pba__Status__c IN :estadosActivos
              AND EV_Merchant_Agent_Department__c IN :departments
        ];

        if(todosLosAnuncios.isEmpty()){ return resultado; }

        for (pba__Request__c demanda : demandas) {
            Decimal precioDemanda = (demanda.Monthly_Net_Bare_Rent__c != null && demanda.Monthly_Net_Bare_Rent__c > 0) 
                                    ? demanda.Monthly_Net_Bare_Rent__c 
                                    : demanda.pba__ListingPrice_pb_max__c;
            if(precioDemanda == null) continue;

            Decimal precioMin = precioDemanda * 0.80;
            Decimal precioMax = precioDemanda * 1.20;
            Decimal supMin = demanda.pba__TotalArea_pb_min__c != null ? demanda.pba__TotalArea_pb_min__c * 0.80 : 0;
            Decimal supMax = demanda.pba__TotalArea_pb_min__c != null ? demanda.pba__TotalArea_pb_min__c * 1.20 : 0;
            
            List<pba__Listing__c> anunciosCoincidentes = new List<pba__Listing__c>();
            for(pba__Listing__c anuncio : todosLosAnuncios) {
                if (anuncio.EV_Merchant_Agent_Department__c == demanda.EV_Merchant_Agent_Department__c &&
                    anuncio.pba__ListingPrice_pb__c >= precioMin &&
                    anuncio.pba__ListingPrice_pb__c <= precioMax &&
                    anuncio.pba__TotalArea_pb__c >= supMin &&
                    anuncio.pba__TotalArea_pb__c <= supMax)
                {
                    anunciosCoincidentes.add(anuncio);
                }
            }
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
            String nombreDemanda = demandaActual.Name;
            String tlf = demandaActual.Asesor__r.MobilePhone != null ? demandaActual.Asesor__r.MobilePhone : 'No disponible';
            String tipoAnuncio = demandaActual.pba__ListingType__c != null ? demandaActual.pba__ListingType__c : 'No especificado';
            Decimal superficie = demandaActual.pba__TotalArea_pb_min__c != null ? demandaActual.pba__TotalArea_pb_min__c : 0;
            Decimal precioRenta = demandaActual.Monthly_Net_Bare_Rent__c != null ? demandaActual.Monthly_Net_Bare_Rent__c : 0;
            Decimal precioVenta = demandaActual.pba__ListingPrice_pb_max__c != null ? demandaActual.pba__ListingPrice_pb_max__c : 0;
            
            for (pba__Listing__c anuncio : mapaDemandasAAnuncios.get(demandaId)) {
                String emailAsesor = anuncio.Asesor_General__r.Asesor_contacto__r.Email;
                if(emailAsesor != null) {
                    String nombreAsesor = anuncio.EV_Merchant_Agent__c != null ? anuncio.EV_Merchant_Agent__c : 'Asesor';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] { emailAsesor });
                    mail.setSubject('¡Demanda coincidente para tu anuncio: ' + anuncio.Name + '!');
                    String body = 'Hola, ' + nombreAsesor + '<br/><br/>';
                    body += 'Se ha creado una nueva demanda que coincide con los criterios de tu anuncio: <b>' + anuncio.Name + '</b>.<br/><br/>';
                    body += '<b>Detalles de la demanda:</b><br/>';
                    body += '<ul>';
                    body += '<li><b>Demanda:</b> ' + nombreDemanda + '</li>';
                    body += '<li><b>Tipo:</b> ' + tipoAnuncio + '</li>';
                    body += '<li><b>Superficie Mínima:</b> ' + superficie + ' m²</li>';
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
        }
        
        if (!correos.isEmpty()) {
            try {
                Messaging.sendEmail(correos);
            } catch (Exception e) {
                System.debug('QUEUEABLE FATAL ERROR al enviar correos: ' + e.getMessage());
            }
        }
    }
}
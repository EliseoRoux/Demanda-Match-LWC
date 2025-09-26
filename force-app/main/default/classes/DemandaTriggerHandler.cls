public with sharing class DemandaTriggerHandler {

    public static void handleAfterInsert(List<pba__Request__c> nuevasDemandas) {
        // Solo llamamos al proceso asíncrono si no estamos en un test
        if (!Test.isRunningTest()) {
            // Creamos un Set con los Ids de las nuevas demandas
            Set<Id> demandaIds = (new Map<Id, pba__Request__c>(nuevasDemandas)).keySet();
            
            // Creamos una instancia de nuestra clase Queueable y la encolamos
            DemandaMatchingQueueable job = new DemandaMatchingQueueable(demandaIds);
            System.enqueueJob(job);
        }
    }
}
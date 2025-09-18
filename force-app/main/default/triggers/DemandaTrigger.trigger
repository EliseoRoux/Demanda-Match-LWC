
trigger DemandaTrigger on pba__Request__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        // Llama a la clase que manejará la lógica
        DemandaTriggerHandler.handleAfterInsert(Trigger.new);
    }
}
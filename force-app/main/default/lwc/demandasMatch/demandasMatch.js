import { LightningElement, track, wire, api } from 'lwc';
import obtenerDemandas from '@salesforce/apex/DemandaController.obtenerDemandas';

export default class DemandasMatch extends LightningElement {
    @api recordId;
    @track demandas = [];
    @track noResults = false;
    @track error;

    @wire(obtenerDemandas, { anuncioId: '$recordId' })
    wiredDemandas({ error, data }) {
        if (data) {
            this.demandas = data.map(d => ({
                ...d,
                demandaLink: `/lightning/r/pba__Request__c/${d.Id}/view`,
                asesorLink: d.Asesor__c ? `/lightning/r/User/${d.Asesor__c}/view` : '',
                contactoLink: d.pba__Contact__c ? `/lightning/r/Contact/${d.pba__Contact__c}/view` : ''
            }));
            this.noResults = data.length === 0;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.noResults = true;
            console.error('Error al obtener demandas:', error);
        }
    }
}

/* Importación de los módulos necesarios a utilizar en el componente. */
import { LightningElement, api, wire } from 'lwc';
import COPILOTO_FIELD from '@salesforce/schema/Product2.Copiloto__c';
import PILOTO_FIELD from '@salesforce/schema/Product2.Piloto__c';
import obtenerAuxiliares from '@salesforce/apex/TripulacionRequerida.obtenerAuxiliares';
import saveAuxiliares from '@salesforce/apex/TripulacionRequerida.saveAuxiliares';


export default class EditarVuelo extends LightningElement {
    piloto = PILOTO_FIELD;
    copiloto = COPILOTO_FIELD;

    /* Declarar las variables que se utilizarán en el código. */
    @api vueloId;   
    options = [];
    values = [];
    _selected = []

    /**
      Se llama al adaptador de cable cada vez que se actualiza los vuelos 
     */
    @wire(obtenerAuxiliares, {idVuelo : '$vueloId'})
    tripulantes({ error, data }) {
        if (data) {
            this.options = data.map(key => ({ value: key.value, label: key.label }));
            this.values = data.filter(element => element.selected == true).map(key => key.value);
        } else if (error) {
            console.log('error-->'+JSON.stringify(error));
        }
    }

    /**
     La función handleChange se llama cuando el usuario selecciona un valor del menú desplegable.
     */
    handleChange(e) {
        this._selected = e.detail.value;
    }

    /**
     * Guarda los auxiliares seleccionados en la base de datos.
     */
    handleSuccess(event) {
        if(this._selected.length == 0){
            this._selected = this.values;
        }
        saveAuxiliares({auxiliares : this._selected, idvuelo : this.vueloId})
        .then((result) => {
            console.log('sucess');
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.log(error);
        });
    }

}
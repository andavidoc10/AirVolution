/* Importando los módulos necesarios para crear un nuevo registro de contacto. */
import { LightningElement} from 'lwc';
import {createRecord } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FIRSTNAME from '@salesforce/schema/Contact.FirstName';
import LASTNAME from '@salesforce/schema/Contact.LastName';
import TIPODEIDENTIFICACION from '@salesforce/schema/Contact.Tipo_de_Identificaci_n__c';
import NUMERODEIDENTIFICACION from '@salesforce/schema/Contact.N_mero_de_Identificaci_n__c';
import NUMERODEPASAPORTE from '@salesforce/schema/Contact.N_mero_de_pasaporte__c';
import FECHADENACIMIENTO from '@salesforce/schema/Contact.Birthdate';
import CORREOELECTRONICO from '@salesforce/schema/Contact.Email';
import NACIONALIDAD from '@salesforce/schema/Contact.Nacionalidad__c';


export default class ActualizarCliente extends LightningElement {
    /* Declarar las variables que se utilizarán en el componente. */
    objectApiName = CONTACT_OBJECT;
    contactId;
    firstName = '';
    lastName = '';
    tipoDeIdentificacion = '';
    numeroDeIdentificacion = '';
    numeroDePasaporte = '';
    fechaDeNacimiento = '';
    correoElectronico = '';
    nacionalidad = '';

    /**
     * Toma el valor del campo de entrada y lo asigna a la variable correspondiente
     */
    handleContactChange(event){
        switch(event.target.name){
            case 'firstName':
                this.firstName = event.target.value;
                break;
            case 'lastName':
                this.lastName = event.target.value;
                break;
            case 'tipoDeIdentificacion':
                this.tipoDeIdentificacion = event.target.value;
                break;
            case 'numeroDeIdentificacion':
                this.numeroDeIdentificacion = event.target.value;
                break;  
            case 'numeroDePasaporte':
                this.numeroDePasaporte = event.target.value;
                break;
            case 'fechaDeNacimiento':
                this.fechaDeNacimiento = event.target.value;
                break;
            case 'correoElectronico':
                this.correoElectronico = event.target.value;
                break;
            case 'nacionalidad':
                this.nacionalidad = event.target.value;
                break;
 
        }
    }

    /**
     * La función crea un nuevo registro de contacto con los valores de los campos que se pasan en la función
     */
    createContact(){
        const fields = {}
        fields[FIRSTNAME.fieldApiName] = this.firstName;
        fields[LASTNAME.fieldApiName] = this.lastName;
        fields[TIPODEIDENTIFICACION.fieldApiName] = this.tipoDeIdentificacion;
        fields[NUMERODEIDENTIFICACION.fieldApiName] = this.numeroDeIdentificacion;
        fields[NUMERODEPASAPORTE.fieldApiName] = this.numeroDePasaporte;
        fields[FECHADENACIMIENTO.fieldApiName] = this.fechaDeNacimiento;
        fields[CORREOELECTRONICO.fieldApiName] = this.correoElectronico;
        fields[NACIONALIDAD.fieldApiName] = this.nacionalidad;
        const recordInput ={apiName: CONTACT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(contact => {
            this.contactId = contact.id;
            console.log(fields);
            console.log('Cuenta agregada con éxito');
        })
        .catch(error => {
            console.error(error);
        })
    }

}
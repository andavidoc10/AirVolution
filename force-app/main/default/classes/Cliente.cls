public with sharing class Cliente {

    // Busca un contacto y una reserva con los parametros enviados desde JavaScrip y retorna la existencia o nulidad de estos.
    @AuraEnabled
    public static CtoReserva clienteReserva(string documento, string tipoDoc){
         contact cliente = null;
         Opportunity reserva = null;

        List<Contact> pasajero = [SELECT Id,Name FROM Contact WHERE N_mero_de_Identificaci_n__c =: documento 
                                    AND Tipo_de_Identificaci_n__c =: tipoDoc LIMIT 1];
        List<Opportunity> reservaExistente = new List<Opportunity>();

        if(pasajero.size() == 1){
            cliente = pasajero[0];
            reservaExistente = [SELECT Id,Name FROM Opportunity WHERE Titular_de_reserva__c =: cliente.Id 
                                    AND StageName NOT IN ('Pagado','no pagado')  LIMIT 1];
        }
        
        if(reservaExistente.size() == 1){
            reserva = reservaExistente[0];
        }
        
        CtoReserva resultado = new CtoReserva(cliente, reserva);

        return resultado;
    }

    // Se crea un Wrapper para el retorno del metodo clienteReserva
    public class CtoReserva{
        @auraEnabled
        public Contact contacto;
        @auraEnabled
        public Opportunity oportunidad;

        public CtoReserva(Contact pasajero, Opportunity reserva){
            contacto = pasajero;
            oportunidad = reserva;
        }
    }

    //Obtiene la lista de vuelos con la lista de precios de la reserva seleccionada y que están programados para una fecha posterior a hoy
    @AuraEnabled(cacheable = true)
    public static list<vueloWrapper> obtenerVuelos(string precio){
        List<Product2> vuelos = [SELECT Id, Name, Aeropuerto_de_Partida__r.Name,
                                Aeropuerto_de_Llegada__r.Name, Fecha_y_hora_de_partida__c, 
                                Fecha_y_hora_estimada_de_llegada__c, (SELECT unitPrice FROM PricebookEntries WHERE Pricebook2Id =: precio)
                                FROM Product2 
                                WHERE Fecha_y_hora_de_partida__c > today];
        
        List<vueloWrapper> listaVuelos = new List<vueloWrapper>();
        for(Product2 a : vuelos){
            if(a.PricebookEntries.size() > 0){
            listaVuelos.add(new vueloWrapper((String)a.Id, a.Name, a.Aeropuerto_de_Partida__r.Name, a.Aeropuerto_de_Llegada__r.Name,
                                             a.Fecha_y_hora_de_partida__c, a.Fecha_y_hora_estimada_de_llegada__c, a.PricebookEntries[0].UnitPrice));
            }
        }

        return listaVuelos;
    }

    // Se crea un Wrapper para el retorno del metodo obtenerVuelos
    public class vueloWrapper {
        @auraEnabled
        public string idVuelo;
        @auraEnabled
        public string nombreVuelo;
        @auraEnabled
        public string aeroPartida;
        @auraEnabled
        public string aeroLlegada;
        @auraEnabled
        public Datetime fechaPartida;
        @auraEnabled
        public Datetime fechaLlegada;
        @auraEnabled
        public Decimal valor;
        


        public vueloWrapper(string idV, string nvuelo, string apartida, String allegada, Datetime fepartida, Datetime fellegada, Decimal precio){
            idVuelo = idV;
            nombreVuelo = nvuelo;
            aeroPartida = apartida;
            aeroLlegada = allegada;
            fechaPartida = fepartida;
            fechaLlegada = fellegada;
            valor = precio;
        }
    }


    //Recibe el nombre de una entrada de precios, y devuelve el Id para posteriormente buscar vuelos con esta entrada de precios
    @AuraEnabled(cacheable = true)
    public static string listaPrecios(string entradaDeLista){
        Pricebook2 precios = [SELECT Id FROM Pricebook2 WHERE  Name =: entradaDeLista LIMIT 1];
        string nombreLista = precios.Id;
        return nombreLista;
    }
    
    //Crea un tiquete con los parametros que recibe desde el componente reservaCompleta
    // ! Cambio void por tiquete
    @AuraEnabled
    public static OpportunityLineItem crearTiquete(string reserva, string vuelo, string pasajero){
        try {
            OpportunityLineItem tiquete = new OpportunityLineItem(OpportunityId = reserva, Product2Id = vuelo, Pasajero__c = pasajero);
            insert tiquete;
            Opportunity completa = new Opportunity(Id = reserva, StageName = 'Completado');
            update completa;
            return tiquete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    }
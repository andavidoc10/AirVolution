@isTest
public with sharing class WebServiceVueloTest {
    
    @TestSetup
    static void makeData(){
        contact pasajero = new Contact(FirstName = 'Andrés', LastName = 'David', Tipo_de_Identificaci_n__c = 'Cédula de ciudadanía', N_mero_de_Identificaci_n__c = '1017', Email = 'andresarca65@gmail.com');
        insert pasajero;
        Datetime tiempo = Datetime.now();
        List<Aeropuerto__c> aeropuertos = new List<Aeropuerto__c>();
        aeropuertos.add(new Aeropuerto__c(Name = 'Aeropuerto Medellín', Ciudad__c = 'Cali'));
        aeropuertos.add(new Aeropuerto__c(Name = 'Aeropuerto Bogotá', Ciudad__c = 'Bogotá'));
        insert aeropuertos;

        avi_n__c avion = new avi_n__c();
        insert avion;

        Product2 vuelo = new Product2(Name = 'vuelo Prueba',Aeropuerto_de_partida__c = aeropuertos[0].Id,
                                     Aeropuerto_de_llegada__c= aeropuertos[1].Id, Fecha_y_hora_de_partida__c = tiempo,
                                     Fecha_y_hora_estimada_de_llegada__c = tiempo.addHours(1), avi_n__c = avion.Id, IsActive = true);
        insert vuelo;

        Id idEstandar = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry( Pricebook2Id = idEstandar, Product2Id = vuelo.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 turista = new Pricebook2(Name = 'Tiquetes clase turista', IsActive = true);
        insert turista;
        Pricebook2 negocios = new Pricebook2(Name = 'Tiquetes Negocios', IsActive = true);  
        insert negocios;
        
        PricebookEntry entrada = new PricebookEntry(Pricebook2Id = turista.id, Product2Id = vuelo.Id, UnitPrice = 20000, IsActive = true);
        insert entrada;
    }

    @isTest
    static void busquedaExitosa(){
        Product2 vuelo = [SELECT Id FROM Product2 LIMIT 1];
        // Set up a test request
        RestRequest request = new RestRequest();
        String fecha = (Date.today().format()).replace('/','-');
        // Set request properties
        request.requestUri = 'services/apexrest/Product2/';
        request.addParameter('fechaMenor', fecha);
        request.addParameter('ciudadPartida', 'Cali');
        request.addParameter('ciudadDestino', 'Bogotá');
        request.addParameter('clase', 'Tiquetes clase turista');
        request.httpMethod = 'GET';
        // more awesome code here....
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        WebServiceVuelo.Respuesta respuesta = WebServiceVuelo.obtenerVuelos();

        System.assertEquals('La solicitud ha sido exitosa', respuesta.mensaje);
        System.assertEquals(true, respuesta.exitoso);
        System.assertEquals(1, respuesta.vuelos.size());
     }
     @isTest
     static void fechaInicalFalla(){
         // Set up a test request
         RestRequest request = new RestRequest();
         // Set request properties
         request.requestUri = 'services/apexrest/Product2/';
         request.addParameter('fechaMenor', '05-09-202');
         request.addParameter('ciudadPartida', 'Cali');
         request.addParameter('ciudadDestino', 'Bogotá');
        request.addParameter('clase', 'Tiquetes Negocios');
         request.httpMethod = 'GET';
         // more awesome code here....
         // Finally, assign the request to RestContext if used
         RestContext.request = request;
         WebServiceVuelo.Respuesta respuesta = WebServiceVuelo.obtenerVuelos();
 
         System.assertEquals('El formato de fecha inicial correcto  es: dd-mm-yyyy.', respuesta.mensaje);
         System.assertEquals(false, respuesta.exitoso);
         
     }


     @isTest
     static void partidaFalla(){
         // Set up a test request
         RestRequest request = new RestRequest();
         // Set request properties
         request.requestUri = 'services/apexrest/Product2/';
         request.addParameter('fechaMenor', '05-09-2022');
         request.addParameter('ciudadPartida', 'los menores');
         request.addParameter('ciudadDestino', 'Bogotá');
         request.addParameter('clase', 'Tiquetes Negocios');
         
         request.httpMethod = 'GET';
         // more awesome code here....
         // Finally, assign the request to RestContext if used
         RestContext.request = request;
         WebServiceVuelo.Respuesta respuesta = WebServiceVuelo.obtenerVuelos();
 
         System.assertEquals('La ciudad de partida no está en el catalogo de la compañia', respuesta.mensaje);
         System.assertEquals(false, respuesta.exitoso);
         
     }

     @isTest
     static void llegadaFalla(){
         // Set up a test request
         RestRequest request = new RestRequest();
         // Set request properties
         request.requestUri = 'services/apexrest/Product2/';
         request.addParameter('fechaMenor', '05-09-2022');
         request.addParameter('ciudadPartida', 'Cali');
         request.addParameter('ciudadDestino', 'Los rolos');
         request.addParameter('clase', 'Tiquetes Negocios');
         request.httpMethod = 'GET';
         // more awesome code here....
         // Finally, assign the request to RestContext if used
         RestContext.request = request;
         WebServiceVuelo.Respuesta respuesta = WebServiceVuelo.obtenerVuelos();
 
         System.assertEquals('La ciudad de destino no está en el catalogo de la compañia', respuesta.mensaje);
         System.assertEquals(false, respuesta.exitoso);
         
     }


}
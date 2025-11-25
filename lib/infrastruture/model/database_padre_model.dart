
import 'package:school_maps/domain/entities/padre.dart';

class DatabasePadreModel{

  final String nombrePadre;
  final int documento;
  final String correo;
  final String rol;
  final String direccion;
  final List<int> documentoHijo;
  final String placaRutaAsignada;
  
  DatabasePadreModel({

    required this.nombrePadre,
    required this.documento,
    required this.correo,
    this.rol = 'Padre',
    required this.direccion,
    required this.documentoHijo,
    required this.placaRutaAsignada
    
  });

  factory DatabasePadreModel.fromFirestore( Map<String, dynamic> firestore ) => DatabasePadreModel(
    nombrePadre: firestore[ 'nombrePadre' ], 
    documento: firestore[ 'documentoPadre' ], 
    correo: firestore[ 'correo' ],
    rol: firestore[ 'rol' ],
    direccion: firestore[ 'direccion' ], 
    documentoHijo: firestore[ 'documentoHijo' ].cast<int>(), 
    placaRutaAsignada: firestore[ 'placa' ]
  );

  Map<String, dynamic> toFirebase() => {

    'nombrePadre' : nombrePadre,
    'documentoPadre' : documento,
    'correo' : correo,
    'rol' : rol,
    'direccion' : direccion,
    'documentoHijo' : documentoHijo,
    'placa' : placaRutaAsignada,

  };

  Padre toPadreEntity() => Padre(

    nombre: nombrePadre, 
    documento: documento, 
    correo: correo,
    rol: rol,
    direccion: direccion, 
    documentoHijo: documentoHijo, 
    placaRutaAsignada: placaRutaAsignada
    
  );

}
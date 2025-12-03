
import 'package:school_maps/domain/entities/padre.dart';

class DatabasePadreModel{

  final String nombre;
  final int documento;
  final String correo;
  final String rol;
  final String direccion;
  List<int> documentoHijo;
  final String placaRutaAsignada;
  final String uId;
  
  DatabasePadreModel({

    required this.nombre,
    required this.documento,
    required this.correo,
    this.rol = 'Acudiente',
    required this.direccion,
    List<int>? documentoHijo,
    this.placaRutaAsignada = '',
    required this.uId
    
  }) : documentoHijo = documentoHijo ?? [];

  factory DatabasePadreModel.fromFirestore( Map<String, dynamic> firestore ) => DatabasePadreModel(
    nombre: firestore[ 'nombrePadre' ], 
    documento: firestore[ 'documentoPadre' ], 
    correo: firestore[ 'correo' ],
    rol: firestore[ 'rol' ],
    direccion: firestore[ 'direccion' ], 
    documentoHijo: firestore[ 'documentoHijo' ].cast<int>(), 
    placaRutaAsignada: firestore[ 'placa' ],
    uId: firestore[ 'uId' ]
  );

  Map<String, dynamic> toFirebase() => {

    'nombrePadre' : nombre,
    'documentoPadre' : documento,
    'correo' : correo,
    'rol' : rol,
    'direccion' : direccion,
    'documentoHijo' : documentoHijo,
    'placa' : placaRutaAsignada,
    'uId': uId

  };

  Padre toPadreEntity() => Padre(

    nombre: nombre, 
    documento: documento, 
    correo: correo,
    rol: rol,
    direccion: direccion, 
    documentoHijo: documentoHijo, 
    placaRutaAsignada: placaRutaAsignada,
    uId: uId
    
  );

}
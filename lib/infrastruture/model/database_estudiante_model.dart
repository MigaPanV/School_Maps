
import 'package:school_maps/domain/entities/estudiante.dart';

class DatabaseEstudianteModel{

  final String nombreEstudiante;
  final int documento;
  final int grado;
  final double lat;
  final double lng;
  bool recogido;
  final int cedulaAcudiente;
  final String placaRutaAsignada;
  final String direccion;

  DatabaseEstudianteModel({

    required this.nombreEstudiante,
    required this.documento,
    required this.grado,
    required this.lat,
    required this.lng,
    required this.cedulaAcudiente,
    this.placaRutaAsignada = '',
    required this.direccion,

    this.recogido = false
  });

  factory DatabaseEstudianteModel.fromFirestore( Map<String, dynamic> firestore ) => DatabaseEstudianteModel(
    
    nombreEstudiante: firestore[ 'nombreEstudiante' ], 
    documento: firestore[ 'documentoEstudiante' ], 
    grado: firestore[ 'grado' ],
    lat: firestore[ 'lat' ], 
    lng: firestore[ 'lng' ],
    cedulaAcudiente: firestore[ 'cedulaAcudiente' ], 
    placaRutaAsignada: firestore[ 'placa' ], 
    direccion: firestore[ 'direccion' ]
  );

  Map<String, dynamic> toFirestore() => {
    'nombreEstudiante' : nombreEstudiante,
    'documentoEstudiante' : documento,
    'grado' : grado,
    'lat': lat,
    'lng': lng,    
    'cedulaAcudiente' : cedulaAcudiente,
    'placa' : placaRutaAsignada,
    'direccion' : direccion,
  };

  Estudiante toEstudianteEntity() => Estudiante(
    
    nombreEstudiante: nombreEstudiante, 
    documento: documento, 
    grado: grado,
    lat: lat,
    lng: lng,
    cedulaAcudiente: cedulaAcudiente, 
    placaRutaAsignada: placaRutaAsignada, 
    direccion: direccion
    
  );
}
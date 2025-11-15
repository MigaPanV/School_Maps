
import 'package:school_maps/domain/entities/estudiante.dart';

class DatabaseEstudianteModel{

  final String nombreEstudiante;
  final int documento;
  bool recogido;
  final String nombreAcudiente;
  final String placaRutaAsignada;
  final String direccion;

  DatabaseEstudianteModel({

    required this.nombreEstudiante,
    required this.documento,
    required this.nombreAcudiente,
    required this.placaRutaAsignada,
    required this.direccion,

    this.recogido = false
  });

  factory DatabaseEstudianteModel.fromFirestore( Map<String, dynamic> firestore ) => DatabaseEstudianteModel(
    
    nombreEstudiante: firestore[ 'nombreEstudiante' ], 
    documento: firestore[ 'documentoEstudiante' ], 
    nombreAcudiente: firestore[ 'nombreAcudiente' ], 
    placaRutaAsignada: firestore[ 'placa' ], 
    direccion: firestore[ 'direccion' ]
  );

  Map<String, dynamic> toFirestore() => {
    'nombreEstudiante' : nombreEstudiante,
    'documentoEstudiante' : documento,
    'nombreAcudiente' : nombreAcudiente,
    'placa' : placaRutaAsignada,
    'direccion' : direccion,
  };

  Estudiante toEstudianteEntity() => Estudiante(
    
    nombreEstudiante: nombreEstudiante, 
    documento: documento, 
    nombreAcudiente: nombreAcudiente, 
    placaRutaAsignada: placaRutaAsignada, 
    direccion: direccion
    
  );
}
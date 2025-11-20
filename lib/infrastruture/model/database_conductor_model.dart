
import 'package:school_maps/domain/entities/conductor.dart';

class DatabaseConductorModel{

  final String nombreConductor;
  final int documento;
  final String correo;
  final String rol;
  final String vencimientoLicencia;
  final String placaRutaAsignada;

  DatabaseConductorModel({ 

    required this.nombreConductor,
    required this.documento,
    required this.correo,
    this.rol = 'Conductor',
    required this.vencimientoLicencia,
    required this.placaRutaAsignada

  });

  factory DatabaseConductorModel.fromFirestore(Map<String, dynamic> firestore) => DatabaseConductorModel(
    nombreConductor: firestore[ 'nombreConductor' ], 
    documento: firestore[ 'documentoConductor' ],
    correo: firestore[ 'correo' ],
    rol: firestore[ 'rol' ],
    vencimientoLicencia: firestore[ 'vencimientoLicencia' ], 
    placaRutaAsignada: firestore[ 'placa' ]
  );

  Map<String, dynamic> toFirestore() => {
    'nombreConductor' : nombreConductor,
    'documentoConductor' : documento,
    'correo' : correo,
    'rol' : rol,
    'vencimientoLicencia' : vencimientoLicencia,
    'placa' : placaRutaAsignada,
  };

  Conductor toConductorEntity() => Conductor(
    
    nombreConductor: nombreConductor,
    documento: documento,
    correo: correo,
    rol: rol,
    vencimientoLicencia: vencimientoLicencia, 
    placaRutaAsignada: placaRutaAsignada
  );
}
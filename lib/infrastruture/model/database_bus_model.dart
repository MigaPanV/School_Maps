
import 'package:school_maps/domain/entities/bus.dart';

class DatabaseBusModel {

  final String placa;
  final String nombreConductor;
  final String tecnoVencimiento;
  final String monitora;
  final String soatVencimiento;
  final String capacidad;
  final String extintorVencimiento;
  final String kmRecorridos;

  DatabaseBusModel ({

    required this.placa,
    required this.nombreConductor,
    required this.tecnoVencimiento,
    required this.soatVencimiento,
    required this.monitora,
    required this.capacidad,
    required this.extintorVencimiento,
    required this.kmRecorridos

  });

  factory DatabaseBusModel.fromFirestore( Map<String, dynamic> firestore ) => DatabaseBusModel(
    placa: firestore[ 'placa' ], 
    nombreConductor: firestore[ 'nombreConductor' ], 
    tecnoVencimiento: firestore[ 'vencimientoTecno' ], 
    soatVencimiento: firestore[ 'vencimientoSoat' ], 
    monitora: firestore[ 'nombreMonitora' ], 
    capacidad: firestore[ 'capacidadRuta' ], 
    extintorVencimiento: firestore[ 'vencimientoExtintor' ], 
    kmRecorridos: firestore[ 'kmRecorridos' ]
  );

  Map<String, dynamic> toFirestore() => {
    'placa' : placa,
    'nombreConductor' : nombreConductor,
    'vencimientoTecno' : tecnoVencimiento,
    'vencimientoSoat' : soatVencimiento,
    'nombreMonitora' : monitora,
    'capacidadRuta' : capacidad,
    'vencimientoExtintor' : extintorVencimiento,
    'kmRecorridos' : kmRecorridos,
  };

  Bus toModelEntity() => Bus(
    placa: placa, 
    nombreConductor: nombreConductor, 
    tecnoVencimiento: tecnoVencimiento, 
    soatVencimiento: soatVencimiento, 
    monitora: monitora, 
    capacidad: capacidad, 
    extintorVencimiento: extintorVencimiento, 
    kmRecorridos: kmRecorridos
  );
}

class Estudiante{

  final String nombreEstudiante;
  final int documento;
  bool recogido;
  final int cedulaAcudiente;
  final String placaRutaAsignada;
  final String direccion;

  Estudiante({

    required this.nombreEstudiante,
    required this.documento,
    required this.cedulaAcudiente,
    required this.placaRutaAsignada,
    required this.direccion,

    this.recogido = false

  });
}
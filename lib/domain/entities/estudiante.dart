
class Estudiante{

  final String nombreEstudiante;
  final int documento;
  final int grado;
  bool recogido;
  final double lat;
  final double lng;
  final int cedulaAcudiente;
  final String placaRutaAsignada;
  final String direccion;

  Estudiante({

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
}
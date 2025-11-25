
class Conductor{

  final String nombre;
  final int documento;
  final String correo;
  final String rol;
  final String vencimientoLicencia;
  final String placaRutaAsignada;

  Conductor({ 

    required this.nombre,
    required this.documento,
    required this.correo,
    this.rol = 'Conductor',
    required this.vencimientoLicencia,
    required this.placaRutaAsignada

  });
}
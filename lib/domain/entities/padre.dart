
class Padre{

  final String nombrePadre;
  final int documento;
  final String correo;
  final String rol;
  final String direccion;
  final List<int> documentoHijo;
  final String placaRutaAsignada;
  
  Padre({

    required this.nombrePadre,
    required this.documento,
    required this.correo,
    this.rol = 'acudiente',
    required this.direccion,
    required this.documentoHijo,
    required this.placaRutaAsignada
    
  });
}

class Padre{

  final String nombre;
  final int documento;
  final String correo;
  final String rol;
  final String direccion;
  final List<int> documentoHijo;
  final String placaRutaAsignada;
  
  Padre({

    required this.nombre,
    required this.documento,
    required this.correo,
    this.rol = 'Acudiente',
    required this.direccion,
    required this.documentoHijo,
    required this.placaRutaAsignada
    
  });
}
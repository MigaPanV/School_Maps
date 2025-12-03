
class Padre{

  final String nombre;
  final int documento;
  final String correo;
  final String rol;
  final String direccion;
  List<int> documentoHijo;
  final String placaRutaAsignada;
  final String uId;
  
  Padre({

    required this.nombre,
    required this.documento,
    required this.correo,
    this.rol = 'Acudiente',
    required this.direccion,
    List<int>? documentoHijo,
    this.placaRutaAsignada = '',
    required this.uId
    
  }) : documentoHijo = documentoHijo ?? [];
}
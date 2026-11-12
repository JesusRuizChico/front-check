/// Datos que captura el arrendador para publicar un inmueble.
class NuevaPropiedad {
  final String titulo;
  final String descripcion;
  final double precioMensual;
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String colonia;
  final String municipio;
  final String estadoUbicacion;
  final String codigoPostal;
  final int habitaciones;
  final int banos;
  final int estacionamientos;
  final double? metrosCuadrados;
  final List<int> amenidadesIds;

  const NuevaPropiedad({
    required this.titulo,
    required this.descripcion,
    required this.precioMensual,
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.colonia,
    required this.municipio,
    required this.estadoUbicacion,
    required this.codigoPostal,
    required this.habitaciones,
    required this.banos,
    required this.estacionamientos,
    this.metrosCuadrados,
    required this.amenidadesIds,
  });
}

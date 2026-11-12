/// Inmueble publicado por un arrendador.
class Propiedad {
  static const estadoDisponible = 'disponible';
  static const estadoPausada = 'pausada';
  static const estadoRentada = 'rentada';

  final int id;
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
  final List<String> imagenes;
  final List<String> servicios;
  final String estado;
  final bool verificada;
  final int arrendadorId;
  final String arrendadorNombre;
  final String? arrendadorTelefono;
  final String? arrendadorFoto;
  final int habitaciones;
  final int banos;
  final int estacionamientos;
  final double? metrosCuadrados;
  final bool esFavorito;
  final DateTime fechaPublicacion;

  const Propiedad({
    required this.id,
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
    required this.imagenes,
    required this.servicios,
    required this.estado,
    required this.verificada,
    required this.arrendadorId,
    required this.arrendadorNombre,
    this.arrendadorTelefono,
    this.arrendadorFoto,
    required this.habitaciones,
    required this.banos,
    required this.estacionamientos,
    this.metrosCuadrados,
    required this.esFavorito,
    required this.fechaPublicacion,
  });

  String get direccionCompleta {
    final interior = numeroInterior != null && numeroInterior!.isNotEmpty ? ' Int. $numeroInterior' : '';
    return '$calle $numeroExterior$interior, Col. $colonia, $municipio, $estadoUbicacion (C.P. $codigoPostal)';
  }

  String? get imagenPrincipal => imagenes.isNotEmpty ? imagenes.first : null;

  bool get esActiva => estado == estadoDisponible;

  String get etiquetaEstado => switch (estado) {
        estadoDisponible => 'Disponible',
        estadoPausada => 'Pausada',
        estadoRentada => 'Rentada',
        _ => estado,
      };

  Propiedad copyWith({String? estado, bool? esFavorito}) {
    return Propiedad(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      precioMensual: precioMensual,
      calle: calle,
      numeroExterior: numeroExterior,
      numeroInterior: numeroInterior,
      colonia: colonia,
      municipio: municipio,
      estadoUbicacion: estadoUbicacion,
      codigoPostal: codigoPostal,
      imagenes: imagenes,
      servicios: servicios,
      estado: estado ?? this.estado,
      verificada: verificada,
      arrendadorId: arrendadorId,
      arrendadorNombre: arrendadorNombre,
      arrendadorTelefono: arrendadorTelefono,
      arrendadorFoto: arrendadorFoto,
      habitaciones: habitaciones,
      banos: banos,
      estacionamientos: estacionamientos,
      metrosCuadrados: metrosCuadrados,
      esFavorito: esFavorito ?? this.esFavorito,
      fechaPublicacion: fechaPublicacion,
    );
  }
}

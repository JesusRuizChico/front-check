import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/domain/models/propiedad_model.dart';
import 'package:front_check/features/properties/application/filtro_propiedades.dart';

Propiedad _propiedad(
  int id,
  String colonia,
  List<String> servicios, {
  double precio = 10000,
  int habitaciones = 2,
  int banos = 1,
  int estacionamientos = 1,
  bool verificada = false,
}) =>
    Propiedad(
      id: id,
      titulo: 'Departamento $id',
      descripcion: '',
      precioMensual: precio,
      calle: 'Calle',
      numeroExterior: '1',
      colonia: colonia,
      municipio: 'Querétaro',
      estadoUbicacion: 'Querétaro',
      codigoPostal: '76000',
      imagenes: const [],
      servicios: servicios,
      estado: Propiedad.estadoDisponible,
      verificada: verificada,
      arrendadorId: 1,
      arrendadorNombre: 'Luis',
      habitaciones: habitaciones,
      banos: banos,
      estacionamientos: estacionamientos,
      esFavorito: false,
      fechaPublicacion: DateTime(2026),
    );

void main() {
  final propiedades = [
    _propiedad(1, 'Centro', ['Internet / Wi-Fi', 'Pet Friendly (Mascotas)']),
    _propiedad(2, 'Juriquilla', ['Alberca / Piscina']),
  ];

  test('Sin criterios devuelve todas las propiedades', () {
    expect(const FiltroPropiedades().aplicar(propiedades), hasLength(2));
  });

  test('Busca por colonia sin distinguir acentos ni mayúsculas', () {
    final resultado =
        const FiltroPropiedades(texto: 'JURÍQUILLA').aplicar(propiedades);
    expect(resultado.map((p) => p.id), [2]);
  });

  test('Filtra por amenidad', () {
    expect(
        const FiltroPropiedades(amenidad: 'Wi-Fi')
            .aplicar(propiedades)
            .map((p) => p.id),
        [1]);
    expect(
        const FiltroPropiedades(amenidad: 'Alberca')
            .aplicar(propiedades)
            .map((p) => p.id),
        [2]);
    expect(const FiltroPropiedades(amenidad: 'Gimnasio').aplicar(propiedades),
        isEmpty);
  });

  test('Filtra por rango de precio y mínimos de espacios', () {
    final opciones = [
      _propiedad(3, 'Centro', [], precio: 8500, habitaciones: 1),
      _propiedad(4, 'Centro', [],
          precio: 12000, habitaciones: 3, banos: 2, estacionamientos: 2),
      _propiedad(5, 'Centro', [],
          precio: 18000, habitaciones: 4, banos: 2, estacionamientos: 1),
    ];

    final resultado = const FiltroPropiedades(
      precioMinimo: 10000,
      precioMaximo: 15000,
      habitacionesMinimas: 3,
      banosMinimos: 2,
      estacionamientosMinimos: 2,
    ).aplicar(opciones);

    expect(resultado.map((p) => p.id), [4]);
  });

  test('Puede limitar el catálogo a propiedades verificadas', () {
    final opciones = [
      _propiedad(6, 'Centro', [], verificada: true),
      _propiedad(7, 'Centro', []),
    ];

    expect(
        const FiltroPropiedades(soloVerificadas: true)
            .aplicar(opciones)
            .map((p) => p.id),
        [6]);
  });

  test('Cuenta criterios activos y reconoce el filtro vacío', () {
    expect(const FiltroPropiedades().estaVacio, isTrue);
    expect(
      const FiltroPropiedades(
              texto: 'Centro', precioMaximo: 12000, soloVerificadas: true)
          .cantidadCriteriosActivos,
      3,
    );
    expect(const FiltroPropiedades(precioMinimo: 1).estaVacio, isFalse);
  });
}

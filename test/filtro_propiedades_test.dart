import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/domain/models/propiedad_model.dart';
import 'package:front_check/features/properties/application/filtro_propiedades.dart';

Propiedad _propiedad(int id, String colonia, List<String> servicios) => Propiedad(
      id: id,
      titulo: 'Departamento $id',
      descripcion: '',
      precioMensual: 10000,
      calle: 'Calle',
      numeroExterior: '1',
      colonia: colonia,
      municipio: 'Querétaro',
      estadoUbicacion: 'Querétaro',
      codigoPostal: '76000',
      imagenes: const [],
      servicios: servicios,
      estado: Propiedad.estadoDisponible,
      verificada: false,
      arrendadorId: 1,
      arrendadorNombre: 'Luis',
      habitaciones: 2,
      banos: 1,
      estacionamientos: 1,
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
    final resultado = const FiltroPropiedades(texto: 'JURÍQUILLA').aplicar(propiedades);
    expect(resultado.map((p) => p.id), [2]);
  });

  test('Filtra por amenidad', () {
    expect(const FiltroPropiedades(amenidad: 'Wi-Fi').aplicar(propiedades).map((p) => p.id), [1]);
    expect(const FiltroPropiedades(amenidad: 'Alberca').aplicar(propiedades).map((p) => p.id), [2]);
    expect(const FiltroPropiedades(amenidad: 'Gimnasio').aplicar(propiedades), isEmpty);
  });
}

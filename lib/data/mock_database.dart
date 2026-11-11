import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/models/usuario_model.dart';
import '../domain/models/propiedad_model.dart';
import '../domain/models/chat_model.dart';
import '../domain/models/servicio_model.dart';

class MockDatabase extends ChangeNotifier {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;

  MockDatabase._internal() {
    _initData();
  }

  // Usuarios Demo
  final List<Usuario> _usuarios = [];
  Usuario? _usuarioActual;

  // Propiedades
  final List<Propiedad> _propiedades = [];
  final Set<int> _favoritosIds = {1, 3};

  // Chats
  final List<Conversacion> _conversaciones = [];
  final _conversacionesController = StreamController<List<Conversacion>>.broadcast();

  // Especialistas de Servicio
  final List<ServicioMantenimiento> _serviciosMantenimiento = [];

  // Catálogo de servicios para publicar propiedades
  final List<Map<String, dynamic>> _serviciosDisponibles = [
    {'id': 1, 'nombre': 'Agua potable', 'icono': 'water_drop'},
    {'id': 2, 'nombre': 'Electricidad', 'icono': 'bolt'},
    {'id': 3, 'nombre': 'Internet / Wi-Fi', 'icono': 'wifi'},
    {'id': 4, 'nombre': 'Gas natural', 'icono': 'local_fire_department'},
    {'id': 5, 'nombre': 'Seguridad 24/7', 'icono': 'security'},
    {'id': 6, 'nombre': 'Estacionamiento techado', 'icono': 'garage'},
    {'id': 7, 'nombre': 'Elevador', 'icono': 'elevator'},
    {'id': 8, 'nombre': 'Gimnasio', 'icono': 'fitness_center'},
    {'id': 9, 'nombre': 'Alberca / Piscina', 'icono': 'pool'},
    {'id': 10, 'nombre': 'Pet Friendly (Mascotas)', 'icono': 'pets'},
    {'id': 11, 'nombre': 'Amueblado', 'icono': 'chair'},
    {'id': 12, 'nombre': 'Terraza / Balcón', 'icono': 'balcony'},
  ];

  void _initData() {
    // 1. Usuarios demo
    _usuarios.addAll([
      Usuario(
        id: 1,
        nombre: 'Jesús Ruiz Chico',
        correo: 'arrendador@habitacheck.com',
        telefono: '4421234567',
        roles: ['arrendador'],
        fotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        bio: 'Arrendador verificado con más de 5 años de experiencia ofreciendo espacios seguros y confortables.',
        fechaRegistro: DateTime(2024, 1, 15),
      ),
      Usuario(
        id: 2,
        nombre: 'Ulises Eduardo López',
        correo: 'arrendatario@habitacheck.com',
        telefono: '4429876543',
        roles: ['arrendatario'],
        fotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
        bio: 'Profesionista en tecnología, responsable y buscando departamento céntrico y pet-friendly.',
        fechaRegistro: DateTime(2024, 3, 10),
      ),
      Usuario(
        id: 3,
        nombre: 'Abigail Hernández',
        correo: 'prestador@habitacheck.com',
        telefono: '4425550192',
        roles: ['proveedor', 'servicios'],
        fotoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        bio: 'Ingeniera electricista certificada. Instalaciones residenciales, iluminación LED y domótica.',
        fechaRegistro: DateTime(2024, 2, 20),
      ),
      Usuario(
        id: 4,
        nombre: 'Omar Hernández',
        correo: 'omar.arrendador@habitacheck.com',
        telefono: '4423338899',
        roles: ['arrendador'],
        fotoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
        bio: 'Inversionista inmobiliario en Querétaro y CDMX.',
        fechaRegistro: DateTime(2024, 4, 1),
      ),
    ]);

    // Usuario activo inicial por defecto (Ulises - Arrendatario)
    _usuarioActual = _usuarios[1];

    // 2. Propiedades demo realistas y atractivas
    _propiedades.addAll([
      Propiedad(
        id: 1,
        titulo: 'Loft Minimalista con Terraza Privada',
        descripcion: 'Hermoso loft de doble altura, totalmente iluminado, acabados de lujo en madera y concreto aparente. Cocina integral equipada con barra de cuarzo y vista panorámica a la ciudad. En la mejor zona de Roma Norte.',
        precioMensual: 18500.0,
        calle: 'Álvaro Obregón',
        numeroExterior: '184',
        numeroInterior: '402',
        colonia: 'Roma Norte',
        municipio: 'Cuauhtémoc',
        estadoUbicacion: 'Ciudad de México',
        codigoPostal: '06700',
        imagenes: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1000&q=80',
        ],
        servicios: ['Internet / Wi-Fi', 'Seguridad 24/7', 'Elevador', 'Pet Friendly (Mascotas)', 'Amueblado', 'Terraza / Balcón'],
        estado: 'activa',
        arrendadorId: 1,
        arrendadorNombre: 'Jesús Ruiz Chico',
        arrendadorTelefono: '4421234567',
        habitaciones: 1,
        banos: 1,
        estacionamientos: 1,
        metrosCuadrados: 78.0,
        esFavorito: true,
        fechaPublicacion: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Propiedad(
        id: 2,
        titulo: 'Residencia Familiar con Jardín y Alberca',
        descripcion: 'Espectacular casa de 2 plantas dentro de condominio privado con vigilancia. Amplia sala-comedor, jardín trasero privado de 60m2 con pérgola y asador, recámara principal con vestidor y baño completo.',
        precioMensual: 26000.0,
        calle: 'Paseo del Mesón',
        numeroExterior: '52',
        colonia: 'Juriquilla',
        municipio: 'Querétaro',
        estadoUbicacion: 'Querétaro',
        codigoPostal: '76230',
        imagenes: [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1600565193348-f74bd3c7ccdf?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1600573472591-ee6b68d14c68?auto=format&fit=crop&w=1000&q=80',
        ],
        servicios: ['Agua potable', 'Electricidad', 'Internet / Wi-Fi', 'Gas natural', 'Seguridad 24/7', 'Estacionamiento techado', 'Alberca / Piscina', 'Pet Friendly (Mascotas)'],
        estado: 'activa',
        arrendadorId: 1,
        arrendadorNombre: 'Jesús Ruiz Chico',
        arrendadorTelefono: '4421234567',
        habitaciones: 3,
        banos: 3,
        estacionamientos: 2,
        metrosCuadrados: 210.0,
        esFavorito: false,
        fechaPublicacion: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Propiedad(
        id: 3,
        titulo: 'Departamento Ejecutivo Nuevo cerca de Parque España',
        descripcion: 'Estrena departamento inteligente con cerradura digital, persianas motorizadas y balcón corrido. Torre con amenidades tipo hotel: gimnasio con vista panorámica, coworking space y roof garden con asadores.',
        precioMensual: 21000.0,
        calle: 'Av. Sonora',
        numeroExterior: '88',
        numeroInterior: '601',
        colonia: 'Condesa',
        municipio: 'Cuauhtémoc',
        estadoUbicacion: 'Ciudad de México',
        codigoPostal: '06140',
        imagenes: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1502005229762-ee152da915d6?auto=format&fit=crop&w=1000&q=80',
        ],
        servicios: ['Internet / Wi-Fi', 'Gimnasio', 'Seguridad 24/7', 'Elevador', 'Estacionamiento techado'],
        estado: 'activa',
        arrendadorId: 4,
        arrendadorNombre: 'Omar Hernández',
        arrendadorTelefono: '4423338899',
        habitaciones: 2,
        banos: 2,
        estacionamientos: 1,
        metrosCuadrados: 95.0,
        esFavorito: true,
        fechaPublicacion: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Propiedad(
        id: 4,
        titulo: 'Casa Tradicional estilo Colonial Coyoacán',
        descripcion: 'Preciosa casa estilo colonial contemporáneo con patio central con fuente de cantera, techos con vigas de madera noble y chimenea en sala. A solo 4 cuadras del centro histórico de Coyoacán.',
        precioMensual: 32000.0,
        calle: 'Francisco Sosa',
        numeroExterior: '210',
        colonia: 'Del Carmen',
        municipio: 'Coyoacán',
        estadoUbicacion: 'Ciudad de México',
        codigoPostal: '04100',
        imagenes: [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1000&q=80',
        ],
        servicios: ['Agua potable', 'Electricidad', 'Gas natural', 'Estacionamiento techado', 'Pet Friendly (Mascotas)', 'Terraza / Balcón'],
        estado: 'inactiva',
        arrendadorId: 1,
        arrendadorNombre: 'Jesús Ruiz Chico',
        arrendadorTelefono: '4421234567',
        habitaciones: 4,
        banos: 3,
        estacionamientos: 2,
        metrosCuadrados: 260.0,
        esFavorito: false,
        fechaPublicacion: DateTime.now().subtract(const Duration(days: 14)),
      ),
      Propiedad(
        id: 5,
        titulo: 'Penthouse de Lujo con Jacuzzi Privado en Roof',
        descripcion: 'Penthouse de ensueño con vista de 360 grados, acabados en mármol Carrara, jacuzzi privado en rooftop, sistema de audio integrado y 3 cajones de estacionamiento independientes.',
        precioMensual: 45000.0,
        calle: 'Monte Líbano',
        numeroExterior: '305',
        numeroInterior: 'PH-1',
        colonia: 'Lomas de Chapultepec',
        municipio: 'Miguel Hidalgo',
        estadoUbicacion: 'Ciudad de México',
        codigoPostal: '11000',
        imagenes: [
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1000&q=80',
          'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1000&q=80',
        ],
        servicios: ['Seguridad 24/7', 'Alberca / Piscina', 'Gimnasio', 'Elevador', 'Estacionamiento techado', 'Terraza / Balcón', 'Amueblado'],
        estado: 'activa',
        arrendadorId: 4,
        arrendadorNombre: 'Omar Hernández',
        arrendadorTelefono: '4423338899',
        habitaciones: 3,
        banos: 4,
        estacionamientos: 3,
        metrosCuadrados: 320.0,
        esFavorito: false,
        fechaPublicacion: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ]);

    // 3. Especialistas en Mantenimiento y Servicios
    _serviciosMantenimiento.addAll([
      const ServicioMantenimiento(
        id: 1,
        nombre: 'Abigail Hernández',
        especialidad: 'Electricidad e Iluminación Inteligente',
        descripcion: 'Reparación de cortocircuitos, instalación de tableros, iluminación decorativa LED y automatización con Alexa/Google Home.',
        tarifaBase: 450.0,
        calificacion: 4.9,
        trabajosRealizados: 48,
        telefono: '4425550192',
        fotoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        disponible: true,
        serviciosOfrecidos: ['Revisión eléctrica', 'Instalación de ventiladores', 'Cambiador de tomacorrientes', 'Domótica'],
      ),
      const ServicioMantenimiento(
        id: 2,
        nombre: 'Guillermo Salazar',
        especialidad: 'Plomería y Gas Certificado',
        descripcion: 'Especialista en fugas de agua y gas, instalación de calentadores solares, bombas hidroneumáticas y sanitarios.',
        tarifaBase: 400.0,
        calificacion: 4.8,
        trabajosRealizados: 62,
        telefono: '4428881234',
        fotoUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=400&q=80',
        disponible: true,
        serviciosOfrecidos: ['Reparación de fugas', 'Instalación de boiler', 'Desazolve de drenajes', 'Instalación de grifería'],
      ),
      const ServicioMantenimiento(
        id: 3,
        nombre: 'Carlos Montaño',
        especialidad: 'Cerrajería de Alta Seguridad',
        descripcion: 'Apertura de cerraduras sin daño, duplicados con chip, instalación de chapas inteligentes digitales y biométricas.',
        tarifaBase: 350.0,
        calificacion: 5.0,
        trabajosRealizados: 89,
        telefono: '4424449988',
        fotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        disponible: true,
        serviciosOfrecidos: ['Apertura 24h', 'Cerraduras digitales', 'Chapas de seguridad', 'Duplicados'],
      ),
      const ServicioMantenimiento(
        id: 4,
        nombre: 'Mariana Vega',
        especialidad: 'Pintura y Mantenimiento de Acabados',
        descripcion: 'Pintura interior y exterior, impermeabilización de azoteas con garantía por escrito y resane de grietas.',
        tarifaBase: 500.0,
        calificacion: 4.7,
        trabajosRealizados: 34,
        telefono: '4426667711',
        fotoUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80',
        disponible: false,
        serviciosOfrecidos: ['Pintura vinílica', 'Impermeabilización', 'Resanes finos', 'Barniz en madera'],
      ),
    ]);

    // 4. Conversaciones de Chat iniciales
    _conversaciones.addAll([
      Conversacion(
        id: 'conv_1',
        otroUsuarioId: 1,
        otroUsuarioNombre: 'Jesús Ruiz Chico',
        otroUsuarioFoto: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        otroUsuarioRol: 'Arrendador',
        propiedadId: 1,
        propiedadTitulo: 'Loft Minimalista con Terraza Privada',
        ultimoMensaje: '¡Excelente! Quedamos el sábado a las 11:00 AM para la visita.',
        fechaUltimoMensaje: DateTime.now().subtract(const Duration(minutes: 25)),
        mensajesNoLeidos: 1,
        mensajes: [
          Mensaje(
            id: 'm1',
            emisorId: 2,
            receptorId: 1,
            contenido: 'Hola Jesús, buenas tardes. Vi tu publicación del Loft en Roma Norte y me encantó.',
            fechaHora: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          Mensaje(
            id: 'm2',
            emisorId: 1,
            receptorId: 2,
            contenido: '¡Hola Ulises! Con mucho gusto. Sigue disponible y listo para habitar.',
            fechaHora: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
          ),
          Mensaje(
            id: 'm3',
            emisorId: 2,
            receptorId: 1,
            contenido: '¿Sería posible agendar una visita este sábado por la mañana?',
            fechaHora: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Mensaje(
            id: 'm4',
            emisorId: 1,
            receptorId: 2,
            contenido: '¡Excelente! Quedamos el sábado a las 11:00 AM para la visita.',
            fechaHora: DateTime.now().subtract(const Duration(minutes: 25)),
            leido: false,
          ),
        ],
      ),
      Conversacion(
        id: 'conv_2',
        otroUsuarioId: 3,
        otroUsuarioNombre: 'Abigail Hernández',
        otroUsuarioFoto: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        otroUsuarioRol: 'Especialista Eléctrico',
        propiedadTitulo: 'Servicio de Mantenimiento Eléctrico',
        ultimoMensaje: 'Claro que sí, cuento con equipo para revisión térmica de pastillas.',
        fechaUltimoMensaje: DateTime.now().subtract(const Duration(hours: 6)),
        mensajesNoLeidos: 0,
        mensajes: [
          Mensaje(
            id: 'm20',
            emisorId: 2,
            receptorId: 3,
            contenido: 'Buenas tardes Abigail, ¿realizas diagnósticos en tableros residenciales?',
            fechaHora: DateTime.now().subtract(const Duration(hours: 7)),
          ),
          Mensaje(
            id: 'm21',
            emisorId: 3,
            receptorId: 2,
            contenido: 'Claro que sí, cuento con equipo para revisión térmica de pastillas.',
            fechaHora: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        ],
      ),
    ]);
  }

  // --- GETTERS ---
  List<Usuario> get usuarios => List.unmodifiable(_usuarios);
  Usuario? get usuarioActual => _usuarioActual;
  List<Propiedad> get propiedades => List.unmodifiable(_propiedades);
  Set<int> get favoritosIds => Set.unmodifiable(_favoritosIds);
  List<Conversacion> get conversaciones => List.unmodifiable(_conversaciones);
  Stream<List<Conversacion>> get conversacionesStream => _conversacionesController.stream;
  List<ServicioMantenimiento> get serviciosMantenimiento => List.unmodifiable(_serviciosMantenimiento);
  List<Map<String, dynamic>> get serviciosDisponibles => List.unmodifiable(_serviciosDisponibles);

  // --- USUARIOS & AUTH ---
  void setUsuarioActual(Usuario usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }

  Usuario login(String correo, String contrasena) {
    final usuario = _usuarios.firstWhere(
      (u) => u.correo.toLowerCase() == correo.toLowerCase(),
      orElse: () {
        // Permitir inicio de sesión con cualquier cuenta inventada si no existe en demo
        final nuevo = Usuario(
          id: _usuarios.length + 1,
          nombre: correo.split('@').first,
          correo: correo,
          telefono: '4420000000',
          roles: correo.contains('arrendador') ? ['arrendador'] : ['arrendatario'],
          fechaRegistro: DateTime.now(),
        );
        _usuarios.add(nuevo);
        return nuevo;
      },
    );
    _usuarioActual = usuario;
    notifyListeners();
    return usuario;
  }

  Usuario registrarUsuario({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
    required String rolSolicitado,
  }) {
    final nuevo = Usuario(
      id: _usuarios.length + 1,
      nombre: nombre,
      correo: correo,
      telefono: telefono,
      roles: [rolSolicitado.toLowerCase()],
      fechaRegistro: DateTime.now(),
    );
    _usuarios.add(nuevo);
    _usuarioActual = nuevo;
    notifyListeners();
    return nuevo;
  }

  Usuario actualizarPerfil({
    required String nombre,
    String? telefono,
    String? bio,
    String? fotoUrl,
  }) {
    if (_usuarioActual == null) throw Exception('No hay sesión iniciada');
    final index = _usuarios.indexWhere((u) => u.id == _usuarioActual!.id);
    final actualizado = _usuarioActual!.copyWith(
      nombre: nombre,
      telefono: telefono,
      bio: bio,
      fotoUrl: fotoUrl,
    );
    if (index != -1) {
      _usuarios[index] = actualizado;
    }
    _usuarioActual = actualizado;
    notifyListeners();
    return actualizado;
  }

  // --- PROPIEDADES ---
  List<Propiedad> getCatalogo({String? query, String? categoria, double? maxPrecio}) {
    return _propiedades.where((p) {
      if (!p.esActiva) return false;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchTitulo = p.titulo.toLowerCase().contains(q);
        final matchColonia = p.colonia.toLowerCase().contains(q);
        final matchMunicipio = p.municipio.toLowerCase().contains(q);
        final matchEstado = p.estadoUbicacion.toLowerCase().contains(q);
        if (!matchTitulo && !matchColonia && !matchMunicipio && !matchEstado) return false;
      }
      if (categoria != null && categoria.isNotEmpty && categoria != 'Todos') {
        final matchServicio = p.servicios.any((s) => s.toLowerCase().contains(categoria.toLowerCase()));
        if (!matchServicio) return false;
      }
      if (maxPrecio != null && maxPrecio > 0) {
        if (p.precioMensual > maxPrecio) return false;
      }
      return true;
    }).map((p) => p.copyWith(esFavorito: _favoritosIds.contains(p.id))).toList();
  }

  List<Propiedad> getMisPropiedades(int arrendadorId) {
    return _propiedades
        .where((p) => p.arrendadorId == arrendadorId && p.estado != 'eliminada')
        .toList();
  }

  Propiedad? getPropiedadPorId(int id) {
    try {
      final p = _propiedades.firstWhere((p) => p.id == id);
      return p.copyWith(esFavorito: _favoritosIds.contains(p.id));
    } catch (_) {
      return null;
    }
  }

  Propiedad agregarPropiedad(Propiedad p) {
    final nueva = p.copyWith(
      id: _propiedades.isNotEmpty ? _propiedades.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1 : 1,
      fechaPublicacion: DateTime.now(),
    );
    _propiedades.insert(0, nueva);
    notifyListeners();
    return nueva;
  }

  void cambiarEstadoPropiedad(int id, String nuevoEstado) {
    final index = _propiedades.indexWhere((p) => p.id == id);
    if (index != -1) {
      _propiedades[index] = _propiedades[index].copyWith(estado: nuevoEstado);
      notifyListeners();
    }
  }

  void eliminarPropiedad(int id) {
    _propiedades.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  bool toggleFavorito(int propiedadId) {
    bool agregado = false;
    if (_favoritosIds.contains(propiedadId)) {
      _favoritosIds.remove(propiedadId);
      agregado = false;
    } else {
      _favoritosIds.add(propiedadId);
      agregado = true;
    }
    notifyListeners();
    return agregado;
  }

  List<Propiedad> getFavoritos() {
    return _propiedades
        .where((p) => _favoritosIds.contains(p.id))
        .map((p) => p.copyWith(esFavorito: true))
        .toList();
  }

  // --- CHATS ---
  Conversacion obtenerOIniciarConversacion({
    required int miUsuarioId,
    required int otroUsuarioId,
    required String otroUsuarioNombre,
    String? otroUsuarioFoto,
    String? otroUsuarioRol,
    int? propiedadId,
    String? propiedadTitulo,
  }) {
    final existenteIndex = _conversaciones.indexWhere((c) =>
        c.otroUsuarioId == otroUsuarioId &&
        (propiedadId == null || c.propiedadId == propiedadId));

    if (existenteIndex != -1) {
      return _conversaciones[existenteIndex];
    }

    final nueva = Conversacion(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      otroUsuarioId: otroUsuarioId,
      otroUsuarioNombre: otroUsuarioNombre,
      otroUsuarioFoto: otroUsuarioFoto,
      otroUsuarioRol: otroUsuarioRol ?? 'Usuario',
      propiedadId: propiedadId,
      propiedadTitulo: propiedadTitulo,
      ultimoMensaje: 'Conversación iniciada',
      fechaUltimoMensaje: DateTime.now(),
      mensajesNoLeidos: 0,
      mensajes: [
        Mensaje(
          id: 'init_${DateTime.now().millisecondsSinceEpoch}',
          emisorId: otroUsuarioId,
          receptorId: miUsuarioId,
          contenido: '¡Hola! Vi tu interés en ${propiedadTitulo ?? "nuestros servicios"}. ¿En qué te puedo apoyar?',
          fechaHora: DateTime.now(),
        )
      ],
    );

    _conversaciones.insert(0, nueva);
    _conversacionesController.add(_conversaciones);
    notifyListeners();
    return nueva;
  }

  Mensaje enviarMensaje({
    required String conversacionId,
    required int emisorId,
    required int receptorId,
    required String contenido,
  }) {
    final mensaje = Mensaje(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      emisorId: emisorId,
      receptorId: receptorId,
      contenido: contenido,
      fechaHora: DateTime.now(),
    );

    final index = _conversaciones.indexWhere((c) => c.id == conversacionId);
    if (index != -1) {
      final conv = _conversaciones[index];
      final nuevosMensajes = List<Mensaje>.from(conv.mensajes)..add(mensaje);
      _conversaciones[index] = conv.copyWith(
        ultimoMensaje: contenido,
        fechaUltimoMensaje: DateTime.now(),
        mensajes: nuevosMensajes,
      );
      _conversacionesController.add(_conversaciones);
      notifyListeners();

      // Respuesta simulada inteligente del otro usuario tras 1.5s
      Timer(const Duration(milliseconds: 1500), () {
        _simularRespuestaAutomatica(conversacionId, emisorId, receptorId, conv.otroUsuarioNombre);
      });
    }

    return mensaje;
  }

  void _simularRespuestaAutomatica(String conversacionId, int miId, int otroId, String otroNombre) {
    final respuestas = [
      '¡Enterado! Reviso mi agenda y te confirmo a la brevedad.',
      'Perfecto, muchas gracias por tu mensaje. ¿Te gustaría agendar una llamada o visita?',
      'Claro que sí, con gusto te ayudo con cualquier duda sobre los requisitos del contrato.',
      'Excelente, cuenta con ello. Quedo al pendiente.',
    ];
    final texto = respuestas[DateTime.now().second % respuestas.length];

    final index = _conversaciones.indexWhere((c) => c.id == conversacionId);
    if (index != -1) {
      final conv = _conversaciones[index];
      final respuesta = Mensaje(
        id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
        emisorId: otroId,
        receptorId: miId,
        contenido: texto,
        fechaHora: DateTime.now(),
        leido: false,
      );
      final list = List<Mensaje>.from(conv.mensajes)..add(respuesta);
      _conversaciones[index] = conv.copyWith(
        ultimoMensaje: texto,
        fechaUltimoMensaje: DateTime.now(),
        mensajesNoLeidos: conv.mensajesNoLeidos + 1,
        mensajes: list,
      );
      _conversacionesController.add(_conversaciones);
      notifyListeners();
    }
  }

  void marcarConversacionLeida(String conversacionId) {
    final index = _conversaciones.indexWhere((c) => c.id == conversacionId);
    if (index != -1) {
      final conv = _conversaciones[index];
      _conversaciones[index] = conv.copyWith(mensajesNoLeidos: 0);
      _conversacionesController.add(_conversaciones);
      notifyListeners();
    }
  }
}

final mockDatabase = MockDatabase();


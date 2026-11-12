import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/network/http_api_client.dart';
import '../core/network/media_url_resolver.dart';
import '../data/dispositivo/image_picker_selector.dart';
import '../data/mappers/chat_mapper.dart';
import '../data/mappers/propiedad_mapper.dart';
import '../data/mappers/usuario_mapper.dart';
import '../data/repositories/api_amenidad_repository.dart';
import '../data/repositories/api_auth_repository.dart';
import '../data/repositories/api_chat_repository.dart';
import '../data/repositories/api_favorito_repository.dart';
import '../data/repositories/api_perfil_repository.dart';
import '../data/repositories/api_propiedad_repository.dart';
import '../domain/repositories/amenidad_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/favorito_repository.dart';
import '../domain/repositories/perfil_repository.dart';
import '../domain/repositories/propiedad_repository.dart';
import '../domain/servicios/selector_imagenes.dart';

/// Raíz de composición: el resto de la app solo conoce las abstracciones.

final apiClientProvider = Provider<ApiClient>((ref) => HttpApiClient(baseUrl: ApiConfig.baseUrl));

final _mediaUrlResolverProvider = Provider((ref) => MediaUrlResolver(ApiConfig.baseUrl));

final _usuarioMapperProvider = Provider((ref) => UsuarioMapper(ref.watch(_mediaUrlResolverProvider)));

final _propiedadMapperProvider = Provider((ref) => PropiedadMapper(ref.watch(_mediaUrlResolverProvider)));

final _chatMapperProvider = Provider((ref) => ChatMapper(ref.watch(_mediaUrlResolverProvider)));

final _apiPropiedadRepositoryProvider = Provider(
  (ref) => ApiPropiedadRepository(ref.watch(apiClientProvider), ref.watch(_propiedadMapperProvider)),
);

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(apiClientProvider), ref.watch(_usuarioMapperProvider)),
);

final perfilRepositoryProvider = Provider<IPerfilRepository>(
  (ref) => ApiPerfilRepository(ref.watch(apiClientProvider), ref.watch(_usuarioMapperProvider)),
);

final catalogoRepositoryProvider = Provider<ICatalogoRepository>(
  (ref) => ref.watch(_apiPropiedadRepositoryProvider),
);

final misPropiedadesRepositoryProvider = Provider<IMisPropiedadesRepository>(
  (ref) => ref.watch(_apiPropiedadRepositoryProvider),
);

final favoritoRepositoryProvider = Provider<IFavoritoRepository>(
  (ref) => ApiFavoritoRepository(ref.watch(apiClientProvider), ref.watch(_propiedadMapperProvider)),
);

final amenidadRepositoryProvider = Provider<IAmenidadRepository>(
  (ref) => ApiAmenidadRepository(ref.watch(apiClientProvider), ref.watch(_propiedadMapperProvider)),
);

final chatRepositoryProvider = Provider<IChatRepository>(
  (ref) => ApiChatRepository(ref.watch(apiClientProvider), ref.watch(_chatMapperProvider)),
);

final selectorImagenesProvider = Provider<ISelectorImagenes>((ref) => ImagePickerSelector());

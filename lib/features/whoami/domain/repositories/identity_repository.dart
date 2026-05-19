import 'package:locogames/features/whoami/domain/entities/identity.dart';

abstract class IdentityRepository {
  Identity getRandomIdentity();
  Identity getRandomIdentityExcluding(List<String> excludeNames);
}

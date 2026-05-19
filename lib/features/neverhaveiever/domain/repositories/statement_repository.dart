import 'package:locogames/features/neverhaveiever/domain/entities/statement.dart';

abstract class NHIEStatementRepository {
  List<NHIEStatement> getStatements(NHIECategory category);
}

import 'package:subby/app/app.dart';
import 'package:subby/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}

import 'package:commands_cli/detached_watcher.dart';

Future<void> handleWatchKillAll() async {
  await killAllWatchers();
}

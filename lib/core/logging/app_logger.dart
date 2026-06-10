import 'package:logger/logger.dart';
import 'package:solodesk_mobile/core/config/app_config.dart';

final appLogger = Logger(
  level: AppConfig.isDevelopment ? Level.debug : Level.warning,
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

import 'package:drift/drift.dart';

import 'database_executor_io.dart'
    if (dart.library.html) 'database_executor_web.dart';

QueryExecutor openExecutor() => openExecutorImpl();

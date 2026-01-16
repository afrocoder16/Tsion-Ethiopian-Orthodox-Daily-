import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor openExecutorImpl() => NativeDatabase.memory();

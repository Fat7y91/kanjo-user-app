import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/settings/data/data_source/settings_data_source.dart';
import '../../data/models/settings_model.dart';

abstract class SettingsRepo {
  Future<Either<Failure, SettingsModel>> getSettings();
}

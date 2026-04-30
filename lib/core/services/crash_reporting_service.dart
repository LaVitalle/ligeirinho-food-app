class CrashReportingService {
  Future<void> initialize() async {
    // TODO: integrate Sentry/Crashlytics initialization.
  }

  Future<void> captureException(Object error, StackTrace stackTrace) async {
    // TODO: forward errors to monitoring provider.
  }
}

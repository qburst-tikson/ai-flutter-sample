/// Single source of truth for the demo account accepted by the fake login.
///
/// These are demo credentials shipped with a fake repository, not secrets.
/// A real backend removes this file entirely.
abstract final class DemoCredentials {
  static const email = 'tikson@qburst.com';
  static const password = 'Avenger123';
}

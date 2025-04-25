enum Flavor { free, paid }

class FlavorConfig {
  final Flavor flavor;

  static late FlavorConfig _instance;

  factory FlavorConfig({required Flavor flavor}) {
    _instance = FlavorConfig._internal(flavor);
    return _instance;
  }

  FlavorConfig._internal(this.flavor);

  static FlavorConfig get instance => _instance;

  static bool get isFree => _instance.flavor == Flavor.free;

  static bool get isPaid => _instance.flavor == Flavor.paid;
}

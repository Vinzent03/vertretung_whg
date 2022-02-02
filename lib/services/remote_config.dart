import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:meta/meta.dart';

abstract class RemoteConfigService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;
  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 4),
        minimumFetchInterval: Duration(hours: 12)));
  }

  static Future<void> refresh() {
    return _remoteConfig.fetchAndActivate();
  }

  static LinksData getLinks(String schoolClass) {
    String today;
    String tomorrow;

    schoolClass = schoolClass.toLowerCase();

    if (schoolClass == "q2") {
      today = _remoteConfig.getString("dsb_q2_today");
      tomorrow = _remoteConfig.getString("dsb_q2_tomorrow");
    } else if (schoolClass == "q1") {
      today = _remoteConfig.getString("dsb_q1_today");
      tomorrow = _remoteConfig.getString("dsb_q1_tomorrow");
    } else if (schoolClass == "ef") {
      today = _remoteConfig.getString("dsb_ef_today");
      tomorrow = _remoteConfig.getString("dsb_ef_tomorrow");
    } else if (schoolClass.startsWith("7") ||
        schoolClass.startsWith("8") ||
        schoolClass.startsWith("9")) {
      today = _remoteConfig.getString("dsb_79_today");
      tomorrow = _remoteConfig.getString("dsb_79_tomorrow");
    } else {
      today = _remoteConfig.getString("dsb_56_today");
      tomorrow = _remoteConfig.getString("dsb_56_tomorrow");
    }
    return LinksData(
      tomorrow: tomorrow,
      today: today,
    );
  }

  static bool useWebSubstituteOnMobile() {
    return _remoteConfig.getBool("use_web_substitute_on_mobile");
  }
}

class LinksData {
  final String tomorrow;
  final String today;

  LinksData({@required this.today, @required this.tomorrow});
}

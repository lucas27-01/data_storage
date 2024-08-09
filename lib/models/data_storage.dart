import 'package:data_storage/models/data.dart';
import 'package:flutter/material.dart';

class DataStorage {
  DataStorage.standard() {
    id = (DateTime.now().millisecondsSinceEpoch / 1000)
        .truncate(); // The seconds since the Unix Epoch
    name = "";
    description = null;
    fromTemplate = false;
    data = [];
    iconCodePoint = null;
  }

  DataStorage({
    required this.name,
    required this.data,
    this.description,
    IconData? icon,
    this.fromTemplate = false,
  }) {
    id = (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
    iconCodePoint = icon?.codePoint;
  }

  DataStorage.withId({
    required this.id,
    required this.name,
    required this.data,
    IconData? icon,
    this.description,
    this.fromTemplate = false,
  }) {
    iconCodePoint = icon?.codePoint;
  }

  factory DataStorage.fromJson(Map<String, dynamic> json) {
    List<Data> tmp;
    if (json["data"].map((el) => Data.fromJson(el)).toList().length == 0) {
      tmp = [];
    } else {
      tmp = json["data"].map((el) => Data.fromJson(el)).toList();
    }
    return DataStorage.withId(
      id: json["id"],
      name: json["name"],
      icon: json["icon"] != null ? IconData(json["icon"], fontFamily: 'MaterialIcons') : null,
      description: json["description"],
      fromTemplate: json["fromTemplate"],
      data: tmp,
    );
  }

  late int id;
  late String name;
  late String? description;
  late bool fromTemplate;
  late List<Data> data;
  late int? iconCodePoint;

  IconData? get icon {
    try {
      return IconData(iconCodePoint!, fontFamily: 'MaterialIcons');
    } catch (e) {
      return null;
    }
  }
  
  Icon? get iconWidget {
    try {
      return Icon(IconData(iconCodePoint!, fontFamily: 'MaterialIcons'));
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "icon": iconCodePoint,
      "description": description,
      "fromTemplate": fromTemplate,
      "data": data.map((el) => el.toJson()).toList()
    };
  }

  DateTime creationDate() {
    return DateTime.fromMillisecondsSinceEpoch(id * 1000);
  }

  static final List<int> iconNames = [
    Icons.ac_unit_rounded.codePoint,
    Icons.alarm_rounded.codePoint,
    Icons.access_time_rounded.codePoint,
    Icons.accessibility_new_rounded.codePoint,
    Icons.accessible_rounded.codePoint,
    Icons.account_balance_rounded.codePoint,
    Icons.account_balance_wallet_rounded.codePoint,
    Icons.account_circle_rounded.codePoint,
    Icons.adf_scanner_rounded.codePoint,
    Icons.admin_panel_settings_rounded.codePoint,
    Icons.ads_click_rounded.codePoint,
    Icons.agriculture_rounded.codePoint,
    Icons.air_rounded.codePoint,
    Icons.airline_seat_recline_normal_rounded.codePoint,
    Icons.airplane_ticket_rounded.codePoint,
    Icons.airplanemode_active_rounded.codePoint,
    Icons.album_rounded.codePoint,
    Icons.all_inclusive_rounded.codePoint,
    Icons.alt_route_rounded.codePoint,
    Icons.alternate_email_rounded.codePoint,
    Icons.analytics_rounded.codePoint,
    Icons.anchor_rounded.codePoint,
    Icons.android_rounded.codePoint,
    Icons.announcement_rounded.codePoint,
    Icons.apartment_rounded.codePoint,
    Icons.api_rounded.codePoint,
    Icons.apple.codePoint,
    Icons.apps_rounded.codePoint,
    Icons.architecture_rounded.codePoint,
    Icons.archive_rounded.codePoint,
    Icons.area_chart_rounded.codePoint,
    Icons.article_rounded.codePoint,
    Icons.assessment_rounded.codePoint,
    Icons.assignment_rounded.codePoint,
    Icons.assist_walker_rounded.codePoint,
    Icons.atm_rounded.codePoint,
    Icons.attachment_rounded.codePoint,
    Icons.attractions_rounded.codePoint,
    Icons.audiotrack_rounded.codePoint,
    Icons.auto_awesome_rounded.codePoint,
    Icons.auto_fix_high_rounded.codePoint,
    Icons.auto_graph_rounded.codePoint,
    Icons.autorenew_rounded.codePoint,
    Icons.av_timer_rounded.codePoint,
    Icons.back_hand_rounded.codePoint,
    Icons.backpack_rounded.codePoint,
    Icons.backup_rounded.codePoint,
    Icons.badge_rounded.codePoint,
    Icons.balance_rounded.codePoint,
    Icons.bar_chart_rounded.codePoint,
    Icons.barcode_reader.codePoint,
    Icons.bathroom_rounded.codePoint,
    Icons.battery_std_rounded.codePoint,
    Icons.beach_access_rounded.codePoint,
    Icons.bed_rounded.codePoint,
    Icons.bedtime_rounded.codePoint,
    Icons.bike_scooter_rounded.codePoint,
    Icons.biotech_rounded.codePoint,
    Icons.blender_rounded.codePoint,
    Icons.blind_rounded.codePoint,
    Icons.block_rounded.codePoint,
    Icons.bloodtype_rounded.codePoint,
    Icons.bluetooth_rounded.codePoint,
    Icons.bolt_rounded.codePoint,
    Icons.book_rounded.codePoint,
    Icons.bookmark_rounded.codePoint,
    Icons.boy_rounded.codePoint,
    Icons.brush_rounded.codePoint,
    Icons.bubble_chart_rounded.codePoint,
    Icons.bug_report_rounded.codePoint,
    Icons.build_rounded.codePoint,
    Icons.business_rounded.codePoint,
    Icons.business_center_rounded.codePoint,
    Icons.cable_rounded.codePoint,
    Icons.cake_rounded.codePoint,
    Icons.calculate_rounded.codePoint,
    Icons.calendar_month_rounded.codePoint,
    Icons.call_rounded.codePoint,
    Icons.camera_alt_rounded.codePoint,
    Icons.campaign_rounded.codePoint,
    Icons.cancel_rounded.codePoint,
    Icons.carpenter_rounded.codePoint,
    Icons.casino_rounded.codePoint,
    Icons.cast_rounded.codePoint,
    Icons.castle_rounded.codePoint
  ];
}

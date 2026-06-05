import 'package:flutter/material.dart';

const Map<String, IconData> _icons = {
  'arrow-left': Icons.arrow_back,
  'chevron-right': Icons.chevron_right,
  'chevron-left': Icons.chevron_left,
  'chevron-down': Icons.expand_more,
  'plus': Icons.add,
  'x': Icons.close,
  'check': Icons.check,
  'search': Icons.search,
  'bell': Icons.notifications_outlined,
  'home': Icons.home_outlined,
  'calendar': Icons.calendar_today_outlined,
  'map-pin': Icons.location_on_outlined,
  'clock': Icons.access_time,
  'store': Icons.storefront_outlined,
  'user': Icons.person_outline,
  'users': Icons.people_outline,
  'inbox': Icons.inbox_outlined,
  'settings': Icons.settings_outlined,
  'pencil': Icons.edit_outlined,
  'trash': Icons.delete_outline,
  'more': Icons.more_vert,
  'more-h': Icons.more_horiz,
  'filter': Icons.filter_alt_outlined,
  'sliders': Icons.tune,
  'mail': Icons.mail_outline,
  'lock': Icons.lock_outline,
  'eye': Icons.visibility_outlined,
  'eye-off': Icons.visibility_off_outlined,
  'log-out': Icons.logout,
  'ticket': Icons.confirmation_number_outlined,
  'utensils': Icons.restaurant_outlined,
  'sparkles': Icons.auto_awesome_outlined,
  'image': Icons.image_outlined,
  'camera': Icons.camera_alt_outlined,
  'star': Icons.star_outline,
  'check-circle': Icons.check_circle_outline,
  'x-circle': Icons.cancel_outlined,
  'alert': Icons.warning_amber_outlined,
  'info': Icons.info_outline,
  'phone': Icons.phone_outlined,
  'share': Icons.ios_share,
  'bookmark': Icons.bookmark_outline,
  'compass': Icons.explore_outlined,
  'dollar': Icons.attach_money,
  'tag': Icons.local_offer_outlined,
  'grid': Icons.grid_view,
  'layers': Icons.layers_outlined,
  'trending': Icons.trending_up,
  'send': Icons.send_outlined,
  'moon': Icons.dark_mode_outlined,
  'qr': Icons.qr_code_2,
  'flame': Icons.local_fire_department_outlined,
  'hourglass': Icons.hourglass_empty,
  'edit-3': Icons.edit_outlined,
  'copy': Icons.content_copy_outlined,
  'globe': Icons.public,
};

class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  const AppIcon(this.name, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    final data = _icons[name] ?? Icons.circle_outlined;
    return Icon(data, size: size, color: color);
  }
}

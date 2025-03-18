import 'package:flutter/material.dart';
import '../tabs/static_wallpaper.dart';
import '../tabs/timer_wallpaper.dart';
import '../tabs/dynamic_wallpaper.dart';
import '../tabs/link_parser.dart';
import '../tabs/space_gallery.dart';

class NavItem {
  final String label;
  final Widget content;

  const NavItem({required this.label, required this.content});
}

final List<NavItem> navItems = [
  const NavItem(
    label: "静态壁纸",
    content: StaticWallpaper(),
  ),
  const NavItem(
    label: "定时切换",
    content: TimerWallpaper(),
  ),
  const NavItem(
    label: "动态壁纸",
    content: DynamicWallpaper(),
  ),
  const NavItem(
    label: "空间画廊",
    content: SpaceGallery(),
  ),
  const NavItem(
    label: "链接解析",
    content: LinkParser(),
  ),
];

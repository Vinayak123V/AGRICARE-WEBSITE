// lib/widgets/leaf_icon.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeafIcon extends StatelessWidget {
  const LeafIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the SVG path data for a simple, rounded leaf icon
    const String svgIcon =
        '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.99 2a.99.99 0 011 1v2.83l2.24-1.49a1 1 0 111.05 1.73l-3.3 2.2a.99.99 0 01-1.4-.23L7.7 5.07a1 1 0 111.73-1.05L10 5.83V3a.99.99 0 01-1-1zm6.24 3.32l-2.2 3.3a.99.99 0 01-.23 1.4L11.07 12.3a1 1 0 11-1.05-1.73l1.49-2.24H9a1 1 0 110-2h2.83l1.49-2.24a1 1 0 111.73 1.05zM3.76 11.68l2.2-3.3a.99.99 0 01.23-1.4L8.93 4.7a1 1 0 111.05 1.73L8.5 8.67H11a1 1 0 110 2H8.17l-1.49 2.24a1 1 0 11-1.73-1.05z" clip-rule="evenodd" />
</svg>''';

    // Renders the SVG string using the flutter_svg package
    return SvgPicture.string(
      svgIcon,
      height: 48,
      width: 48,
      colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
    );
  }
}

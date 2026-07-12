import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ServiceTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool highlighted;
  final bool loading;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.highlighted = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = highlighted ? ZienaColors.primary : ZienaColors.white;
    final textColor = highlighted ? ZienaColors.white : ZienaColors.textPrimary;
    final trailingColor = highlighted ? ZienaColors.white : ZienaColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: highlighted
                  ? null
                  : Border.all(color: ZienaColors.greyBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 44,
                      height: 44,
                      color: ZienaColors.bg3,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: ZienaColors.bg3,
                      child: const Icon(Icons.image_outlined,
                          color: ZienaColors.primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: trailingColor,
                    ),
                  )
                else
                  Icon(Icons.chevron_right, color: trailingColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
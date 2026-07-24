import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/screens_provider.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TLUserAvatar extends ConsumerWidget {
  final double radius;

  const TLUserAvatar({super.key, this.radius = 20.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    return CircleAvatar(
      radius: radius,
      backgroundImage: state.avatarUrl.isNotEmpty
          ? NetworkImage('${ApiConstants.baseUrl}${state.avatarUrl}')
          : null,
      child: state.avatarUrl.isEmpty
          ? Icon(Icons.person, size: radius * 1.2, color: AppColors.textSecondary)
          : null,
    );
  }
}

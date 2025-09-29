import 'package:flutter/material.dart';

import 'app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final bool showBack;
  final Future<bool> Function()? onWillPop; // ✅ custom back handling

  const CommonAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor = AppColors.primaryColor,
    this.showBack = true,
    this.onWillPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      title: Text(
        title,

        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color:AppColors.Background
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back,color: AppColors.Background,),
        onPressed: () async {
          if (onWillPop != null) {
            final shouldPop = await onWillPop!();
            if (shouldPop) Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
          }
        },
      )
          : null,
      actions: actions,
    );
    if (onWillPop != null) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: appBar,
      );
    }
    return appBar;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

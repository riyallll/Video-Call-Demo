import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserTile({Key? key, required this.user, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
      title: Text("${user.firstName} ${user.lastName}"),
      subtitle: Text(user.email),
      onTap: onTap,
    );
  }
}

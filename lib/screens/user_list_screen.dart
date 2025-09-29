import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/user_model.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_strings.dart' show AppStrings;
import '../widgets/common_app_bar.dart';

import 'dart:io';

class UserListScreen extends StatefulWidget {
  static const routeName = '/user_list';

  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _api = ApiService();
  final CacheService _cache = CacheService();
  List<UserModel> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({bool forceRemote = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!forceRemote) {
        final cached = await _cache.getCachedUsers();
        if (cached.isNotEmpty) {
          setState(() {
            _users = cached;
            _loading = false;
          });
          _fetchRemoteAndCache(); // background update
          return;
        }
      }
      await _fetchRemoteAndCache();
    } catch (e) {
      setState(() {
        _error = "${AppStrings.failedToLoadUsers} $e";
        _loading = false;
      });
    }
  }

  Future<void> _fetchRemoteAndCache() async {
    try {
      final remote = await _api.fetchUsers();
      await _cache.cacheUsers(remote);
      setState(() {
        _users = remote;
        _loading = false;
      });
    } catch (e) {
      final cached = await _cache.getCachedUsers();
      if (cached.isNotEmpty) {
        setState(() {
          _users = cached;
          _loading = false;
        });
      } else {
        setState(() {
          _error = "${AppStrings.failedToLoadUsers} $e";
          _loading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadUsers(forceRemote: true);
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.logout),
            content: const Text(AppStrings.exitConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(AppStrings.yes),
              ),
            ],
          ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent the default back behavior
      onPopInvoked: (didPop) async {
        if (didPop) return; // If pop was already successful, do nothing.

        final shouldExit = await _onWillPop();

        if (shouldExit) {
          if (Platform.isAndroid || Platform.isIOS) {
            exit(0);
          } else {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CommonAppBar(
          title: AppStrings.usersTitle,
          showBack: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.Background),
              tooltip: AppStrings.refresh,
              onPressed: _refresh,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.Background),
              tooltip: AppStrings.logout,
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text(AppStrings.logout),
                        content: const Text(AppStrings.logoutConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(AppStrings.no),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(AppStrings.yes),
                          ),
                        ],
                      ),
                );

                if (shouldLogout ?? false) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  await CacheService().clearCache();

                  Fluttertoast.showToast(
                    msg: "Logged out successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            radius: 28,
                            child: Text(
                              u.email.isNotEmpty
                                  ? u.firstName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          title: Text(
                            u.firstName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            u.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.video_call,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/video_call',
                              arguments: {'peerId': u.id},
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

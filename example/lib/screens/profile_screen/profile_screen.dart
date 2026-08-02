import 'package:flutter/material.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/profile_screen/profile_viewmodel.dart';
import 'package:duet_example/screens/profile_screen/states/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with DuetStateMixin<ProfileScreen, ProfileViewModel> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  ProfileViewModel bindDuet() => ProfileViewModel();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: duet.data.name);
    _phoneController = TextEditingController(text: duet.data.phone);
    _bioController = TextEditingController(text: duet.data.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _syncControllersWithData() {
    _nameController.text = duet.data.name;
    _phoneController.text = duet.data.phone;
    _bioController.text = duet.data.bio;
  }

  @override
  Widget build(BuildContext context) {
    return buildScope(
      DuetBehaviorListener<ProfileData, ProfileUiBehavior>(
        listener: (context, behavior) {
          switch (behavior) {
            case ProfileUiSuccess(message: final msg):
              _syncControllersWithData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            case ProfileUiError(message: final msg):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            default:
              break;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Trang c   nh  n (Local State)'),
            actions: [
              DuetBuilder<ProfileData, ProfileUiBehavior>.both(
                builder: (context, data, behavior) {
                  final isLoading = behavior is ProfileUiLoading;
                  return IconButton(
                    icon: Icon(data.isEditing ? Icons.close : Icons.edit),
                    tooltip: data.isEditing ? 'H   y' : 'Ch   nh s   a',
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!data.isEditing) {
                              _syncControllersWithData();
                            }
                            duet.toggleEditing();
                          },
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Badge th  ng tin m   t   ?t  nh ch   t Local ViewModel
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade800),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ViewModel n  y l   C   C B   ?(isGlobal = false).\n'
                              'T   ?     ng gi   i ph  ng (autoDispose = true) khi     ng m  n h  nh.',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar & Email Header
                    DuetSelector<ProfileViewModel, ({String name, String email})>(
                      selector: (vm) => (name: vm.data.name, email: vm.data.email),
                      builder: (context, info) {
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                info.name.isNotEmpty ? info.name[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              info.email,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Card Form th  ng tin
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Th  ng tin c   nh  n',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),

                            DuetBuilder<ProfileData, ProfileUiBehavior>.both(
                              builder: (context, data, behavior) {
                                final isLoading = behavior is ProfileUiLoading;
                                final isFieldEnabled = data.isEditing && !isLoading;
                                return Column(
                                  children: [
                                    // H   ?t  n
                                    TextField(
                                      controller: _nameController,
                                      enabled: isFieldEnabled,
                                      decoration: const InputDecoration(
                                        labelText: 'H   ?v   t  n',
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // S   ?  i   n tho   i
                                    TextField(
                                      controller: _phoneController,
                                      enabled: isFieldEnabled,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'S   ?  i   n tho   i',
                                        prefixIcon: Icon(Icons.phone),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Ti   u s   ?/ Bio
                                    TextField(
                                      controller: _bioController,
                                      enabled: isFieldEnabled,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        labelText: 'Ti   u s   ?(Bio)',
                                        prefixIcon: Icon(Icons.badge),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // N  t l  u th  ng tin khi editing
                                    if (data.isEditing)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : () => duet.saveProfile(
                                                    name: _nameController.text,
                                                    phone: _phoneController.text,
                                                    bio: _bioController.text,
                                                  ),
                                          icon: const Icon(Icons.save),
                                          label: const Text('L  u thay      i'),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // C   u h  nh    ng d   ng
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DuetSelector<ProfileViewModel, bool>(
                        selector: (vm) => vm.data.notificationsEnabled,
                        builder: (context, enabled) {
                          return SwitchListTile(
                            value: enabled,
                            title: const Text('Nh   n th  ng b  o    ng d   ng'),
                            subtitle: const Text('B   t/t   t th  ng b  o      y      n thi   t b   '),
                            secondary: const Icon(Icons.notifications_active),
                            onChanged: duet.toggleNotifications,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Loading overlay khi saving
              DuetSelector<ProfileViewModel, bool>.ui(
                selector: (vm) => vm.ui is ProfileUiLoading,
                builder: (context, isLoading) {
                  if (!isLoading) return const SizedBox.shrink();
                  return Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

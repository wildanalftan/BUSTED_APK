import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/users_provider.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentUser = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('MANAGE USERS', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isMe = currentUser?.email.toLowerCase() == user.email.toLowerCase();
                
                final cardShape = const BeveledRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: cardShape.copyWith(
                    side: BorderSide(
                      color: user.isBlocked ? cs.error : cs.outline.withOpacity(0.2),
                      width: user.isBlocked ? 2.0 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: ShapeDecoration(
                        color: user.isAdmin ? cs.secondary : cs.primary,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: user.isAdmin ? cs.onSecondary : cs.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(user.name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        if (user.isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.secondary.withOpacity(0.15),
                              border: Border.all(color: cs.secondary, width: 1.5),
                            ),
                            child: Text('ADMIN', style: TextStyle(color: cs.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(user.email, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        if (user.isBlocked) ...[
                          const SizedBox(height: 4),
                          Text(
                            'STATUS: BLOCKED', 
                            style: TextStyle(color: cs.error, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ],
                    ),
                    trailing: isMe
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('YOU', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          )
                        : IconButton(
                            icon: Icon(
                              user.isBlocked ? Icons.lock_open : Icons.block, 
                              color: user.isBlocked ? Colors.green : cs.error,
                            ),
                            tooltip: user.isBlocked ? 'Unblock user' : 'Block user',
                            onPressed: () {
                              _confirmToggleBlock(context, ref, user.name, user.email, user.isBlocked);
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmToggleBlock(BuildContext context, WidgetRef ref, String name, String email, bool isBlocked) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isBlocked ? 'Unblock User?' : 'Block User?'),
          content: Text('Are you sure you want to ${isBlocked ? 'unblock' : 'block'} $name ($email)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.green : cs.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref.read(usersProvider.notifier).toggleBlockUser(email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User $name has been ${isBlocked ? 'unblocked' : 'blocked'}.'),
                    backgroundColor: isBlocked ? Colors.green : cs.error,
                  ),
                );
              },
              child: Text(isBlocked ? 'Unblock' : 'Block'),
            ),
          ],
        );
      },
    );
  }
}

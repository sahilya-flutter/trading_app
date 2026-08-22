import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../persistence/local_storage_service.dart';
import '../../market/presentation/market_providers.dart';
import '../domain/notification_item.dart';

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  final LocalStorageService _storage;
  final Uuid _uuid = const Uuid();
  static const int _maxNotifications = 50;

  NotificationsNotifier(this._storage) : super(_storage.loadNotifications());

  void _persist() {
    _storage.saveNotifications(state);
  }

  NotificationItem addNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    final item = NotificationItem(
      id: _uuid.v4(),
      title: title,
      message: message,
      type: type,
      timestamp: timestamp ?? DateTime.now(),
      isRead: false,
      metadata: metadata,
    );

    final updated = [item, ...state];
    if (updated.length > _maxNotifications) {
      state = updated.sublist(0, _maxNotifications);
    } else {
      state = updated;
    }
    _persist();
    return item;
  }

  void markAsRead(String id) {
    if (!state.any((n) => n.id == id && !n.isRead)) return;

    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _persist();
  }

  void markAllAsRead() {
    if (state.every((n) => n.isRead)) return;

    state = state.map((n) => n.copyWith(isRead: true)).toList();
    _persist();
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
    _persist();
  }

  void clearAll() {
    state = [];
    _persist();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return NotificationsNotifier(storage);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider);
  return list.where((n) => !n.isRead).length;
});

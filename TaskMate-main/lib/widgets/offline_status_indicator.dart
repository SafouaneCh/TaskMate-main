import 'package:flutter/material.dart';
import 'package:taskmate/services/network_service.dart';
import 'package:taskmate/services/sync_service.dart';

class OfflineStatusIndicator extends StatefulWidget {
  const OfflineStatusIndicator({super.key});

  @override
  State<OfflineStatusIndicator> createState() => _OfflineStatusIndicatorState();
}

class _OfflineStatusIndicatorState extends State<OfflineStatusIndicator> {
  final NetworkService _networkService = NetworkService();
  final SyncService _syncService = SyncService();
  bool _isOnline = true;
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _networkService.addListener(_onConnectivityChanged);
    _updateStatus();
  }

  void _onConnectivityChanged(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });
  }

  void _updateStatus() {
    setState(() {
      _isOnline = _networkService.isConnected;
      _pendingSyncCount = _syncService.pendingSyncCount;
    });
  }

  @override
  void dispose() {
    _networkService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isOnline ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: _isOnline ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: _isOnline ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_pendingSyncCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_pendingSyncCount pending',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

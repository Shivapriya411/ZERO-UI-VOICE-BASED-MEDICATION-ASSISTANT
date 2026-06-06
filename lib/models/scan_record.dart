import 'medicine.dart';

class ScanRecord {
  final Medicine medicine;
  final DateTime scannedAt;

  ScanRecord({
    required this.medicine,
    required this.scannedAt,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(scannedAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${scannedAt.day}/${scannedAt.month}/${scannedAt.year}';
  }
}
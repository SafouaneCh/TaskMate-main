import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactService {
  /// Requests contact permissions and returns the status
  /// [readonly]: Whether to request read-only permission (true) or write permission (false)
  Future<PermissionStatus> requestPermission({bool readonly = true}) async {
    try {
      final status = await Permission.contacts.status;
      if (!status.isGranted) {
        return await Permission.contacts.request();
      }
      return status;
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  /// Fetches contacts from the device with optional parameters
  /// [withThumbnail]: Whether to load contact thumbnails (default: false)
  /// [sorted]: Whether to sort contacts by display name (default: true)
  /// [withProperties]: Whether to include contact properties (default: true)
  Future<List<Contact>> fetchContacts({
    bool withThumbnail = false,
    bool sorted = true,
    bool withProperties = true,
  }) async {
    try {
      // First check if we have permission
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        throw Exception('Contact permissions not granted');
      }

      // Get all contacts
      final contacts = await FlutterContacts.getContacts(
        withThumbnail: withThumbnail,
        withProperties: withProperties,
      );

      // Sort if requested
      if (sorted) {
        contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
      }

      return contacts;
    } catch (e) {
      // Handle any errors and return empty list
      return [];
    }
  }

  /// Fetches a single contact by ID
  /// [id]: The contact ID to fetch
  /// [withThumbnail]: Whether to load contact thumbnail (default: false)
  Future<Contact?> getContactById(String id, {bool withThumbnail = false}) async {
    try {
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        return null;
      }
      return await FlutterContacts.getContact(id, withThumbnail: withThumbnail);
    } catch (e) {
      return null;
    }
  }

  /// Refreshes the contact list with latest changes
  Future<List<Contact>> refreshContacts() async {
    return fetchContacts();
  }
}
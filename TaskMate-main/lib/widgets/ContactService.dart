import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactService {
  // Method to request and check contact permissions
  Future<PermissionStatus> getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.contacts.request();
    }
    return permission;
  }

  // Method to fetch contacts from the device
  Future<List<Contact>> fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }
}

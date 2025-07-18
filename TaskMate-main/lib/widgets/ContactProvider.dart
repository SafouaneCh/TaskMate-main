import 'package:contacts_service/contacts_service.dart';

class ContactProvider {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];

  List<Contact> get contacts => _contacts;
  List<Contact> get filteredContacts => _filteredContacts;

  void setContacts(List<Contact> contacts) {
    _contacts = contacts;
    _filteredContacts = contacts;
  }
  List<Contact> getContacts() {
    return _contacts;
  }

  void filterContacts(String query) {
    _filteredContacts = _contacts
        .where((contact) =>
    contact.displayName != null &&
        contact.displayName!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

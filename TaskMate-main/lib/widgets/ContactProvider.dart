import 'package:flutter_contacts/flutter_contacts.dart';

class ContactProvider {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  bool _permissionDenied = false;

  List<Contact> get contacts => _contacts;
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  bool get permissionDenied => _permissionDenied;

  Future<void> loadContacts() async {
    try {
      _isLoading = true;
      _permissionDenied = false;

      if (!await FlutterContacts.requestPermission(readonly: true)) {
        _permissionDenied = true;
        return;
      }

      final contacts = await FlutterContacts.getContacts();
      setContacts(contacts);
    } finally {
      _isLoading = false;
    }
  }

  void setContacts(List<Contact> contacts) {
    _contacts = contacts
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    _filteredContacts = List.from(_contacts);
  }

  void filterContacts(String query) {
    if (query.isEmpty) {
      _filteredContacts = List.from(_contacts);
      return;
    }

    _filteredContacts = _contacts
        .where((contact) =>
    contact.displayName.toLowerCase().contains(query.toLowerCase()) ||
        (contact.name.first.toLowerCase().contains(query.toLowerCase())) ||
        (contact.name.last.toLowerCase().contains(query.toLowerCase())) ||
        contact.phones.any((phone) =>
            phone.number.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  void clearContacts() {
    _contacts.clear();
    _filteredContacts.clear();
  }
}
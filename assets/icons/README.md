# Icons

## Required Icons

### WhatsApp Icon
For optimal WhatsApp sharing experience, you should add a WhatsApp icon to this directory:

1. Download the official WhatsApp logo (preferably in PNG format)
2. Rename it to `whatsapp_icon.png`
3. Place it in this directory (`assets/icons/`)
4. Update the code in `lib/presentation/pages/note/note_edit_page.dart` to use the image asset:

```dart
ListTile(
  leading: Image.asset(
    'assets/icons/whatsapp_icon.png',
    width: 24,
    height: 24,
    errorBuilder: (context, error, stackTrace) => const Icon(Icons.message, color: Color(0xFF25D366)),
  ),
  title: const Text('Share via WhatsApp'),
  onTap: () {
    Navigator.pop(context);
    shareService.shareNoteViaWhatsApp(context, note, _checklistItems);
  },
),
```

Note: Always ensure you're using assets that comply with WhatsApp's brand guidelines when using their logo. 
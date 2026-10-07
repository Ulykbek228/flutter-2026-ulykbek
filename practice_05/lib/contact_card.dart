import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        // Without Expanded around the Column (Pixel 7, 412 dp wide):
        // "A RenderFlex overflowed by 584 pixels on the right."
        child: Row(
          children: [
            Stack(
              // The badge may hang over the avatar's edge.
              clipBehavior: Clip.none,
              children: [
                // List order decides depth: avatar first = badge on top.
                CircleAvatar(child: Text(contact.initial)),
                if (contact.unread > 0)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.error,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Text(
                        '${contact.unread}',
                        style: text.labelSmall?.copyWith(color: colors.onError),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Expanded gets the leftover width, tight — so the long name
            // wraps instead of overflowing.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: text.titleMedium),
                  Text(contact.email, style: text.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

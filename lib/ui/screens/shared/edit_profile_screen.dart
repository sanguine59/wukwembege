import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/profile.dart';
import '../../../theme.dart';
import '../../../viewmodels/app_viewmodel.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/inputs.dart';
import '../../widgets/thumb.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final AppViewModel _vm = context.read<AppViewModel>();
  late final Profile _profile = _vm.profile!;
  late final _name = TextEditingController(text: _profile.name);
  late final _owner = TextEditingController(text: _profile.owner);
  late final _detail = TextEditingController(text: _profile.role == Role.organizer ? _profile.roleLabel ?? '' : _profile.cuisine ?? '');
  late final _bio = TextEditingController(text: _profile.bio);
  late final _email = TextEditingController(text: _profile.email);
  late final _phone = TextEditingController(text: _profile.phone);

  Future<void> _save() async {
    final isOrg = _profile.role == Role.organizer;
    final updated = _profile.copyWith(
      name: _name.text, owner: _owner.text,
      roleLabel: isOrg ? _detail.text : null,
      cuisine: !isOrg ? _detail.text : null,
      bio: _bio.text, email: _email.text, phone: _phone.text,
    );
    await _vm.saveProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = _profile.role == Role.organizer;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(
              title: 'Edit profile',
              onBack: () => Navigator.of(context).pop(),
              trailing: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Btn(label: 'Save', size: BtnSize.sm, onPressed: _save),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                children: [
                  Center(
                    child: Column(children: [
                      isOrg
                          ? AvatarInitials(name: _owner.text.isEmpty ? _profile.owner : _owner.text, color: _profile.color, size: 76)
                          : AppThumb(color: _profile.color, glyph: _profile.glyph, size: 76, radius: 22, glyphSize: 36),
                      const SizedBox(height: 10),
                      Btn(
                        label: 'Change photo', size: BtnSize.sm, icon: 'camera', variant: BtnVariant.secondary,
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo picker'))),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Field(label: isOrg ? 'Organization name' : 'Stall / business name', child: AppTextInput(controller: _name)),
                  const SizedBox(height: 12),
                  Field(label: 'Owner / contact name', child: AppTextInput(controller: _owner)),
                  const SizedBox(height: 12),
                  Field(label: isOrg ? 'Role' : 'Cuisine', child: AppTextInput(controller: _detail)),
                  const SizedBox(height: 12),
                  Field(label: 'Bio', child: AppTextInput(controller: _bio, minLines: 3, maxLines: 5)),
                  const SizedBox(height: 12),
                  Field(label: 'Email', child: AppTextInput(controller: _email, leadIcon: 'mail')),
                  const SizedBox(height: 12),
                  Field(label: 'Phone', child: AppTextInput(controller: _phone, leadIcon: 'phone')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

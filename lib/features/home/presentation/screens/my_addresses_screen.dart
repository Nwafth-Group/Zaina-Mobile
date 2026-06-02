import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/address_model.dart';
import '../cubit/address_cubit.dart';
import 'add_edit_address_screen.dart';

class MyAddressesScreen extends StatelessWidget {
  const MyAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('my_addresses'.tr(),
            style: const TextStyle(
              
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
        centerTitle: false,
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: ZienaColors.error,
            ));
          }
        },
        builder: (context, state) {
          final isActionLoading = state is AddressActionLoading;
          final addresses = state is AddressLoaded
              ? state.addresses
              : state is AddressActionLoading
              ? state.current
              : context.read<AddressCubit>().list;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: addresses.isEmpty && state is! AddressLoading
                        ? _buildEmpty(context)
                        : state is AddressLoading
                        ? const Center(
                        child: CircularProgressIndicator(
                            color: ZienaColors.primary,
                            strokeWidth: 2))
                        : RefreshIndicator(
                      onRefresh: () => context
                          .read<AddressCubit>()
                          .fetchAddresses(),
                      color: ZienaColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 16, 16, 16),
                        itemCount: addresses.length,
                        itemBuilder: (_, i) => _AddressCard(
                          address: addresses[i],
                          onSetDefault: () => context
                              .read<AddressCubit>()
                              .setDefault(addresses[i].id),
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value:
                                context.read<AddressCubit>(),
                                child: AddEditAddressScreen(
                                    editAddress: addresses[i]),
                              ),
                            ),
                          ),
                          onDelete: () =>
                              _confirmDelete(context, addresses[i]),
                        ),
                      ),
                    ),
                  ),

                  // ── Add Address ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                    decoration: const BoxDecoration(color: ZienaColors.white),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AddressCubit>(),
                              child: const AddEditAddressScreen(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded,
                            color: ZienaColors.primary, size: 20),
                        label: Text('add_address'.tr(),
                            style: const TextStyle(
                              
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ZienaColors.primary,
                            )),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(
                              color: ZienaColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // action loading overlay
              if (isActionLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: ZienaColors.primary, strokeWidth: 2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: const BoxDecoration(
                  color: ZienaColors.bg2, shape: BoxShape.circle),
              child: const Icon(Icons.location_off_outlined,
                  color: ZienaColors.primary, size: 46),
            ),
            const SizedBox(height: 20),
            Text('no_addresses_yet'.tr(),
                style: const TextStyle(
                   fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('no_addresses_desc'.tr(),
                style: const TextStyle(
                   fontSize: 13,
                  color: ZienaColors.textSecondary, height: 1.5,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('delete_address'.tr(),
            style: const TextStyle(
                 fontWeight: FontWeight.w700)),
        content: Text('delete_address_confirm'.tr(),
            style: const TextStyle(
                
                color: ZienaColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(),
                style: const TextStyle(
                    
                    color: ZienaColors.textSecondary)),
          ),
          ZienaButton(
            text: 'delete'.tr(),
            onTap: () {
              Navigator.pop(context);
              context.read<AddressCubit>().deleteAddress(address.id);
            },
            backgroundColor: ZienaColors.error,
          ),
        ],
      ),
    );
  }
}

// ── Address Card ──────────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault
              ? ZienaColors.primary
              : ZienaColors.greyBorder,
          width: address.isDefault ? 1.5 : 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ────────────────────────────────────────────────────────
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: address.isDefault
                    ? ZienaColors.bg2
                    : ZienaColors.bg1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(address.icon,
                  color: ZienaColors.primary, size: 20),
            ),
            const SizedBox(width: 12),

            // ── Text ─────────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label + default badge
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: address.isDefault
                            ? ZienaColors.primary
                            : ZienaColors.bg1,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(address.label,
                          style: TextStyle(
                             fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: address.isDefault
                                ? Colors.white
                                : ZienaColors.textSecondary,
                          )),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      Text('default'.tr(),
                          style: const TextStyle(
                             fontSize: 10,
                            color: ZienaColors.primary,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Text(address.shortAddress(lang),
                      style: const TextStyle(
                         fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ZienaColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(address.oneLiner,
                      style: const TextStyle(
                         fontSize: 12,
                        color: ZienaColors.textSecondary, height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

            // ── Menu ─────────────────────────────────────────────────────────
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz,
                  color: ZienaColors.textSecondary, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'default') onSetDefault();
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                if (!address.isDefault)
                  PopupMenuItem(
                    value: 'default',
                    child: _menuItem(Icons.check_circle_outline,
                        'set_as_default'.tr(), ZienaColors.primary),
                  ),
                PopupMenuItem(
                  value: 'edit',
                  child: _menuItem(Icons.edit_outlined,
                      'edit'.tr(), ZienaColors.textSecondary),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: _menuItem(Icons.delete_outline,
                      'delete'.tr(), ZienaColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
               fontSize: 13, color: color)),
    ]);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fmt.dart';
import '../../../core/widgets/page_states.dart';
import '../../../core/widgets/sign_in_prompt.dart';
import '../../../data/models/order_model.dart';
import '../../auth/viewmodel/auth_cubit.dart';
import '../../cart/viewmodel/cart_cubit.dart';
import '../../cart/viewmodel/cart_state.dart';
import '../viewmodel/checkout_cubit.dart';
import '../viewmodel/checkout_state.dart';

const _countries = ['Egypt', 'Saudi Arabia', 'United Arab Emirates', 'Kuwait', 'United States', 'United Kingdom', 'Germany'];

/// Checkout: delivery address form + order placement (writes `orders/{id}`,
/// clears the cart, redirects to My Orders).
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckoutCubit>(
      create: (context) => CheckoutCubit(context.read()),
      child: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutStatus.placed) {
            context.go('/orders?placed=1');
          }
        },
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            return switch (cart.status) {
              CartStatus.guest => const SignInPrompt(
                  title: 'Sign in to checkout',
                  subtitle: 'You need an account to place an order.',
                  redirect: '/checkout',
                ),
              CartStatus.loading => const LoadingView(label: 'Loading your bag…'),
              CartStatus.ready when cart.isEmpty => EmptyView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your bag is empty',
                  subtitle: 'Add a product before checking out.',
                  actionLabel: 'SHOP NOW',
                  onAction: () => context.go('/'),
                ),
              CartStatus.ready => _CheckoutForm(cart: cart),
            };
          },
        ),
      ),
    );
  }
}

class _CheckoutForm extends StatefulWidget {
  const _CheckoutForm({required this.cart});

  final CartState cart;

  @override
  State<_CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<_CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  String _country = _countries.first;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthCubit>();
    final user = auth.state.user;
    if (user == null) return;
    context.read<CheckoutCubit>().placeOrder(
          uid: user.uid,
          items: widget.cart.items,
          address: AddressModel(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            line1: _line1Controller.text.trim(),
            city: _cityController.text.trim(),
            zip: _zipController.text.trim(),
            country: _country,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final form = _addressForm();
              final summary = _summary();
              return constraints.maxWidth > 860
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: form),
                        const SizedBox(width: 28),
                        SizedBox(width: 320, child: summary),
                      ],
                    )
                  : Column(children: [form, const SizedBox(height: 24), summary]);
            },
          ),
        ),
      ),
    );
  }

  Widget _addressForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          TextFormField(
            key: const Key('address-name'),
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Full name is required.' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('address-phone'),
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Phone number is required.';
              if (value.length < 6) return 'Enter a valid phone number.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const Key('address-line'),
            controller: _line1Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line',
              hintText: 'Street, building, apartment',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Address is required.' : null,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('address-city'),
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'City is required.' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  key: const Key('address-zip'),
                  controller: _zipController,
                  decoration: const InputDecoration(labelText: 'ZIP Code'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'ZIP code is required.' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: const Key('address-country'),
            initialValue: _country,
            decoration: const InputDecoration(labelText: 'Country'),
            items: [
              for (final country in _countries)
                DropdownMenuItem(value: country, child: Text(country)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _country = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, checkout) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lineGrey),
            color: AppColors.softGrey,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Order Summary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _row('Items (${widget.cart.itemCount})', Fmt.price(widget.cart.subtotal)),
              const SizedBox(height: 6),
              _row(
                'Shipping',
                widget.cart.shipping == 0 ? 'FREE' : Fmt.price(widget.cart.shipping),
                valueColor: widget.cart.shipping == 0 ? Colors.green : null,
              ),
              const SizedBox(height: 10),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(
                    Fmt.price(widget.cart.total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (checkout.error != null) ...[
                Text(
                  checkout.error!,
                  style: const TextStyle(color: AppColors.saleRed, fontSize: 13.5),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                key: const Key('place-order'),
                onPressed: checkout.isSubmitting ? null : _submit,
                child: checkout.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('PLACE ORDER'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}

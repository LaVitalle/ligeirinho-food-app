import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/catalog_providers.dart';

class CreateAdditionalScreen extends ConsumerStatefulWidget {
  const CreateAdditionalScreen({super.key});

  @override
  ConsumerState<CreateAdditionalScreen> createState() =>
      _CreateAdditionalScreenState();
}

class _CreateAdditionalScreenState extends ConsumerState<CreateAdditionalScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0,00');
  final _maxCtrl = TextEditingController(text: '5');
  String _unit = 'Unitário';
  int _qty = 1;
  bool _isLoading = false;

  void _saveAdditional() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final priceStr = _priceCtrl.text.replaceAll('.', '').replaceAll(',', '.');
      final price = double.tryParse(priceStr) ?? 0.0;
      final maxVal = int.tryParse(_maxCtrl.text) ?? 5;

      final myCanteen = await ref.read(myCanteenProvider.future);
      final api = ref.read(catalogApiServiceProvider);

      await api.createAdditional({
        'canteenId': myCanteen.id,
        'name': _nameCtrl.text.trim(),
        'price': price,
        // Since extra DTO might not accept maxQuantity right away depending on backend,
        // we can pass it if supported, or just the required fields.
        // Based on our previous check:
        // class CreateExtraDto: name, price, canteenId. 
      });

      ref.invalidate(vendorAdditionalsProvider(myCanteen.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicional criado com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.primary),
          label: const Text('Voltar para lista',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        leadingWidth: 160,
        title: const Text('Novo Adicional'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Nome do Adicional'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'Ex. Bacon Extra'),
            ),
            const SizedBox(height: 16),

            _label('Valor (R\$)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: 'R\$  '),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Unidade'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _unit,
                        items: ['Unitário', 'Gramas', 'ml']
                            .map((u) => DropdownMenuItem(
                                value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => _unit = v!),
                        decoration: InputDecoration(
                          fillColor: AppColors.surface,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.inputBorder)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.inputBorder)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Quantidade'),
                      const SizedBox(height: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (_qty > 1) setState(() => _qty--);
                              },
                            ),
                            Expanded(
                              child: Text('$_qty',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16,
                                  color: AppColors.primary),
                              onPressed: () => setState(() => _qty++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Qtd. Máxima por Pedido'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _maxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ex. 5'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Limite que o cliente pode adicionar de uma vez.',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAdditional,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar Adicional',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }
}

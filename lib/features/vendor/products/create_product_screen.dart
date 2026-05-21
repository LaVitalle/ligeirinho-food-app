import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/providers/catalog_providers.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key});

  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0,00');
  final Set<String> _selectedAdditionals = {};
  bool _isLoading = false;

  void _saveProduct() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final priceStr = _priceCtrl.text.replaceAll('.', '').replaceAll(',', '.');
      // The backend expects price to be a number string like "15.90" not a double
      
      // Need canteenId
      final myCanteen = await ref.read(myCanteenProvider.future);

      final api = ref.read(catalogApiServiceProvider);
      
      // Let's get the first category ID available or create a mock one for now
      // since the backend requires categoryId as a UUID
      final categories = await ref.read(categoriesProvider.future);
      // Forçar o UUID da categoria 'Salgados' que acabamos de criar se a lista estiver vazia
      final categoryId = categories.isNotEmpty ? categories.first.id : 'a21dd1b4-cef9-41b2-876f-4947ef0f177d';

      await api.createProduct({
        'canteenId': myCanteen.id,
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': priceStr, // Preço como string, como o backend exige
        'categoryId': categoryId,
      });

      // Refresh products list
      ref.invalidate(vendorProductsProvider(myCanteen.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto criado com sucesso!')),
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
    final myCanteenAsync = ref.watch(myCanteenProvider);
    final canteenId = myCanteenAsync.valueOrNull?.id;
    final additionalsAsync = canteenId != null ? ref.watch(vendorAdditionalsProvider(canteenId)) : null;
    final availableAdditionals = additionalsAsync?.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios,
              size: 16, color: AppColors.primary),
          label: const Text('Voltar',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        leadingWidth: 100,
        title: const Text('Novo Produto'),
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
            // Foto
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.inputBorder, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.image, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text('Toque para enviar foto do produto',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textMedium)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _label('Nome do Produto'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'Ex. Hambúrguer Artesanal'),
            ),
            const SizedBox(height: 16),

            _label('Descrição'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Descreva os ingredientes e detalhes...'),
            ),
            const SizedBox(height: 16),

            _label('Valor do Produto'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: 'R\$  '),
            ),
            const SizedBox(height: 20),

            // Adicionais
            const Text('Adicionais',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),

            if (_selectedAdditionals.isNotEmpty) ...[
              const Text('Adicionais Selecionados',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _selectedAdditionals.map((id) {
                  final add =
                      availableAdditionals.firstWhere((a) => a.id == id);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(add.name,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(
                              () => _selectedAdditionals.remove(id)),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            const Text('Adicionar Adicionais',
                style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 8),

            // Search adicionais
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar adicionais...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                fillColor: AppColors.surface,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),

            ...availableAdditionals.take(3).map((add) {
              final selected = _selectedAdditionals.contains(add.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(add.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark)),
                          Text('+ R\$ ${add.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedAdditionals.remove(add.id);
                          } else {
                            _selectedAdditionals.add(add.id);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(selected ? 'Rem.' : 'Add',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppColors.primary)),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar Produto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }
}

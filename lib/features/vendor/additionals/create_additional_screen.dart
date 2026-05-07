import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CreateAdditionalScreen extends StatefulWidget {
  const CreateAdditionalScreen({super.key});

  @override
  State<CreateAdditionalScreen> createState() =>
      _CreateAdditionalScreenState();
}

class _CreateAdditionalScreenState extends State<CreateAdditionalScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0,00');
  final _maxCtrl = TextEditingController(text: '5');
  String _unit = 'Unitário';
  int _qty = 1;

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
                        value: _unit,
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
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.save, color: Colors.white, size: 18),
                label: const Text('SALVAR ADICIONAL',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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

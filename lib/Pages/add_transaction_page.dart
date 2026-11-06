import 'package:flutter/material.dart';

import '../Models/transaction_model.dart';
import '../Services/firestore_service.dart';
import '../utils/app_colors.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState
    extends State<AddTransactionPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String type = 'expense';
  bool loading = false;

  Future<void> saveTransaction() async {
    final title = titleController.text.trim();
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama dan nominal dengan benar'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final transaction = TransactionModel(
        id: '',
        title: title,
        amount: amount,
        type: type,
        note: noteController.text.trim(),
        date: DateTime.now(),
      );

      await FirestoreService().addTransaction(transaction);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catat keuanganmu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jangan lupa mencatat setiap pemasukan dan pengeluaran.',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 25),

            const Text(
              'Jenis Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _typeButton(
                    'Pemasukan',
                    'income',
                    AppColors.income,
                    Icons.south_west,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeButton(
                    'Pengeluaran',
                    'expense',
                    AppColors.expense,
                    Icons.north_east,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Transaksi',
                hintText: 'Contoh: Uang saku',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Nominal',
                hintText: 'Contoh: 50000',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Tambahkan keterangan transaksi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                onPressed: loading ? null : saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Simpan Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final selected = type == value;

    return GestureDetector(
      onTap: () {
        setState(() => type = value);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
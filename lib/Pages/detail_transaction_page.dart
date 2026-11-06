import 'package:flutter/material.dart';

import '../Models/transaction_model.dart';
import '../Services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/format_helper.dart';

class DetailTransactionPage extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransactionPage({
    super.key,
    required this.transaction,
  });

  @override
  State<DetailTransactionPage> createState() =>
      _DetailTransactionPageState();
}

class _DetailTransactionPageState
    extends State<DetailTransactionPage> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController noteController;

  late String type;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.transaction.title,
    );

    amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );

    noteController = TextEditingController(
      text: widget.transaction.note,
    );

    type = widget.transaction.type;
  }

  Future<void> updateTransaction() async {
    final title = titleController.text.trim();
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan nominal harus diisi dengan benar'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final updated = TransactionModel(
        id: widget.transaction.id,
        title: title,
        amount: amount,
        type: type,
        note: noteController.text.trim(),
        date: widget.transaction.date,
      );

      await FirestoreService().updateTransaction(updated);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
          'Transaksi ini akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => loading = true);

    try {
      await FirestoreService().deleteTransaction(
        widget.transaction.id,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
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
    final isIncome = type == 'income';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            onPressed: loading ? null : deleteTransaction,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: isIncome
                        ? AppColors.income.withValues(alpha: 0.12)
                        : AppColors.expense.withValues(alpha: 0.12),
                    child: Icon(
                      isIncome
                          ? Icons.south_west
                          : Icons.north_east,
                      size: 35,
                      color: isIncome
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    FormatHelper.rupiah(
                      widget.transaction.amount,
                    ),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    FormatHelper.tanggal(
                      widget.transaction.date,
                    ),
                    style: const TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Transaksi',
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
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(
                labelText: 'Jenis Transaksi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'income',
                  child: Text('Pemasukan'),
                ),
                DropdownMenuItem(
                  value: 'expense',
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => type = value);
                }
              },
            ),

            const SizedBox(height: 18),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : updateTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: loading ? null : deleteTransaction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.expense,
                ),
                child: const Text('Hapus Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
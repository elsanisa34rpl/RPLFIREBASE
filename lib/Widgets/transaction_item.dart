import 'package:flutter/material.dart';

import '../Models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/format_helper.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'income';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isIncome
              ? AppColors.income.withValues(alpha: 0.12)
              : AppColors.expense.withValues(alpha: 0.12),
          child: Icon(
            isIncome
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            color: isIncome
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        subtitle: Text(
          FormatHelper.tanggal(transaction.date),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${FormatHelper.rupiah(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome
                ? AppColors.income
                : AppColors.expense,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
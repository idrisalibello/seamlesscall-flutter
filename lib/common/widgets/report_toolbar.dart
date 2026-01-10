import 'package:flutter/material.dart';

class ReportToolbar extends StatelessWidget {
  final VoidCallback onExportCsv;
  final VoidCallback onExportPdf;
  final Widget? filters;

  const ReportToolbar({
    super.key,
    required this.onExportCsv,
    required this.onExportPdf,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (filters != null) Expanded(child: filters!),

          const SizedBox(width: 12),

          OutlinedButton.icon(
            icon: const Icon(Icons.table_chart),
            label: const Text('CSV'),
            onPressed: onExportCsv,
          ),

          const SizedBox(width: 8),

          OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
            onPressed: onExportPdf,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BusinessFormatters {
  BusinessFormatters._();

  static String warehouseName(String id) {
    switch (id) {
      case 'warehouse_1':
        return 'Asosiy ombor';
      case 'warehouse_2':
        return 'Toshkent ombor';
      case 'warehouse_3':
        return 'Samarqand ombor';
      default:
        return id;
    }
  }

  static String portfolioShortName(String id) {
    switch (id) {
      case 'pf_beverages':
        return 'BEV';
      case 'pf_snacks':
        return 'SNK';
      case 'pf_energy_premium':
        return 'PRM';
      default:
        return id;
    }
  }

  static String portfolioDisplayName(String id) {
    switch (id) {
      case 'pf_beverages':
        return 'Ichimliklar';
      case 'pf_snacks':
        return 'Snack/Qandolat';
      case 'pf_energy_premium':
        return 'Premium';
      default:
        return id;
    }
  }

  static Color portfolioColor(String id) {
    switch (id) {
      case 'pf_beverages':
        return const Color(0xFF1565C0);
      case 'pf_snacks':
        return const Color(0xFF00897B);
      case 'pf_energy_premium':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }
}

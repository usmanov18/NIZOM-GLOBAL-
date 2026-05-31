import '../../domain/entities/order_flow_entities.dart';
import '../../domain/entities/order_catalog_product.dart';

/// Fallback katalog datasource.
/// Keyinchalik Product/Customer remote/local repository bilan almashtiriladi.
class OrderSeedCatalogDataSource {
  const OrderSeedCatalogDataSource._();

  static List<OrderCustomer> seedCustomers() {
    return List.generate(20, (index) {
      final hasDebt = index % 3 == 0;
      return OrderCustomer(
        id: 'cust_$index',
        code: 'C${(index + 1).toString().padLeft(5, '0')}',
        name: 'Super Market ${index + 1}',
        legalName: 'Super Market ${index + 1} LLC',
        inn: '12345678$index',
        address: index % 3 == 0
            ? 'Toshkent, Chilonzor ${index + 1}'
            : index % 3 == 1
                ? 'Samarqand, Registon ${index + 1}'
                : 'Buxoro, Markaz ${index + 1}',
        phone: '+998 90 123 45 ${index.toString().padLeft(2, '0')}',
        agentId: 'agent_1',
        priceGroupId: 'pg_1',
        paymentTerms: 'NET30',
        creditLimit: 50000000,
        currentDebt: hasDebt ? 5000000 : 0,
        availableCredit: hasDebt ? 45000000 : 50000000,
        paymentDelayDays: 30,
        isActive: true,
        isBlocked: false,
        lastOrderAmount: 0,
      );
    });
  }

  static List<OrderCatalogProduct> seedProducts() => const [
        OrderCatalogProduct(
          id: 'prod_1',
          name: 'Coca-Cola 1.5L',
          category: 'Ichimliklar',
          price: 8500,
          stock: 120,
          stockByWarehouse: {
            'warehouse_1': 120,
            'warehouse_2': 45,
            'warehouse_3': 0
          },
          portfolioId: 'pf_beverages',
          assortment: 'mandatory',
          source: '1C',
          brand: 'Coca-Cola',
        ),
        OrderCatalogProduct(
          id: 'prod_2',
          name: 'Fanta 1.5L',
          category: 'Ichimliklar',
          price: 8300,
          stock: 95,
          stockByWarehouse: {
            'warehouse_1': 95,
            'warehouse_2': 25,
            'warehouse_3': 12
          },
          portfolioId: 'pf_beverages',
          assortment: 'mandatory',
          source: '1C',
          brand: 'Fanta',
        ),
        OrderCatalogProduct(
          id: 'prod_3',
          name: 'Sprite 1.5L',
          category: 'Ichimliklar',
          price: 8300,
          stock: 88,
          stockByWarehouse: {
            'warehouse_1': 88,
            'warehouse_2': 50,
            'warehouse_3': 8
          },
          portfolioId: 'pf_beverages',
          assortment: 'mandatory',
          source: '1C',
          brand: 'Sprite',
        ),
        OrderCatalogProduct(
          id: 'prod_4',
          name: 'Nestle suv 1L',
          category: 'Suv',
          price: 3500,
          stock: 240,
          stockByWarehouse: {
            'warehouse_1': 240,
            'warehouse_2': 160,
            'warehouse_3': 75
          },
          portfolioId: 'pf_beverages',
          assortment: 'mandatory',
          source: '1C',
          brand: 'Nestle',
        ),
        OrderCatalogProduct(
          id: 'prod_5',
          name: 'Pepsi 1.5L',
          category: 'Ichimliklar',
          price: 8200,
          stock: 140,
          stockByWarehouse: {
            'warehouse_1': 140,
            'warehouse_2': 40,
            'warehouse_3': 15
          },
          portfolioId: 'pf_beverages',
          assortment: 'recommended',
          source: '1C',
          brand: 'Pepsi',
        ),
        OrderCatalogProduct(
          id: 'prod_6',
          name: 'Lay\'s chips 90g',
          category: 'Snack',
          price: 12000,
          stock: 70,
          stockByWarehouse: {
            'warehouse_1': 70,
            'warehouse_2': 22,
            'warehouse_3': 5
          },
          portfolioId: 'pf_snacks',
          assortment: 'recommended',
          source: 'SAP',
          brand: 'Lays',
        ),
        OrderCatalogProduct(
          id: 'prod_7',
          name: 'Orbit saqich',
          category: 'Qandolat',
          price: 4500,
          stock: 300,
          stockByWarehouse: {
            'warehouse_1': 300,
            'warehouse_2': 90,
            'warehouse_3': 45
          },
          portfolioId: 'pf_snacks',
          assortment: 'recommended',
          source: 'SAP',
          brand: 'Orbit',
        ),
        OrderCatalogProduct(
          id: 'prod_8',
          name: 'Milka shokolad',
          category: 'Qandolat',
          price: 16500,
          stock: 55,
          stockByWarehouse: {
            'warehouse_1': 55,
            'warehouse_2': 10,
            'warehouse_3': 0
          },
          portfolioId: 'pf_snacks',
          assortment: 'optional',
          source: 'SAP',
          brand: 'Milka',
        ),
        OrderCatalogProduct(
          id: 'prod_9',
          name: 'Lipton Ice Tea',
          category: 'Ichimliklar',
          price: 9000,
          stock: 65,
          stockByWarehouse: {
            'warehouse_1': 65,
            'warehouse_2': 20,
            'warehouse_3': 0
          },
          portfolioId: 'pf_beverages',
          assortment: 'seasonal',
          source: '1C',
          brand: 'Lipton',
        ),
        OrderCatalogProduct(
          id: 'prod_10',
          name: 'Red Bull 250ml',
          category: 'Energetik',
          price: 18000,
          stock: 40,
          stockByWarehouse: {
            'warehouse_1': 40,
            'warehouse_2': 6,
            'warehouse_3': 0
          },
          portfolioId: 'pf_energy_premium',
          assortment: 'optional',
          source: 'MIXED',
          brand: 'Red Bull',
        ),
      ];
}

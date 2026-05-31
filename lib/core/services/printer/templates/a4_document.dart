import '../models/receipt_models.dart';

// ============================================================
// A4 DOCUMENT - A4 qog'oz formatida hujjatlar
// PDF generation uchun
// ============================================================

class A4Document {
  /// A4 formatida sotuv hujjati
  static String generateSaleDocument(ReceiptData receipt) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      font-family: 'Segoe UI', Arial, sans-serif; 
      padding: 20mm;
      font-size: 11pt;
      color: #333;
    }
    .header { 
      display: flex; 
      justify-content: space-between; 
      align-items: flex-start;
      margin-bottom: 20px;
      padding-bottom: 15px;
      border-bottom: 3px solid #1565C0;
    }
    .company-info { flex: 1; }
    .company-name { 
      font-size: 24pt; 
      font-weight: bold; 
      color: #1565C0;
      margin-bottom: 5px;
    }
    .company-details { font-size: 9pt; color: #666; }
    .document-info { text-align: right; }
    .document-title { 
      font-size: 18pt; 
      font-weight: bold; 
      color: #1565C0;
      margin-bottom: 10px;
    }
    .document-number { 
      font-size: 14pt; 
      color: #333;
    }
    .document-date { 
      font-size: 10pt; 
      color: #666;
    }
    
    .parties { 
      display: flex; 
      justify-content: space-between; 
      margin: 20px 0;
    }
    .party { 
      flex: 1; 
      padding: 15px;
      background: #f8f9fa;
      border-radius: 8px;
      margin: 0 5px;
    }
    .party-title { 
      font-weight: bold; 
      color: #1565C0;
      margin-bottom: 8px;
      font-size: 10pt;
    }
    .party-name { 
      font-weight: bold; 
      font-size: 12pt;
      margin-bottom: 4px;
    }
    .party-detail { 
      font-size: 9pt; 
      color: #666;
      margin-bottom: 2px;
    }
    
    .items-table { 
      width: 100%; 
      border-collapse: collapse; 
      margin: 20px 0;
    }
    .items-table th { 
      background: #1565C0; 
      color: white;
      padding: 10px 8px;
      text-align: left;
      font-size: 9pt;
      font-weight: 600;
    }
    .items-table th:last-child,
    .items-table td:last-child { text-align: right; }
    .items-table td { 
      padding: 8px;
      border-bottom: 1px solid #eee;
      font-size: 10pt;
    }
    .items-table tr:nth-child(even) { background: #f8f9fa; }
    .items-table .discount { color: #2E7D32; font-size: 9pt; }
    
    .totals { 
      display: flex; 
      justify-content: flex-end;
      margin: 20px 0;
    }
    .totals-box { 
      width: 300px;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 8px;
    }
    .total-row { 
      display: flex; 
      justify-content: space-between;
      padding: 5px 0;
      font-size: 11pt;
    }
    .total-row.grand-total { 
      font-size: 16pt;
      font-weight: bold;
      color: #1565C0;
      border-top: 2px solid #1565C0;
      padding-top: 10px;
      margin-top: 10px;
    }
    
    .payment-info { 
      margin: 20px 0;
      padding: 15px;
      background: #e8f5e9;
      border-radius: 8px;
      border-left: 4px solid #2E7D32;
    }
    .payment-title { 
      font-weight: bold; 
      color: #2E7D32;
      margin-bottom: 8px;
    }
    .payment-detail { 
      font-size: 10pt; 
      color: #333;
      margin-bottom: 4px;
    }
    
    .footer { 
      margin-top: 30px;
      padding-top: 15px;
      border-top: 1px solid #ddd;
      display: flex;
      justify-content: space-between;
    }
    .footer-left { font-size: 9pt; color: #666; }
    .footer-right { text-align: right; }
    .qr-code { 
      width: 80px; 
      height: 80px; 
      border: 1px solid #ddd;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 8pt;
      color: #999;
    }
    
    .notes { 
      margin: 15px 0;
      padding: 10px;
      background: #fff3e0;
      border-radius: 8px;
      font-size: 10pt;
      color: #e65100;
    }
    
    @media print {
      body { padding: 0; }
      .no-print { display: none; }
    }
  </style>
</head>
<body>
  <!-- Header -->
  <div class="header">
    <div class="company-info">
      <div class="company-name">${receipt.companyName}</div>
      <div class="company-details">
        ${receipt.companyAddress}<br>
        Tel: ${receipt.companyPhone}<br>
        ${receipt.inn != null ? 'STIR: ${receipt.inn}' : ''}
      </div>
    </div>
    <div class="document-info">
      <div class="document-title">SAVOD HUJJATI</div>
      <div class="document-number">№ ${receipt.documentNumber}</div>
      <div class="document-date">${_formatDate(receipt.documentDate)}</div>
    </div>
  </div>
  
  <!-- Parties -->
  <div class="parties">
    <div class="party">
      <div class="party-title">SOTUVCHI</div>
      <div class="party-name">${receipt.companyName}</div>
      <div class="party-detail">${receipt.companyAddress}</div>
      <div class="party-detail">Tel: ${receipt.companyPhone}</div>
    </div>
    <div class="party">
      <div class="party-title">XARIDOR</div>
      <div class="party-name">${receipt.customerName}</div>
      ${receipt.customerCode != null ? '<div class="party-detail">Kod: ${receipt.customerCode}</div>' : ''}
      ${receipt.customerAddress != null ? '<div class="party-detail">${receipt.customerAddress}</div>' : ''}
      ${receipt.customerPhone != null ? '<div class="party-detail">Tel: ${receipt.customerPhone}</div>' : ''}
    </div>
  </div>
  
  <!-- Items Table -->
  <table class="items-table">
    <thead>
      <tr>
        <th>№</th>
        <th>Mahsulot</th>
        <th>Kod</th>
        <th>Miqdor</th>
        <th>Narx</th>
        <th>Chegirma</th>
        <th>Jami</th>
      </tr>
    </thead>
    <tbody>
      ${receipt.items.map((item) => '''
      <tr>
        <td>${item.lineNumber}</td>
        <td>${item.productName}</td>
        <td>${item.productCode}</td>
        <td>${item.quantity} ${item.unit}</td>
        <td>${_fmt(item.unitPrice)}</td>
        <td>${item.discountPercent > 0 ? '${item.discountPercent}%' : '-'}</td>
        <td>${_fmt(item.totalAmount)}</td>
      </tr>
      ${item.discountAmount > 0 ? '<tr><td colspan="6" class="discount">Chegirma: -${_fmt(item.discountAmount)} ${receipt.currency}</td></tr>' : ''}
      ''').join('')}
    </tbody>
  </table>
  
  <!-- Totals -->
  <div class="totals">
    <div class="totals-box">
      <div class="total-row">
        <span>Ortiqcha summa:</span>
        <span>${_fmt(receipt.subtotal)} ${receipt.currency}</span>
      </div>
      ${receipt.hasDiscount ? '''
      <div class="total-row">
        <span>Chegirma:</span>
        <span style="color: #2E7D32">-${_fmt(receipt.discountAmount)} ${receipt.currency}</span>
      </div>
      ''' : ''}
      ${receipt.taxAmount > 0 ? '''
      <div class="total-row">
        <span>Soliq:</span>
        <span>${_fmt(receipt.taxAmount)} ${receipt.currency}</span>
      </div>
      ''' : ''}
      <div class="total-row grand-total">
        <span>JAMI:</span>
        <span>${_fmt(receipt.totalAmount)} ${receipt.currency}</span>
      </div>
    </div>
  </div>
  
  <!-- Payment Info -->
  <div class="payment-info">
    <div class="payment-title">TO'LOV MA'LUMOTLARI</div>
    <div class="payment-detail">To'lov usuli: ${receipt.paymentMethod}</div>
    <div class="payment-detail">To'langan summa: ${_fmt(receipt.paidAmount)} ${receipt.currency}</div>
    ${receipt.changeAmount > 0 ? '<div class="payment-detail">Qaytim: ${_fmt(receipt.changeAmount)} ${receipt.currency}</div>' : ''}
  </div>
  
  ${receipt.notes != null ? '''
  <div class="notes">
    <strong>Izoh:</strong> ${receipt.notes}
  </div>
  ''' : ''}
  
  <!-- Footer -->
  <div class="footer">
    <div class="footer-left">
      <strong>Agent:</strong> ${receipt.agentName} (${receipt.agentCode})<br>
      ${receipt.footerText ?? 'Rahmat! Yana tashrif buyur!'}
    </div>
    <div class="footer-right">
      <div class="qr-code">[QR KOD]</div>
    </div>
  </div>
</body>
</html>
''';
  }

  /// A4 formatida kunlik hisobot
  static String generateDailyReport({
    required DateTime date,
    required String agentName,
    required String agentCode,
    required int totalOrders,
    required double totalSales,
    required double totalCollections,
    required int totalVisits,
    required int completedVisits,
    required double totalDistance,
    required List<Map<String, dynamic>> topProducts,
    required List<Map<String, dynamic>> topCustomers,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; padding: 20mm; font-size: 11pt; }
    .header { text-align: center; margin-bottom: 30px; }
    .title { font-size: 24pt; font-weight: bold; color: #1565C0; }
    .subtitle { font-size: 14pt; color: #666; margin-top: 5px; }
    .date { font-size: 12pt; color: #333; margin-top: 10px; }
    
    .stats-grid { 
      display: grid; 
      grid-template-columns: repeat(4, 1fr); 
      gap: 15px;
      margin: 20px 0;
    }
    .stat-card { 
      padding: 15px; 
      background: #f8f9fa; 
      border-radius: 10px;
      text-align: center;
    }
    .stat-value { font-size: 20pt; font-weight: bold; color: #1565C0; }
    .stat-label { font-size: 9pt; color: #666; margin-top: 5px; }
    
    .section { margin: 25px 0; }
    .section-title { 
      font-size: 14pt; 
      font-weight: bold; 
      color: #1565C0;
      margin-bottom: 10px;
      padding-bottom: 5px;
      border-bottom: 2px solid #1565C0;
    }
    
    .list-item { 
      display: flex; 
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #eee;
    }
    .list-item:last-child { border-bottom: none; }
  </style>
</head>
<body>
  <div class="header">
    <div class="title">KUNLIK HISOBOT</div>
    <div class="subtitle">NIZOM GLOBAL</div>
    <div class="date">${date.day}.${date.month}.${date.year}</div>
  </div>
  
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-value">$totalOrders</div>
      <div class="stat-label">Buyurtmalar</div>
    </div>
    <div class="stat-card">
      <div class="stat-value">${_fmt(totalSales)}</div>
      <div class="stat-label">Sotuv (so'm)</div>
    </div>
    <div class="stat-card">
      <div class="stat-value">$totalVisits</div>
      <div class="stat-label">Tashriflar</div>
    </div>
    <div class="stat-card">
      <div class="stat-value">${totalDistance.toStringAsFixed(1)}</div>
      <div class="stat-label">Masofa (km)</div>
    </div>
  </div>
  
  <div class="section">
    <div class="section-title">Top mahsulotlar</div>
    ${topProducts.map((p) => '''
    <div class="list-item">
      <span>${p['name']}</span>
      <span>${p['quantity']} dona • ${_fmt(p['amount'])} so'm</span>
    </div>
    ''').join('')}
  </div>
  
  <div class="section">
    <div class="section-title">Top mijozlar</div>
    ${topCustomers.map((c) => '''
    <div class="list-item">
      <span>${c['name']}</span>
      <span>${c['orders']} buyurtma • ${_fmt(c['amount'])} so'm</span>
    </div>
    ''').join('')}
  </div>
  
  <div style="margin-top: 40px; text-align: center; color: #666; font-size: 10pt;">
    Agent: $agentName ($agentCode)<br>
    Hisobot vaqti: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}
  </div>
</body>
</html>
''';
  }

  static String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  static String _fmt(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

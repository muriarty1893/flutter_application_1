import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart'; // CSV paketini ekledik

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ürün Fiyat Hesaplayıcı',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  ProductListPageState createState() => ProductListPageState();
}

class ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = [];
  TextEditingController groupController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController percentageController = TextEditingController();

  String? oldPrice; // Eski fiyatı göstermek için
  String? newPrice; // Yeni fiyatı göstermek için

  @override
  void initState() {
    super.initState();
    loadCSVData();
  }

  Future<void> loadCSVData() async {
    // CSV dosyasını assets klasöründen yükle
    final csvData = await rootBundle.loadString('assets/urunler.csv');

    // CSV verisini bir tabloya dönüştür
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

    // CSV tablosundaki verileri işleme
    for (var row in csvTable) {
      setState(() {
        products.add({
          'group': row[0].toString().toLowerCase().trim(), // Ürün grubu
          'name': row[1].toString().toLowerCase().trim(),  // Ürün adı
          'price': double.tryParse(row[2].toString().replaceAll(',', '.')), // Fiyat (double)
        });
      });
    }
  }

  void calculateNewPrice() {
    String enteredGroup = groupController.text.toLowerCase().trim(); // Girilen grup adı
    String enteredName = nameController.text.toLowerCase().trim();   // Girilen ürün adı
    String enteredPercentage = percentageController.text.trim();     // Girilen yüzde

    // Girilen ürün grubu ve adı CSV dosyasındaki ürünle eşleşiyor mu kontrol et
    var product = products.firstWhere(
      (prod) =>
          prod['group'] == enteredGroup &&
          prod['name'] == enteredName,
      orElse: () => {},
    );

    if (product.isNotEmpty) {
      double price = product['price'] ?? 0.0;
      double percentage = double.tryParse(enteredPercentage) ?? 0.0;

      // Yeni fiyatı hesapla (Eski fiyat + yüzde artış)
      double newPriceValue = price + (price * percentage / 100);

      setState(() {
        oldPrice = price.toStringAsFixed(2);
        newPrice = newPriceValue.toStringAsFixed(2);
      });
    } else {
      setState(() {
        oldPrice = 'Ürün bulunamadı';
        newPrice = 'Ürün bulunamadı';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Fiyat Hesaplayıcı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ürün Grubu için input
            TextField(
              controller: groupController,
              decoration: const InputDecoration(
                labelText: 'Ürün Grubu',
              ),
            ),
            const SizedBox(height: 16),
            // Ürün Adı için input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
              ),
            ),
            const SizedBox(height: 16),
            // Yüzdelik değer için input
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(
                labelText: 'Yüzdelik Değer (%)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Hesapla butonu
            ElevatedButton(
              onPressed: calculateNewPrice,
              child: const Text('Hesapla'),
            ),
            const SizedBox(height: 16),
            // Eski ve yeni fiyatları göster
            if (oldPrice != null) Text('Eski Fiyat: $oldPrice'),
            if (newPrice != null) Text('Yeni Fiyat: $newPrice'),
          ],
        ),
      ),
    );
  }
}

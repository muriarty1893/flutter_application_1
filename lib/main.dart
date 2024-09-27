import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';  // CSV paketini ekledik

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
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = [];

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
          'name': row[0],  // Ürün adı
          'price': row[1], // Ürün fiyatı
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(products[index]['name']),
                  subtitle: Text('Alış Fiyatı: ${products[index]['price']} TL'),
                );
              },
            ),
    );
  }
}

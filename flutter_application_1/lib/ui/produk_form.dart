import 'package:flutter/material.dart';

class ProdukForm extends StatefulWidget {
  final Map<String, dynamic>? produk;

  const ProdukForm({super.key, this.produk});

  @override
  ProdukFormState createState() => ProdukFormState();
}

class ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kodeProdukTextboxController;
  late final TextEditingController _namaProdukTextboxController;
  late final TextEditingController _hargaProdukTextboxController;

  @override
  void initState() {
    super.initState();
    _kodeProdukTextboxController = TextEditingController(
      text: widget.produk?['kode'],
    );
    _namaProdukTextboxController = TextEditingController(
      text: widget.produk?['nama'],
    );
    _hargaProdukTextboxController = TextEditingController(
      text: widget.produk?['harga']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produk == null ? 'Form Tambah Produk' : 'Form Ubah Produk',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _kodeProdukTextboxController,
                decoration: const InputDecoration(labelText: 'Kode Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _namaProdukTextboxController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hargaProdukTextboxController,
                decoration: const InputDecoration(labelText: 'Harga Produk'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newProduk = {
                      'kode': _kodeProdukTextboxController.text,
                      'nama': _namaProdukTextboxController.text,
                      'harga': int.parse(_hargaProdukTextboxController.text),
                    };
                    Navigator.of(context).pop(newProduk);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

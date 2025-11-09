import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/produk_detail.dart';
import 'package:flutter_application_1/ui/produk_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  late Future<void> _loadDataFuture;
  final List<Map<String, dynamic>> _produkData = [];
  List<Map<String, dynamic>> _filteredProduk = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  SortOption _sortOption = SortOption.none;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadProduk();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredProduk = List<Map<String, dynamic>>.from(_produkData);
      } else {
        _filteredProduk = _produkData
            .where(
              (p) =>
                  p['nama']!.toString().toLowerCase().contains(q) ||
                  p['kode']!.toString().toLowerCase().contains(q),
            )
            .toList();
      }
    });
  }

  Future<void> _loadProduk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('produk_data');
    if (mounted) {
      setState(() {
        _produkData.clear();
        if (raw != null) {
          final List decoded = jsonDecode(raw);
          _produkData.addAll(
            decoded.map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e),
            ),
          );
        } else {
          // default data
          _produkData.addAll([
            {'kode': 'A001', 'nama': 'Jauzia', 'harga': 10000},
            {'kode': 'A002', 'nama': 'Gama', 'harga': 20000},
            {'kode': 'A003', 'nama': 'Callula', 'harga': 30000},
          ]);
        }
        _applySort();
        _filteredProduk = List<Map<String, dynamic>>.from(_produkData);
      });
    }
  }

  Future<void> _saveProduk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('produk_data', jsonEncode(_produkData));
  }

  void _applySort() {
    switch (_sortOption) {
      case SortOption.namaAsc:
        _produkData.sort(
          (a, b) => a['nama']!.toString().compareTo(b['nama']!.toString()),
        );
        break;
      case SortOption.hargaAsc:
        _produkData.sort(
          (a, b) => (a['harga'] as int).compareTo(b['harga'] as int),
        );
        break;
      case SortOption.hargaDesc:
        _produkData.sort(
          (a, b) => (b['harga'] as int).compareTo(a['harga'] as int),
        );
        break;
      case SortOption.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Cari produk...'),
              )
            : const Text('List Data Produk'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          PopupMenuButton<SortOption>(
            onSelected: (opt) {
              setState(() {
                _sortOption = opt;
                _applySort();
                _filteredProduk = List<Map<String, dynamic>>.from(_produkData);
              });
              _saveProduk();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortOption.none, child: Text('Default')),
              PopupMenuItem(
                value: SortOption.namaAsc,
                child: Text('Nama (A-Z)'),
              ),
              PopupMenuItem(
                value: SortOption.hargaAsc,
                child: Text('Harga (Low-High)'),
              ),
              PopupMenuItem(
                value: SortOption.hargaDesc,
                child: Text('Harga (High-Low)'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return RefreshIndicator(
            onRefresh: _loadProduk,
            child: _filteredProduk.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Tidak ada data produk')),
                    ],
                  )
                : ListView.builder(
                    itemCount: _filteredProduk.length,
                    itemBuilder: (context, index) {
                      final item = _filteredProduk[index];
                      return Dismissible(
                        key: ValueKey(item['kode'] ?? index),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) =>
                            _showDeleteConfirmationDialogByKode(item['kode']!),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProdukDetail(
                                  kodeProduk: item['kode']!,
                                  namaProduk: item['nama']!,
                                  hargaProduk: item['harga']!,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              isThreeLine: true,
                              title: Text(item['nama']!),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kode: ${item['kode']!}'),
                                  Text('Harga: ${item['harga']!}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProdukForm(produk: item),
                                            ),
                                          );

                                      if (result != null &&
                                          result is Map<String, dynamic>) {
                                        final actualIndex = _produkData
                                            .indexWhere(
                                              (p) => p['kode'] == item['kode'],
                                            );
                                        setState(() {
                                          if (actualIndex != -1) {
                                            _produkData[actualIndex] = result;
                                          }
                                          _onSearchChanged();
                                        });
                                        await _saveProduk();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ProdukForm()));

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _produkData.add(result);
              _onSearchChanged();
            });
            await _saveProduk();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialogByKode(String kode) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final idx = _produkData.indexWhere((p) => p['kode'] == kode);
              if (idx != -1) {
                setState(() {
                  _produkData.removeAt(idx);
                  _onSearchChanged();
                });
                await _saveProduk();
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

enum SortOption { none, namaAsc, hargaAsc, hargaDesc }

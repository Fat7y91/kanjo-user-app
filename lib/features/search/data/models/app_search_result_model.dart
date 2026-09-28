import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';

class AppSearchResultModel {
  const AppSearchResultModel({
    required this.query,
    this.products = const [],
    this.vendors = const [],
    this.productGroupLabel = 'Products',
    this.vendorGroupLabel = 'Vendors',
  });

  final String query;
  final List<ProductModel> products;
  final List<VendorModel> vendors;
  final String productGroupLabel;
  final String vendorGroupLabel;

  bool get isEmpty => products.isEmpty && vendors.isEmpty;

  factory AppSearchResultModel.fromJson(Map<String, dynamic> json) {
    final groups = json['groups'];
    var products = const <ProductModel>[];
    var vendors = const <VendorModel>[];
    var productLabel = 'Products';
    var vendorLabel = 'Vendors';

    if (groups is List) {
      for (final raw in groups.whereType<Map>()) {
        final group = Map<String, dynamic>.from(raw);
        final key = group['key']?.toString().toLowerCase() ?? '';
        final label = group['label']?.toString() ?? '';
        final items = group['items'];
        if (items is! List) continue;

        if (key == 'products') {
          productLabel = label.isNotEmpty ? label : productLabel;
          products = items.whereType<Map>().map((e) {
            final map = Map<String, dynamic>.from(e);
            final name = map['name'];
            if (name is Map) {
              map['name'] = Map<String, dynamic>.from(name);
            }
            final description = map['description'];
            if (description is Map) {
              map['description'] = Map<String, dynamic>.from(description);
            }
            return ProductModel.fromJson(map);
          }).toList();
        } else if (key == 'vendors') {
          vendorLabel = label.isNotEmpty ? label : vendorLabel;
          vendors = items.whereType<Map>().map((e) {
            final map = Map<String, dynamic>.from(e);
            final type = map['type'];
            if (type is Map) {
              final typeMap = Map<String, dynamic>.from(type);
              final typeName = typeMap['name'];
              if (typeName is Map) {
                typeMap['name'] = Map<String, dynamic>.from(typeName);
              }
              map['type'] = typeMap;
            }
            final rating = map['rating_summary'];
            if (rating is Map) {
              map['rating_summary'] = Map<String, dynamic>.from(rating);
            }
            return VendorModel.fromJson(map);
          }).toList();
        }
      }
    }

    return AppSearchResultModel(
      query: json['query']?.toString() ?? '',
      products: products,
      vendors: vendors,
      productGroupLabel: productLabel,
      vendorGroupLabel: vendorLabel,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'groups': [
          {
            'key': 'products',
            'label': productGroupLabel,
            'items': products.map((e) => e.toJson()).toList(),
          },
          {
            'key': 'vendors',
            'label': vendorGroupLabel,
            'items': vendors.map((e) => e.toJson()).toList(),
          },
        ],
      };
}

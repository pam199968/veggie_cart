// ignore_for_file: unused_import
// Copyright (c) 2025 Patrick Mortas
// All rights reserved.

import 'print_util_stub.dart'
    if (dart.library.js_interop) 'print_util_web.dart'
    if (dart.library.io) 'print_util_mobile.dart';

/// 🔹 Impression du tableau de préparation par légume
Future<void> printVegetableTable(List<List<String>> rows) =>
    printVegetableTableImpl(rows);

/// 🔹 Impression du tableau de préparation par client
Future<void> printCustomerOrders(Map<String, List<dynamic>> ordersByCustomer) =>
    printCustomerOrdersImpl(ordersByCustomer);

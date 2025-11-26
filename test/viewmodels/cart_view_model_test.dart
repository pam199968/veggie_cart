import 'package:au_bio_jardin_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:au_bio_jardin_app/models/weekly_offer.dart';
import 'package:au_bio_jardin_app/models/vegetable_model.dart';
import 'package:au_bio_jardin_app/models/order_item.dart';
import 'package:au_bio_jardin_app/models/user_model.dart';
import 'package:au_bio_jardin_app/models/profile.dart';
import 'package:au_bio_jardin_app/models/delivery_method_config.dart';

import 'package:au_bio_jardin_app/viewmodels/cart_view_model.dart';
import 'package:au_bio_jardin_app/viewmodels/account_view_model.dart';
import 'package:au_bio_jardin_app/viewmodels/weekly_offers_view_model.dart';

import 'package:au_bio_jardin_app/repositories/order_repository.dart';

@GenerateMocks([AccountViewModel, WeeklyOffersViewModel, OrderRepository])
import 'cart_view_model_test.mocks.dart';

void main() {
  group('CartViewModel Tests', () {
    late CartViewModel cart;
    late MockAccountViewModel mockAccountVM;
    late MockWeeklyOffersViewModel mockWeeklyOffersVM;
    late MockOrderRepository mockOrderRepo;

    late UserModel testUser;
    late WeeklyOffer testOffer;
    late VegetableModel carrot;
    late VegetableModel tomato;
    late DeliveryMethodConfig deliveryMethod;

    setUp(() {
      mockAccountVM = MockAccountViewModel();
      mockWeeklyOffersVM = MockWeeklyOffersViewModel();
      mockOrderRepo = MockOrderRepository();

      cart = CartViewModel(
        accountViewModel: mockAccountVM,
        weeklyOffersViewModel: mockWeeklyOffersVM,
        orderRepository: mockOrderRepo,
      );

      testUser = UserModel(
        id: "user-123",
        name: "Dupont",
        givenName: "Marie",
        email: "marie@example.com",
        phoneNumber: "",
        address: "",
        deliveryMethod: DeliveryMethodConfig(
          key: "farmPickup",
          label: "Ferme",
          enabled: true,
          isDefault: true,
        ),
        pushNotifications: true,
        profile: Profile.customer,
      );

      carrot = VegetableModel(
        id: "v1",
        name: "Carotte",
        category: VegetableCategory.root,
        price: 2,
        packaging: "kg",
        standardQuantity: 5,
      );

      tomato = VegetableModel(
        id: "v2",
        name: "Tomate",
        category: VegetableCategory.fruit,
        price: 3,
        packaging: "kg",
        standardQuantity: 4,
      );

      testOffer = WeeklyOffer(
        id: "offer-1",
        title: "Offre de la semaine",
        description: "Légumes frais de saison",
        status: WeeklyOfferStatus.published,
        vegetables: [carrot, tomato],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      deliveryMethod = DeliveryMethodConfig(
        key: "farmPickup",
        label: "Retrait Ferme",
        enabled: true,
        isDefault: true,
      );
    });

    // 📌 OFFER TESTS
    test('setOffer initialise une offre et vide le panier', () {
      cart.updateQuantity(carrot, 2);
      cart.setOffer(testOffer);

      expect(cart.offer, testOffer);
      expect(cart.items.length, 0);
    });

    test('setOffer notifie les listeners', () {
      var notified = false;
      cart.addListener(() => notified = true);

      cart.setOffer(testOffer);
      expect(notified, isTrue);
    });

    // 📌 UPDATE QUANTITY TESTS
    test('updateQuantity ajoute ou modifie un item', () {
      cart.updateQuantity(carrot, 2);
      expect(cart.items[carrot], 2);

      cart.updateQuantity(carrot, 3);
      expect(cart.items[carrot], 3);
    });

    test('updateQuantity supprime si quantité <= 0', () {
      cart.updateQuantity(carrot, 2);
      cart.updateQuantity(carrot, 0); // suppression
      expect(cart.items.length, 0);
    });

    test('updateQuantity notifie les listeners', () {
      var notified = false;
      cart.addListener(() => notified = true);

      cart.updateQuantity(carrot, 2);
      expect(notified, isTrue);
    });

    // 📌 CLEAR TESTS
    test('clearCart vide le panier et retire l\'offre', () {
      cart.setOffer(testOffer);
      cart.updateQuantity(carrot, 2);
      cart.clearCart();

      expect(cart.items.length, 0);
      expect(cart.offer, isNull);
    });

    test('clearCart notifie les listeners', () {
      var notified = false;
      cart.addListener(() => notified = true);

      cart.clearCart();
      expect(notified, isTrue);
    });

    // 📌 SELECTED VEGETABLES TESTS
    test('selectedVegetables retourne les légumes avec quantité locale', () {
      cart.setOffer(testOffer);
      cart.updateQuantity(carrot, 2);

      final selected = cart.selectedVegetables;

      expect(selected.length, 1);
      expect(selected.first.name, "Carotte");
      expect(selected.first.selectedQuantity, 2);
    });

    test('selectedVegetables retourne [] si pas d\'offre', () {
      final selected = cart.selectedVegetables;
      expect(selected.length, 0);
    });

    // 📌 ORDER ITEMS TESTS
    test('orderItems transforme le panier en OrderItem', () {
      cart.updateQuantity(carrot, 2);
      cart.updateQuantity(tomato, 1);

      final items = cart.orderItems;

      expect(items.length, 2);
      expect(items.any((i) => i.vegetable.name == "Carotte"), isTrue);
    });

    test('totalItems retourne le nombre d\'items', () {
      cart.updateQuantity(carrot, 2);
      cart.updateQuantity(tomato, 1);

      expect(cart.totalItems, 2);
    });

    // 📌 SUBMIT ORDER TESTS
    testWidgets('submitOrder crée une commande et efface le panier', (
      tester,
    ) async {
      // Arrange
      cart.setOffer(testOffer);
      cart.updateQuantity(carrot, 1);
      when(mockAccountVM.currentUser).thenReturn(testUser);
      final createdOrder = OrderModel(
        id: 'order-1',
        orderNumber: "BC12345",
        offerSummary: WeeklyOfferSummary(
          id: testOffer.id!,
          title: testOffer.title,
          description: testOffer.description,
          status: testOffer.status,
          startDate: testOffer.startDate,
          endDate: testOffer.endDate,
        ),
        customerId: 'user-123',
        items: cart.orderItems,
        deliveryMethod: deliveryMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(
        mockOrderRepo.createOrder(
          customerId: anyNamed('customerId'),
          offerSummary: anyNamed('offerSummary'),
          deliveryMethod: anyNamed('deliveryMethod'),
          items: anyNamed('items'),
          notes: anyNamed('notes'),
        ),
      ).thenAnswer((_) async => createdOrder);

      // Act
      await cart.submitOrder(deliveryMethod: deliveryMethod, notes: "Test");

      // Assert
      verify(
        mockOrderRepo.createOrder(
          customerId: "user-123",
          offerSummary: anyNamed('offerSummary'),
          deliveryMethod: deliveryMethod,
          items: anyNamed('items'),
          notes: "Test",
        ),
      ).called(1);

      expect(cart.items.length, 0);
      expect(cart.offer, isNull);
    });

    testWidgets('submitOrder ne fait rien si panier vide', (tester) async {
      await cart.submitOrder(deliveryMethod: deliveryMethod);
      verifyNever(
        mockOrderRepo.createOrder(
          customerId: anyNamed('customerId'),
          offerSummary: anyNamed('offerSummary'),
          deliveryMethod: anyNamed('deliveryMethod'),
          items: anyNamed('items'),
          notes: anyNamed('notes'),
        ),
      );
    });
  });
}

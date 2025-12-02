// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutDescription =>
      'This app is designed for Bio jardin customers to manage orders.';

  @override
  String copyright(Object year) {
    return '© $year - Patrick M.';
  }

  @override
  String get searchCustomer => 'Search for a customer...';

  @override
  String get accountDeactivated => 'Account deactivated';

  @override
  String get disableAccount => 'Disable this account';

  @override
  String get reactivateAccount => 'Reactivate this account';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get offerStatus => 'Offer status';

  @override
  String get vegetablesIncluded => 'Vegetables included';

  @override
  String get editVegetable => 'Edit Vegetable';

  @override
  String get price => 'Price (optional)';

  @override
  String get packagingUnit => 'Packaging unit';

  @override
  String get removeVegetable => 'Remove the vegetable';

  @override
  String get moreVegetables => 'See more vegetables';

  @override
  String get removeVegetableQuestion =>
      'Do you really want to remove this vegetable from the offer?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving';

  @override
  String get selectVegetables => 'Select vegetables';

  @override
  String get searchVegetable => 'Search for a vegetable...';

  @override
  String get validate => 'Validate';

  @override
  String get orderInProgress => 'Order in progress';

  @override
  String get myCart => 'My cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get addNote => 'Add a note';

  @override
  String get backToOffer => 'Back to the offer';

  @override
  String get validateOrder => 'Validate my order';

  @override
  String get orderSent => 'Order sent!';

  @override
  String get finalizeOrder => 'Finalize the order';

  @override
  String get editOffer => 'Edit offer';

  @override
  String get newOffer => 'New offer';

  @override
  String get completeAllFields => 'Please complete all fields.';

  @override
  String get noOffersAvailable => 'No offers available';

  @override
  String get noOrders => 'No orders';

  @override
  String get byVegetable => 'By vegetable';

  @override
  String get byCustomer => 'By customer';

  @override
  String get customerPreparation => 'Customer preparation';

  @override
  String get delivery => 'Delivery: ';

  @override
  String get draft => 'Draft';

  @override
  String get published => 'Published';

  @override
  String get closed => 'Closed';

  @override
  String get all => 'All';

  @override
  String get offerCreation => 'Create an offer';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Duplicate';

  @override
  String get publish => 'Publish';

  @override
  String get close => 'Close';

  @override
  String get reopen => 'Reopen';

  @override
  String get weekOf => 'Week of';

  @override
  String get myOrders => 'My orders';

  @override
  String get vegetablePreparation => 'Vegetable preparation';

  @override
  String get print => 'Print';

  @override
  String get totalQuantity => 'Total quantity';

  @override
  String get packaging => 'Packaging';

  @override
  String get vegetable => 'Vegetable';

  @override
  String get quantity => 'Quantity';

  @override
  String get youHaveNoOrders => 'You have no orders.';

  @override
  String get order => 'Order n°';

  @override
  String get status => 'Status: ';

  @override
  String get deliveryMethod => 'Delivery Method: ';

  @override
  String get deliveryMethods => 'Delivery methods';

  @override
  String get searchDeliveryMethod => 'search delivery method';

  @override
  String get addDeliveryMethod => 'Add dlivery method';

  @override
  String get disable => 'Disable';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get noDeliveryMethodsFound => 'No delivery method found';

  @override
  String get editDeliveryMethod => 'Edit delivery method';

  @override
  String get notes => 'Notes: ';

  @override
  String get items => 'Items:';

  @override
  String get createdAt => 'Created at: ';

  @override
  String get userHasBeenDeactivated => 'has been deactivated.';

  @override
  String get unableToDeactivateUser => 'Unable to deactivate.';

  @override
  String get gardenersListTitle => 'Liste des maraîchers';

  @override
  String get addGardenerTooltip => 'Ajouter un maraîcher';

  @override
  String get noGardenersFound => 'Aucun maraîcher trouvé.';

  @override
  String get addGardenerDialogTitle => 'Ajouter un maraîcher';

  @override
  String get searchUserLabel => 'Rechercher un utilisateur';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get weeklyOffers => 'Weekly offers';

  @override
  String get offersManagement => 'Offers management';

  @override
  String get customerOrders => 'Customer orders';

  @override
  String get catalog => 'Catalog';

  @override
  String get gardenersList => 'List of administrators';

  @override
  String get customerOrdersTitle => 'Customer Orders';

  @override
  String get ordersListTitle => 'Orders List';

  @override
  String get preparationTitle => 'Preparation';

  @override
  String get noOrdersFound => 'No orders found.';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get orderStatusTitle => 'Order Status';

  @override
  String get attachedOffersTitle => 'Attached Offers';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get orderNumber => 'Order n°';

  @override
  String get customer => 'Customer: ';

  @override
  String get orderDetails => 'Order n°';

  @override
  String get weekRange => 'Week of ';

  @override
  String get weeklyOffersTitle => 'Weekly Offers';

  @override
  String get addWeeklyOfferTooltip => 'Add a weekly offer';

  @override
  String get noWeeklyOffersFound => 'No weekly offers found';

  @override
  String get addWeeklyOfferDialogTitle => 'Add a weekly offer';

  @override
  String get searchWeeklyOfferLabel => 'Search for a weekly offer';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editButton => 'Edit';

  @override
  String get confirmDelete => 'Are you sure you want to delete this offer?';

  @override
  String get update => 'Update';

  @override
  String get weeklyOfferDetails => 'Offer details';

  @override
  String get offer => 'Offer';

  @override
  String get description => 'Description';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get addVegetable => 'Add Vegetable';

  @override
  String get noVegetablesSelected => 'No vegetables selected';

  @override
  String get select => 'Select';

  @override
  String get weeklyOffer => 'Weekly offer';

  @override
  String get profileUpdateLabel => 'Edit My Profile';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get viewProfile => 'Consult my profile';

  @override
  String get userInfos => 'User Information';

  @override
  String get appTitle => 'My Vegetable Basket';

  @override
  String get nameLabel => 'Last Name';

  @override
  String get givenNameLabel => 'First Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordHint =>
      'Password must be at least 8 characters long, contain an uppercase letter and a number.';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get profileLabel => 'Profile';

  @override
  String get addressLabel => 'Address';

  @override
  String get deliveryMethodLabel => 'Delivery Method';

  @override
  String get pushNotificationLabel => 'Enable push notifications';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get signInButton => 'Sign In';

  @override
  String get createAccountLink => 'Create Account';

  @override
  String get emailError => 'Please enter a valid email address.';

  @override
  String get passwordError =>
      'Password must be at least 8 characters long, contain an uppercase letter and a number.';

  @override
  String get passwordMismatchError => 'Passwords do not match.';

  @override
  String get notConnected => 'User not connected';

  @override
  String get connectedAs => 'Connected as';

  @override
  String get add => 'Add';

  @override
  String get name => 'Name';

  @override
  String get category => 'Category';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get standardQuantity => 'Standard Quantity (optional)';

  @override
  String get active => 'Active';

  @override
  String get allCategories => 'All Categories';

  @override
  String get currencySymbol => '£';

  @override
  String get customersList => 'Customers list';

  @override
  String get noCustomersFound => 'No Customers Found';

  @override
  String get errorLoadingData => 'Error Loading Data';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get confirmCancelOrder => 'Confirm';

  @override
  String get confirmDeletion => 'Confirmation';

  @override
  String get deleteConfirmMessage => 'Confirm deletion';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';
}

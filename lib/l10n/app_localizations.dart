import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'This app is designed for Bio jardin customers to manage orders.'**
  String get aboutDescription;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Patrick M.'**
  String get copyright;

  /// No description provided for @searchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search for a customer...'**
  String get searchCustomer;

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated'**
  String get accountDeactivated;

  /// No description provided for @disableAccount.
  ///
  /// In en, this message translates to:
  /// **'Disable this account'**
  String get disableAccount;

  /// No description provided for @reactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Reactivate this account'**
  String get reactivateAccount;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @offerStatus.
  ///
  /// In en, this message translates to:
  /// **'Offer status'**
  String get offerStatus;

  /// No description provided for @vegetablesIncluded.
  ///
  /// In en, this message translates to:
  /// **'Vegetables included'**
  String get vegetablesIncluded;

  /// No description provided for @editVegetable.
  ///
  /// In en, this message translates to:
  /// **'Edit Vegetable'**
  String get editVegetable;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price (optional)'**
  String get price;

  /// No description provided for @packagingUnit.
  ///
  /// In en, this message translates to:
  /// **'Packaging unit'**
  String get packagingUnit;

  /// No description provided for @removeVegetable.
  ///
  /// In en, this message translates to:
  /// **'Remove the vegetable'**
  String get removeVegetable;

  /// No description provided for @moreVegetables.
  ///
  /// In en, this message translates to:
  /// **'See more vegetables'**
  String get moreVegetables;

  /// No description provided for @removeVegetableQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove this vegetable from the offer?'**
  String get removeVegetableQuestion;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @selectVegetables.
  ///
  /// In en, this message translates to:
  /// **'Select vegetables'**
  String get selectVegetables;

  /// No description provided for @searchVegetable.
  ///
  /// In en, this message translates to:
  /// **'Search for a vegetable...'**
  String get searchVegetable;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @orderInProgress.
  ///
  /// In en, this message translates to:
  /// **'Order in progress'**
  String get orderInProgress;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @backToOffer.
  ///
  /// In en, this message translates to:
  /// **'Back to the offer'**
  String get backToOffer;

  /// No description provided for @validateOrder.
  ///
  /// In en, this message translates to:
  /// **'Validate my order'**
  String get validateOrder;

  /// No description provided for @orderSent.
  ///
  /// In en, this message translates to:
  /// **'Order sent!'**
  String get orderSent;

  /// No description provided for @finalizeOrder.
  ///
  /// In en, this message translates to:
  /// **'Finalize the order'**
  String get finalizeOrder;

  /// No description provided for @editOffer.
  ///
  /// In en, this message translates to:
  /// **'Edit offer'**
  String get editOffer;

  /// No description provided for @newOffer.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get newOffer;

  /// No description provided for @completeAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all fields.'**
  String get completeAllFields;

  /// No description provided for @noOffersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get noOffersAvailable;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get noOrders;

  /// No description provided for @byVegetable.
  ///
  /// In en, this message translates to:
  /// **'By vegetable'**
  String get byVegetable;

  /// No description provided for @byCustomer.
  ///
  /// In en, this message translates to:
  /// **'By customer'**
  String get byCustomer;

  /// No description provided for @customerPreparation.
  ///
  /// In en, this message translates to:
  /// **'Customer preparation'**
  String get customerPreparation;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery: '**
  String get delivery;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @offerCreation.
  ///
  /// In en, this message translates to:
  /// **'Create an offer'**
  String get offerCreation;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get copy;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of'**
  String get weekOf;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @vegetablePreparation.
  ///
  /// In en, this message translates to:
  /// **'Vegetable preparation'**
  String get vegetablePreparation;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total quantity'**
  String get totalQuantity;

  /// No description provided for @packaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get packaging;

  /// No description provided for @vegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetable'**
  String get vegetable;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @youHaveNoOrders.
  ///
  /// In en, this message translates to:
  /// **'You have no orders.'**
  String get youHaveNoOrders;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order n°'**
  String get order;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get status;

  /// No description provided for @deliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method: '**
  String get deliveryMethod;

  /// No description provided for @deliveryMethods.
  ///
  /// In en, this message translates to:
  /// **'Delivery methods'**
  String get deliveryMethods;

  /// No description provided for @searchDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'search delivery method'**
  String get searchDeliveryMethod;

  /// No description provided for @addDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Add dlivery method'**
  String get addDeliveryMethod;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @noDeliveryMethodsFound.
  ///
  /// In en, this message translates to:
  /// **'No delivery method found'**
  String get noDeliveryMethodsFound;

  /// No description provided for @editDeliveryMethod.
  ///
  /// In en, this message translates to:
  /// **'Edit delivery method'**
  String get editDeliveryMethod;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes: '**
  String get notes;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items:'**
  String get items;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at: '**
  String get createdAt;

  /// No description provided for @userHasBeenDeactivated.
  ///
  /// In en, this message translates to:
  /// **'has been deactivated.'**
  String get userHasBeenDeactivated;

  /// No description provided for @unableToDeactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Unable to deactivate.'**
  String get unableToDeactivateUser;

  /// No description provided for @gardenersListTitle.
  ///
  /// In en, this message translates to:
  /// **'Liste des maraîchers'**
  String get gardenersListTitle;

  /// No description provided for @addGardenerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Ajouter un maraîcher'**
  String get addGardenerTooltip;

  /// No description provided for @noGardenersFound.
  ///
  /// In en, this message translates to:
  /// **'Aucun maraîcher trouvé.'**
  String get noGardenersFound;

  /// No description provided for @addGardenerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Ajouter un maraîcher'**
  String get addGardenerDialogTitle;

  /// No description provided for @searchUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Rechercher un utilisateur'**
  String get searchUserLabel;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Aucun résultat'**
  String get noResults;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// No description provided for @weeklyOffers.
  ///
  /// In en, this message translates to:
  /// **'Weekly offers'**
  String get weeklyOffers;

  /// No description provided for @offersManagement.
  ///
  /// In en, this message translates to:
  /// **'Offers management'**
  String get offersManagement;

  /// No description provided for @customerOrders.
  ///
  /// In en, this message translates to:
  /// **'Customer orders'**
  String get customerOrders;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @gardenersList.
  ///
  /// In en, this message translates to:
  /// **'List of administrators'**
  String get gardenersList;

  /// No description provided for @customerOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Orders'**
  String get customerOrdersTitle;

  /// No description provided for @ordersListTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders List'**
  String get ordersListTitle;

  /// No description provided for @preparationTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparationTitle;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found.'**
  String get noOrdersFound;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @orderStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatusTitle;

  /// No description provided for @attachedOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Attached Offers'**
  String get attachedOffersTitle;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order n°'**
  String get orderNumber;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer: '**
  String get customer;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order n°'**
  String get orderDetails;

  /// No description provided for @weekRange.
  ///
  /// In en, this message translates to:
  /// **'Week of '**
  String get weekRange;

  /// No description provided for @weeklyOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Offers'**
  String get weeklyOffersTitle;

  /// No description provided for @addWeeklyOfferTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a weekly offer'**
  String get addWeeklyOfferTooltip;

  /// No description provided for @noWeeklyOffersFound.
  ///
  /// In en, this message translates to:
  /// **'No weekly offers found'**
  String get noWeeklyOffersFound;

  /// No description provided for @addWeeklyOfferDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a weekly offer'**
  String get addWeeklyOfferDialogTitle;

  /// No description provided for @searchWeeklyOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Search for a weekly offer'**
  String get searchWeeklyOfferLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this offer?'**
  String get confirmDelete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @weeklyOfferDetails.
  ///
  /// In en, this message translates to:
  /// **'Offer details'**
  String get weeklyOfferDetails;

  /// No description provided for @offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @addVegetable.
  ///
  /// In en, this message translates to:
  /// **'Add Vegetable'**
  String get addVegetable;

  /// No description provided for @noVegetablesSelected.
  ///
  /// In en, this message translates to:
  /// **'No vegetables selected'**
  String get noVegetablesSelected;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @weeklyOffer.
  ///
  /// In en, this message translates to:
  /// **'Weekly offer'**
  String get weeklyOffer;

  /// No description provided for @profileUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit My Profile'**
  String get profileUpdateLabel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'Consult my profile'**
  String get viewProfile;

  /// No description provided for @userInfos.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInfos;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Vegetable Basket'**
  String get appTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get nameLabel;

  /// No description provided for @givenNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get givenNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long, contain an uppercase letter and a number.'**
  String get passwordHint;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @deliveryMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get deliveryMethodLabel;

  /// No description provided for @pushNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications'**
  String get pushNotificationLabel;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountLink;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailError;

  /// No description provided for @passwordError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long, contain an uppercase letter and a number.'**
  String get passwordError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatchError;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'User not connected'**
  String get notConnected;

  /// No description provided for @connectedAs.
  ///
  /// In en, this message translates to:
  /// **'Connected as'**
  String get connectedAs;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @standardQuantity.
  ///
  /// In en, this message translates to:
  /// **'Standard Quantity (optional)'**
  String get standardQuantity;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'£'**
  String get currencySymbol;

  /// No description provided for @customersList.
  ///
  /// In en, this message translates to:
  /// **'Customers list'**
  String get customersList;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No Customers Found'**
  String get noCustomersFound;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Data'**
  String get errorLoadingData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

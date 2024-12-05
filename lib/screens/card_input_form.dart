import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:next_card/utils/colors_const.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



class CreditCardInputForm extends StatefulWidget {
  const CreditCardInputForm({super.key});

  @override
  State<CreditCardInputForm> createState() => _CreditCardInputFormState();
}

class _CreditCardInputFormState extends State<CreditCardInputForm> {
  bool isLightTheme = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = true;

  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'credit_cards.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE cards(id INTEGER PRIMARY KEY, cardNumber TEXT, expiryDate TEXT, cardHolderName TEXT, cvvCode TEXT)'
        );
      },
      version: 1,
    );
  }

  Future<void> _saveCard() async {
    if (_database != null) {
      await _database!.insert(
        'cards',
        {
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cardHolderName': cardHolderName,
          'cvvCode': cvvCode,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Card saved successfully!');
    }
  }

  Future<void> _navigateToCardList(BuildContext context) async {
    if (_database != null) {
      final List<Map<String, dynamic>> cards = await _database!.query('cards');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardListPage(
            cards: cards,
            database: _database!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      title: 'Next Credit Card',
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: _buildThemeData(Brightness.light),
      darkTheme: _buildThemeData(Brightness.dark),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: isLightTheme ? AppColors.bgLight : AppColors.bgDark,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => _navigateToCardList(context),
                            icon: Icon(Icons.sd_card_outlined, color: isLightTheme ? Colors.black : Colors.white),
                          ),
                          const Text(
                            'Next Credit Card',
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              isLightTheme = !isLightTheme;
                            }),
                            icon: Icon(
                              isLightTheme ? Icons.light_mode : Icons.dark_mode,
                              color: isLightTheme ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      glassmorphismConfig: _getGlassmorphismConfig(),
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'Axis Bank',
                      frontCardBorder:
                      useGlassMorphism ? null : Border.all(color: Colors.grey),
                      backCardBorder:
                      useGlassMorphism ? null : Border.all(color: Colors.grey),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      cardBgColor: isLightTheme
                          ? AppColors.cardBgLightColor
                          : AppColors.cardBgColor,
                      backgroundImage:
                      useBackgroundImage ? 'assets/card_bg.png' : 'assets/card_bg1.png',
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            _buildSwitchRow('Glassmorphism', useGlassMorphism,
                                    (value) => setState(() => useGlassMorphism = value)),
                            _buildSwitchRow('Card Image', useBackgroundImage,
                                    (value) => setState(() => useBackgroundImage = value)),
                            _buildSwitchRow('Floating Card', useFloatingAnimation,
                                    (value) => setState(() => useFloatingAnimation = value)),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _onValidate,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      AppColors.colorB58D67,
                                      AppColors.colorF9EED2,
                                    ],
                                    begin: Alignment(-1, -4),
                                    end: Alignment(1, 4),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Validate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'halter',
                                    fontSize: 14,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildThemeData(Brightness brightness) {
    return ThemeData(
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
          fontSize: 18,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: brightness == Brightness.light ? Colors.white : Colors.black,
        background: brightness == Brightness.light ? Colors.black : Colors.white,
        primary: brightness == Brightness.light ? Colors.black : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        labelStyle: TextStyle(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      _saveCard();
    } else {
      print('Invalid!');
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );
    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title),
          const Spacer(),
          Switch(
            value: value,
            inactiveTrackColor: Colors.white70,
            activeColor: Colors.white,
            activeTrackColor: AppColors.colorE5D1B2,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}


class CardListPage extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final Database database;

  const CardListPage({
    Key? key,
    required this.cards,
    required this.database,
  }) : super(key: key);

  Future<void> _deleteCard(int id) async {
    await database.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Card deleted successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cards'),
        backgroundColor: AppColors.colorB58D67,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: const Icon(
                Icons.credit_card,
                color: AppColors.colorB58D67,
              ),
              title: Text(card['cardHolderName'] ?? 'No Name'),
              subtitle: Text(
                '**** **** **** ${card['cardNumber']?.substring(card['cardNumber'].length - 4)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCardPage(
                            card: card,
                            database: database,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _deleteCard(card['id']);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardListPage(
                            cards: List.from(cards)..removeAt(index),
                            database: database,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class EditCardPage extends StatefulWidget {
  final Map<String, dynamic> card;
  final Database database;

  const EditCardPage({
    super.key,
    required this.card,
    required this.database,
  });

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;

  @override
  void initState() {
    super.initState();
    cardNumber = widget.card['cardNumber'] ?? '';
    expiryDate = widget.card['expiryDate'] ?? '';
    cardHolderName = widget.card['cardHolderName'] ?? '';
    cvvCode = widget.card['cvvCode'] ?? '';
  }

  Future<void> _updateCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      final id = widget.card['id'];
      if (id != null) {
        await widget.database.update(
          'cards',
          {
            'cardNumber': cardNumber,
            'expiryDate': expiryDate,
            'cardHolderName': cardHolderName,
            'cvvCode': cvvCode,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        print('Card updated successfully!');
        //Navigator.of(context).pop(true);
      } else {
        print('Card ID is null. Cannot update.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        backgroundColor: AppColors.colorB58D67,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: cardNumber,
                decoration: const InputDecoration(labelText: 'Card Number'),
                onChanged: (value) => cardNumber = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Card Number is required' : null,
              ),
              TextFormField(
                initialValue: expiryDate,
                decoration: const InputDecoration(labelText: 'Expiry Date'),
                onChanged: (value) => expiryDate = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Expiry Date is required' : null,
              ),
              TextFormField(
                initialValue: cardHolderName,
                decoration: const InputDecoration(labelText: 'Card Holder Name'),
                onChanged: (value) => cardHolderName = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Card Holder Name is required' : null,
              ),
              TextFormField(
                initialValue: cvvCode,
                decoration: const InputDecoration(labelText: 'CVV Code'),
                onChanged: (value) => cvvCode = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'CVV Code is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCard,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

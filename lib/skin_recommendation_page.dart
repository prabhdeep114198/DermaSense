import 'package:flutter/material.dart';

class SkinRecommendationPage extends StatefulWidget {
  @override
  _SkinRecommendationPageState createState() => _SkinRecommendationPageState();
}

class _SkinRecommendationPageState extends State<SkinRecommendationPage> {
  final _formKey = GlobalKey<FormState>();

  String? _skinType;
  String? _skinConcern;
  String? _ageRange;
  String? _sunExposure;
  String? _waterIntake;
  bool _hasAllergies = false;

  String? recommendation;

  final List<String> skinTypes = [
    'Oily',
    'Dry',
    'Combination',
    'Sensitive',
    'Normal',
  ];
  final List<String> skinConcerns = [
    'Acne',
    'Dark spots',
    'Wrinkles',
    'Dryness',
    'Redness',
  ];
  final List<String> ageRanges = ['Under 18', '18-25', '26-35', '36-50', '50+'];
  final List<String> sunExposureLevels = ['Low', 'Moderate', 'High'];
  final List<String> waterIntakeLevels = [
    '< 1L/day',
    '1-2L/day',
    '2L+ per day',
  ];

  void recommendProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        // Enhanced mock logic (you can replace with ML model/API)
        if (_skinType == 'Oily' && _skinConcern == 'Acne') {
          recommendation = '''
🔹 Morning:
- Cleanser: Salicylic acid face wash
- Serum: Niacinamide 10%
- Moisturizer: Oil-free gel
- Sunscreen: SPF 50 matte finish

🔹 Night:
- Cleanser: Gentle foaming cleanser
- Treatment: Benzoyl peroxide 2.5%
- Serum: Retinol (if age > 25)
- Moisturizer: Lightweight non-comedogenic

💡 Tip: Drink at least 2L of water per day and avoid greasy foods.
''';
        } else {
          recommendation = '''
🔹 Morning:
- Cleanser: Mild hydrating cleanser
- Serum: Vitamin C
- Moisturizer: $_skinType-specific hydration
- Sunscreen: SPF 30+

🔹 Night:
- Cleanser: $_skinType friendly cleanser
- Serum: Hyaluronic acid
- Moisturizer: Deep repair night cream

💡 Based on your lifestyle, try reducing $_sunExposure sun exposure and increase water intake to $_waterIntake.
''';
        }

        if (_hasAllergies) {
          recommendation =
              '$recommendation\n⚠️ Note: Always check for allergens before trying new products.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DermaSense - Personalized Skincare'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Skin Type'),
                items:
                    skinTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => _skinType = val,
                validator: (val) => val == null ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Primary Skin Concern'),
                items:
                    skinConcerns
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => _skinConcern = val,
                validator: (val) => val == null ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Age Range'),
                items:
                    ageRanges
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => _ageRange = val,
                validator: (val) => val == null ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Sun Exposure'),
                items:
                    sunExposureLevels
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => _sunExposure = val,
                validator: (val) => val == null ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Daily Water Intake'),
                items:
                    waterIntakeLevels
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => _waterIntake = val,
                validator: (val) => val == null ? 'Required' : null,
              ),
              SwitchListTile(
                title: Text('Do you have any known skin allergies?'),
                value: _hasAllergies,
                onChanged: (val) => setState(() => _hasAllergies = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: recommendProduct,
                child: Text('Get Personalized Routine'),
              ),
              SizedBox(height: 30),
              if (recommendation != null)
                Text(recommendation!, style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/service/rescue_camp_service.dart';

class AddNeedDonationPage extends StatefulWidget {
  const AddNeedDonationPage({super.key});

  @override
  State<AddNeedDonationPage> createState() => _AddNeedDonationPageState();
}

class _AddNeedDonationPageState extends State<AddNeedDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final RescueCampService _rescueCampService = RescueCampService();
  
  String? _selectedCategory;
  String? _selectedUrgency;
  int? _selectedCampId;
  final TextEditingController _quantityController = TextEditingController();

  final List<String> _categories = ['Food', 'Medicine', 'Clothes', 'Price'];
  final List<String> _urgencyLevels = ['High', 'Medium', 'Low'];
  
  List<dynamic> _rescueCamps = [];
  bool _isLoadingCamps = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    setState(() => _isLoadingCamps = true);
    final camps = await _rescueCampService.getAllRescueCamps();
    if (mounted) {
      setState(() {
        _rescueCamps = camps;
        _isLoadingCamps = false;
      });
    }
  }

  Future<void> _submitNeed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCampId == null) return;

    setState(() => _isSubmitting = true);

    dynamic foodQty = "0";
    dynamic medicineQty = "0";
    dynamic clothesQty = "0";
    dynamic priceQty = "0";

    String value = _quantityController.text;

    switch (_selectedCategory) {
      case 'Food':
        foodQty = int.tryParse(value) ?? value;
        break;
      case 'Medicine':
        medicineQty = value;
        break;
      case 'Clothes':
        clothesQty = value;
        break;
      case 'Price':
        priceQty = value;
        break;
    }

    final success = await _rescueCampService.createResourceNeed(
      foodQty: foodQty,
      medicineQty: medicineQty,
      clothesQty: clothesQty,
      priceQty: priceQty,
      urgencyLevel: _selectedUrgency!,
      rescueCampId: _selectedCampId!,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation need added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add donation need. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Need Donation'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: _isLoadingCamps 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Specify Donation Need',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Item Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Item Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 20),

              // Quantity Field (Shown after category selection)
              if (_selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity of $_selectedCategory',
                      hintText: _selectedCategory == 'Food' ? 'e.g. 50' : 'e.g. 100 sets, 20 boxes',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.inventory),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the quantity';
                      }
                      return null;
                    },
                  ),
                ),

              // Urgency Level Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Urgency Level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                value: _selectedUrgency,
                items: _urgencyLevels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUrgency = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select urgency level' : null,
              ),
              const SizedBox(height: 20),

              // Rescue Camp Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Select Rescue Camp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_work),
                ),
                value: _selectedCampId,
                items: _rescueCamps.map<DropdownMenuItem<int>>((dynamic camp) {
                  return DropdownMenuItem<int>(
                    value: camp['id'],
                    child: Text(camp['name'] ?? 'Unnamed Camp'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCampId = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a rescue camp' : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitNeed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Need',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

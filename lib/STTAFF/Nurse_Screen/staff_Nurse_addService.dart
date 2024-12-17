import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Staff_Nurse_Addservice extends StatefulWidget {
  const Staff_Nurse_Addservice({super.key});

  @override
  State<Staff_Nurse_Addservice> createState() => _Staff_Nurse_AddserviceState();
}

class _Staff_Nurse_AddserviceState extends State<Staff_Nurse_Addservice> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  // final TextEditingController _categoryController = TextEditingController();
  File? _pickedImage;

  List<Map<String, dynamic>> categoryList = [];
  String? selectedCategory;
  String? selectedCategoryId;

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://164.92.111.149/api/service-categories/'),
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'FdRlM2aeZHaxUXhD6v20guchkzoL6eQLDhhmoAmIMqVtn6UR2k9c9c4c0W6muGIz',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List categories = data['results'];

        setState(() {
          categoryList = categories
              .map((category) => {
                    'id': category['id'],
                    'name': category['name'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> postService() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');
      final nurseId = prefs.getInt('nurseId'); // Ensure this ID is valid

      if (token == null || nurseId == null || selectedCategoryId == null) {
        throw Exception(
            'Missing token, nurseId, or categoryId in shared preferences');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://164.92.111.149/api/services/'),
      );

      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'duration': _durationController.text,
        'category': selectedCategoryId.toString(),
        'nurses': nurseId.toString(), // إرسال الممرضة الصحيحة
      });

      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _pickedImage!.path),
        );
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Service posted successfully!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _pickedImage = null;
        });
      } else {
        final errorResponse = jsonDecode(responseString);
        throw Exception(
            'Failed to post service: ${errorResponse['detail'] ?? responseString}');
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Service Name
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Service Name',
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                  ),
                ),

                // Description
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                    ),
                  ),
                ),

                // Price
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Price is required' : null,
                    ),
                  ),
                ),

                // Duration
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (HH:MM:SS)',
                        border: InputBorder.none,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Duration is required' : null,
                    ),
                  ),
                ),

                // Category dropdown
                categoryList.isEmpty
                    ? const CircularProgressIndicator(
                        color: Colors.teal,
                      )
                    : Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            hint: const Text('Select Category'),
                            onChanged: (newValue) {
                              setState(() {
                                selectedCategory = newValue;
                                selectedCategoryId = categoryList
                                    .firstWhere(
                                      (category) =>
                                          category['name'] == newValue,
                                      orElse: () => {'id': null},
                                    )['id']
                                    .toString();
                              });
                            },
                            items: categoryList.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['name'],
                                child: Text(category['name']),
                              );
                            }).toList(),
                            decoration:
                                const InputDecoration(labelText: 'Category'),
                            validator: (value) =>
                                value == null ? 'Category is required' : null,
                          ),
                        ),
                      ),

                // Image picker
                GestureDetector(
                  onTap: pickImage,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 5,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _pickedImage == null
                          ? const Center(child: Text('Tap to pick an image'))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child:
                                  Image.file(_pickedImage!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: postService,
                  child: const Text('Submit Service',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
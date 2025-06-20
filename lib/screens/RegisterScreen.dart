import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  XFile? imagen;

  void cambiarImagen(XFile nuevaImagen) {
    setState(() {
      imagen = nuevaImagen;
    });
  }

  Future<void> _onRegister() async {
    final supabase = Supabase.instance.client;

    if (_formKey.currentState!.validate()) {
      try {
        final AuthResponse res = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final user = res.user;

        if (user != null) {
          final insertResponse = await supabase.from('usuarios').insert({
            'username': _usernameController.text.trim(),
            'edad': int.parse(_ageController.text),
            'user_id': user.id,
          });

          if (insertResponse.error != null) {
            throw insertResponse.error!;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario registrado correctamente')),
          );

          Navigator.pushReplacementNamed(context, '/login');
        }
      } on AuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Crear Cuenta'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Regístrate para comenzar',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Ingrese su nombre de usuario'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su edad';
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) return 'Edad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => (value == null || value.length < 6)
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => abrirGaleria(cambiarImagen),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => abrirCamara(cambiarImagen),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (imagen != null) ...[
                Image.file(File(imagen!.path), width: 350, height: 400),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => subirImagen(imagen!),
                  icon: const Icon(Icons.upload_sharp),
                  label: const Text('Subir Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ] else
                const Text("No hay imagen seleccionada"),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Registrar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _onRegister,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- FUNCIONES AUXILIARES ----------

Future<void> abrirGaleria(Function cambiarImagen) async {
  final imagenSeleccionada = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );
  if (imagenSeleccionada != null) cambiarImagen(imagenSeleccionada);
}

Future<void> abrirCamara(Function cambiarImagen) async {
  final imagenSeleccionada = await ImagePicker().pickImage(
    source: ImageSource.camera,
  );
  if (imagenSeleccionada != null) cambiarImagen(imagenSeleccionada);
}

Future<void> subirImagen(XFile imagen) async {
  final supabase = Supabase.instance.client;

  final String uniqueFileName =
      'public/avatar_${DateTime.now().millisecondsSinceEpoch}.png';

  final avatarFile = File(imagen.path);
  await supabase.storage.from('personajes').upload(
        uniqueFileName,
        avatarFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
}

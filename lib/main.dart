import 'package:guia_07/instancia_bd.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ...
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllerDNI = TextEditingController();
  final TextEditingController _controllerNombre = TextEditingController();

  late Future<List> listaUsuarios;

  @override
  void initState(){
    super.initState();
    listaUsuarios = obtenerUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase"),
      ),
      body: FutureBuilder<List>(
        future: listaUsuarios,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar usuarios"),
            );
          }else if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final usuario = snapshot.data![index];
                final dni = usuario['dni'];
                final nombre = usuario['nombre'];
                final uid = usuario['uid'];
                return ListTile(
                  title: Text(nombre),
                  subtitle: Text("DNI: $dni"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _eliminarUsuario(uid);
                    },
                  ),
                  onTap: () {
                    _showEditDialog(uid, dni, nombre);
                  },
                );
              },
            );
          } else {
            return Center(
              child: Text("No se encontraron Usuarios"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dialogAgregarUsuario();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void mostrarLista(){
    setState(() {
      listaUsuarios = obtenerUsuario();
    });
  }
  void dialogAgregarUsuario() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Agregar Usuario"),
          content: Column(
            children: [
              TextField(controller: _controllerDNI, decoration: const InputDecoration(hintText: "DNI"),),
              TextField(controller: _controllerNombre, decoration: const InputDecoration(hintText: "Nombre"),),
            ],
          ), actions: [
          ElevatedButton(onPressed: () async{
            await agregarUsuario(
              _controllerDNI.text.toString(),
              _controllerNombre.text.toString()).then((_){
                Navigator.of(context).pop();
                mostrarLista();
            });
          }, child: const Text("Guardar"))
        ],
        );
      } 
    );
  }

  void _eliminarUsuario(String uid) async {
    await eliminarUsuario(uid).then((_) {
      mostrarLista();
    });
  }
  void _actualizarUsuario (String uid, String dni, String nombre)
  async{
    await actualizarUsuario(uid, dni, nombre).then((_){
      mostrarLista();
    });
  }
  void _showEditDialog(String uid, String id, String currentTitle) {
    TextEditingController _titleController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modificar Nombre"),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: " Escribe el nuevo Nombre",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                String newTitle = _titleController.text;
                if (newTitle.isNotEmpty) {
                  _actualizarUsuario(uid, id, newTitle);
                }
                Navigator.of(context).pop();
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
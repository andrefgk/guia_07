// Importa el archivo instancia_bd.dart que contiene funciones relacionadas con la base de datos
import 'package:guia_07/instancia_bd.dart';
// Importa el paquete de Flutter para construir interfaces gráficas
import 'package:flutter/material.dart';
// Importa el paquete de Firebase Core para inicializar Firebase
import 'package:firebase_core/firebase_core.dart';
// Importa las opciones de configuración de Firebase generadas automáticamente
import 'firebase_options.dart';

// Función principal que se ejecuta al iniciar la aplicación
void main() async{
  // Asegura que los widgets estén correctamente inicializados antes de ejecutar código asincrónico
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase con las opciones específicas para la plataforma actual
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ejecuta la aplicación MyApp
  runApp(const MyApp());
}

// Clase principal de la aplicación que extiende StatelessWidget
class MyApp extends StatelessWidget {
  // Constructor constante de MyApp
  const MyApp({super.key});

  // Método que construye la interfaz de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la aplicación
      title: 'Flutter Demo',
      // Tema de la aplicación con esquema de color basado en un color semilla
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Usa Material Design 3
      ),
      // Página principal de la aplicación
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Widget con estado que representa la página principal
class MyHomePage extends StatefulWidget {
  // Constructor que recibe el título como parámetro requerido
  const MyHomePage({super.key, required this.title});
  final String title; // Título de la página

  // Crea el estado asociado a este widget
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Clase que contiene el estado de MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  // Controlador para el campo de texto del DNI
  final TextEditingController _controllerDNI = TextEditingController();
  // Controlador para el campo de texto del nombre
  final TextEditingController _controllerNombre = TextEditingController();

  // Variable que almacenará la lista de usuarios obtenida de Firebase
  late Future<List> listaUsuarios;

  // Método que se ejecuta al inicializar el estado
  @override
  void initState(){
    super.initState();
    // Obtiene la lista de usuarios desde la base de datos
    listaUsuarios = obtenerUsuario();
  }

  // Método que construye la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación
      appBar: AppBar(
        title: Text("Usuarios con Firebase 🔥"),
      ),
      // Cuerpo de la aplicación que muestra la lista de usuarios
      body: FutureBuilder<List>(
        future: listaUsuarios, // Fuente de datos futura
        builder: (context, snapshot){
          // Muestra un indicador de carga mientras se obtienen los datos
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          // Muestra un mensaje de error si ocurre un problema
          }else if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar usuarios"),
            );
          // Si hay datos, muestra la lista de usuarios
          }else if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.length, // Número de elementos
              separatorBuilder: (context, index) => Divider(), // Separador entre elementos
              itemBuilder: (context, index) {
                final usuario = snapshot.data![index]; // Usuario actual
                final dni = usuario['dni']; // DNI del usuario
                final nombre = usuario['nombre']; // Nombre del usuario
                final uid = usuario['uid']; // UID del usuario
                return ListTile(
                  title: Text(nombre), // Muestra el nombre
                  subtitle: Text("DNI: $dni"), // Muestra el DNI
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(uid, dni, nombre),
                      ),
                      //Boton para Eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarUsuario(uid),
                      ),
                    ],
                  ),
                );
              },
            );
          // Si no hay datos, muestra un mensaje
          } else {
            return Center(
              child: Text("No se encontraron Usuarios"),
            );
          }
        },
      ),
      // Botón flotante para agregar un nuevo usuario
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dialogAgregarUsuario(); // Muestra el diálogo para agregar usuario
        },
        child: Icon(Icons.add), // Icono de agregar
      ),
    );
  }

  // Método para actualizar la lista de usuarios
  void mostrarLista(){
    setState(() {
      listaUsuarios = obtenerUsuario(); // Vuelve a obtener la lista
    });
  }

  // Método que muestra el diálogo para agregar un nuevo usuario
  void dialogAgregarUsuario() {
    _controllerDNI.clear();
    _controllerNombre.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Usuario"), // Título del diálogo
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de texto para el DNI
              TextField(controller: _controllerDNI, decoration: const InputDecoration(labelText: "DNI"),),
              // Campo de texto para el nombre
              TextField(controller: _controllerNombre, decoration: const InputDecoration(labelText: "Nombre"),),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Botón para guardar el nuevo usuario
            TextButton(onPressed: () async{
              await agregarUsuario(
                _controllerDNI.text.toString(),
                _controllerNombre.text.toString()).then((_){
                  Navigator.of(context).pop(); // Cierra el diálogo
                  mostrarLista(); // Actualiza la lista
              });
            }, child: const Text("Guardar"))
          ],
        );
      } 
    );
  }

  // Método para eliminar un usuario por su UID
  void _eliminarUsuario(String uid) async {
    await eliminarUsuario(uid).then((_) {
      mostrarLista(); // Actualiza la lista después de eliminar
    });
  }

  // Método para actualizar los datos de un usuario
  void _actualizarUsuario (String uid, String dni, String nombre) async {
    await actualizarUsuario(uid, dni, nombre).then((_){
      mostrarLista(); // Actualiza la lista después de modificar
    });
  }

  // Método que muestra el diálogo para editar el nombre de un usuario
  void _showEditDialog(String uid, String currentDNI, String currentNombre) {
  TextEditingController _dniController = TextEditingController(text: currentDNI);
  TextEditingController _nombreController = TextEditingController(text: currentNombre);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Modificar Usuario"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _dniController,
              decoration: InputDecoration(
                labelText: "Nuevo DNI",
              ),
            ),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: "Nuevo Nombre",
              ),
            ),
          ],
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
              String nuevoDNI = _dniController.text.trim();
              String nuevoNombre = _nombreController.text.trim();
              if (nuevoDNI.isNotEmpty && nuevoNombre.isNotEmpty) {
                _actualizarUsuario(uid, nuevoDNI, nuevoNombre);
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

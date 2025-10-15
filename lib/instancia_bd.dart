// Importa el paquete de Cloud Firestore para acceder a la base de datos de Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
// Crea una instancia de la base de datos Firestore para realizar operaciones
FirebaseFirestore db = FirebaseFirestore.instance;
// Función asincrónica que obtiene la lista de usuarios desde la colección "usuarios"
Future<List> obtenerUsuario() async {
  // Lista vacía donde se almacenarán los usuarios obtenidos
  List usuarios = [];
  try {
    // Referencia a la colección "usuarios" dentro de Firestore
    CollectionReference collectionReferencePeople = db.collection("usuarios");

    // Realiza una consulta para obtener todos los documentos de la colección
    QuerySnapshot queryUsuarios = await collectionReferencePeople.get();

    // Itera sobre cada documento obtenido en la consulta
    queryUsuarios.docs.forEach((documento) {
      // Convierte los datos del documento a un mapa de tipo <String, dynamic>
      Map<String, dynamic> dataConId = documento.data() as Map<String, dynamic>;
      // Verifica si el campo 'dni' existe, si no, asigna 'Sin DNI'
      String dni = dataConId.containsKey('dni') ? dataConId['dni'] : 'Sin DNI';
      // Verifica si el campo 'nombre' existe, si no, asigna 'Sin Nombre'
      String nombre = dataConId.containsKey('nombre') ? dataConId['nombre'] : 'Sin Nombre';
      // Agrega el ID del documento como campo 'uid' en el mapa
      dataConId['uid'] = documento.id;
      // Agrega un nuevo mapa con los datos del usuario a la lista
      usuarios.add({
        'dni': dni,
        'nombre': nombre,
        'uid': documento.id,
      });
    });
  } catch (e) {
    // Captura y muestra cualquier error que ocurra durante la obtención de usuarios
    print("Error al obtener usuarios: $e");
  }
  // Retorna la lista de usuarios obtenida
  return usuarios;
}
// Función asincrónica que agrega un nuevo usuario a la colección "usuarios"
Future<void> agregarUsuario(String dni, String nombre) async {
  // Agrega un nuevo documento con los campos 'dni' y 'nombre' a la colección
  await db.collection("usuarios").add({"dni": dni, "nombre": nombre});
}
// Función asincrónica que actualiza los datos de un usuario existente
Future<void> actualizarUsuario(String uid, String dni, String nombre) async {
  // Reemplaza el contenido del documento con el UID especificado por los nuevos datos
  await db.collection("usuarios").doc(uid).set({"dni": dni, "nombre": nombre});
}
// Función asincrónica que elimina un usuario de la colección "usuarios"
Future<void> eliminarUsuario(String dni) async {
  // Crea una referencia a la colección "usuarios"
  final CollectionReference users = FirebaseFirestore.instance.collection('usuarios');
  try {
    // Elimina el documento cuyo ID coincide con el valor de 'dni'
    await users.doc(dni).delete();
    // Muestra un mensaje de confirmación en consola
    print('Usuario Eliminado correctamente');
  } catch (e) {
    // Muestra un mensaje de error si ocurre algún problema al eliminar
    print('Error eliminando usuario: $e');
  }
}

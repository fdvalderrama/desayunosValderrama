import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/reporte_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmpleadosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desayunos Valderrama - Empleados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmpleadosHomePage(),
    );
  }
}

class EmpleadosHomePage extends StatefulWidget {
  @override
  _EmpleadosHomePageState createState() => _EmpleadosHomePageState();
}

class _EmpleadosHomePageState extends State<EmpleadosHomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> empleados = [];

  @override
  void initState() {
    super.initState();
    fetchEmpleados();
  }

  Future<void> fetchEmpleados() async {
    final response = await supabase
        .from('usuario')
        .select()
        .order('id', ascending: true);
    if (response.length > 0) {
      setState(() {
        empleados = response as List<dynamic>;
      });
    } 
  }

  Future<void> agregarEmpleado(String nombre, String email, String password, String rol) async {
    await supabase
        .from('usuario')
        .insert({
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': rol,
        });

    fetchEmpleados(); // Refrescar la lista de empleados después de la inserción
  }

  Future<void> actualizarEmpleado(int id, String nombre, String email, String password, String rol) async {
    await supabase
        .from('usuario')
        .update({
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': rol,
        })
        .eq('id', id);

    fetchEmpleados(); // Refrescar la lista de empleados después de la actualización
  }

  Future<void> eliminarEmpleado(int id) async {
    await supabase
        .from('usuario')
        .delete()
        .eq('id', id);

    fetchEmpleados(); // Refrescar la lista de empleados después de la eliminación
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 70.0,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text(
                  'Inicio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
              SizedBox(width: 100),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EmpleadosScreen()),
                  );
                },
                child: Text(
                  'Empleados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
              SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportesScreen()),
                        );
                      },
                      child: Text(
                        'Reportes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'Gestión de Empleados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final TextEditingController nombreController = TextEditingController();
                    final TextEditingController emailController = TextEditingController();
                    final TextEditingController passwordController = TextEditingController();
                    final TextEditingController rolController = TextEditingController();
                    return AlertDialog(
                      title: Text('Agregar Empleado'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                            ),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                          TextField(
                            controller: rolController,
                            decoration: InputDecoration(
                              labelText: 'Rol',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            agregarEmpleado(
                              nombreController.text,
                              emailController.text,
                              passwordController.text,
                              rolController.text,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text('Guardar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Agregar Empleado'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: empleados.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Rol')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: empleados
                                .map((empleado) => DataRow(cells: [
                                      DataCell(Text(empleado['id'].toString())),
                                      DataCell(Text(empleado['nombre'])),
                                      DataCell(Text(empleado['email'])),
                                      DataCell(Text(empleado['rol'])),
                                      DataCell(
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    final TextEditingController nombreController = TextEditingController(text: empleado['nombre']);
                                                    final TextEditingController emailController = TextEditingController(text: empleado['email']);
                                                    final TextEditingController passwordController = TextEditingController(text: empleado['password']);
                                                    final TextEditingController rolController = TextEditingController(text: empleado['rol']);
                                                    return AlertDialog(
                                                      title: Text('Actualizar Empleado'),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            controller: nombreController,
                                                            decoration: InputDecoration(
                                                              labelText: 'Nombre',
                                                            ),
                                                          ),
                                                          TextField(
                                                            controller: emailController,
                                                            decoration: InputDecoration(
                                                              labelText: 'Email',
                                                            ),
                                                          ),
                                                          TextField(
                                                            controller: passwordController,
                                                            decoration: InputDecoration(
                                                              labelText: 'Password',
                                                            ),
                                                          ),
                                                          TextField(
                                                            controller: rolController,
                                                            decoration: InputDecoration(
                                                              labelText: 'Rol',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text('Cancelar'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            actualizarEmpleado(
                                                              empleado['id'],
                                                              nombreController.text,
                                                              emailController.text,
                                                              passwordController.text,
                                                              rolController.text,
                                                            );
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text('Guardar'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text('Actualizar'),
                                            ),
                                            SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                eliminarEmpleado(empleado['id']);
                                              },
                                              child: Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

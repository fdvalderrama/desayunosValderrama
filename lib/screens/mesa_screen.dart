import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/pedido_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';


class MesaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desayunos Valderrama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> mesas = [];

  @override
  void initState() {
    super.initState();
    fetchMesas();
  }

  Future<void> fetchMesas() async {
    final response = await supabase
        .from('mesa')
        .select()
        .order('id', ascending: true);
    if (response.length > 0) {
      setState(() {
        mesas = response as List<dynamic>;
      });
    } else {
      print('Error fetching mesas');
    }
  }

  Future<void> asignarMesa(int id, String cliente, int comanda) async {
        await supabase
        .from('mesa')
        .update({
          'cliente': cliente,
          'comanda': comanda,
          'estatus': 'Asignada',
        })
        .eq('id', id);

      fetchMesas(); // Refrescar las mesas después de la actualización

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 70.0, // Ajusta la altura del AppBar según sea necesario
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (Route<dynamic> route) => false,
    );
                },
                child: Text(
                  'Inicio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0, // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),
              SizedBox(width: 100), // Espacio entre los textos
              InkWell(
                onTap: () {
                  // Acción para 'Mesas'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MesaScreen()),
                  );
                },
                child: Text(
                  'Mesas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0 // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),

              SizedBox(width: 100), // Espacio entre los textos
              InkWell(
                onTap: () {
                  // Acción para 'Ordenes'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PedidoScreen()),
                  );
                },
                child: Text(
                  'Ordenes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0 // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),
              SizedBox(width: 100), // Espacio entre los textos
              InkWell(
                onTap: () {
                  // Acción para 'Caja'
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Caja')),
                  );
                },
                child: Text(
                  'Caja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0 // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false, // Esto oculta el botón de atrás
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center, // Cambiado a center para centrar la columna
    children: [
      Center( // Añadido Center para centrar el título
        child: Text(
          'Asignar mesa',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(height: 16),
      Expanded(
        child: mesas.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Center( // Añadido Center para centrar la tabla
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Número')),
                        DataColumn(label: Text('Estatus')),
                        DataColumn(label: Text('Cliente')),
                        DataColumn(label: Text('N. Comanda')),
                        DataColumn(label: Text('Asignar')),
                      ],
                      rows: mesas
                          .map((mesa) => DataRow(cells: [
                                DataCell(Text(mesa['numero'].toString())),
                                DataCell(Text(mesa['estatus'].toString())),
                                DataCell(Text(mesa['cliente'] ?? '')),
                                DataCell(Text(mesa['comanda']?.toString() ?? '')),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          final TextEditingController clienteController = TextEditingController();
                                          final int comanda = Random().nextInt(900000) + 100000; // Generar número aleatorio de 6 dígitos
                                          return AlertDialog(
                                            title: Text('Asignar'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('ID de Mesa: ${mesa['id']}'),
                                                SizedBox(height: 8),
                                                Text('Número de Comanda: $comanda'),
                                                TextField(
                                                  controller: clienteController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Nombre del Cliente',
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
                                                  asignarMesa(mesa['id'], clienteController.text, comanda);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Guardar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text('Asignar'),
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
import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MesaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desayunos Valderrama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
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

    setState(() {
      mesas.clear();
    });

    fetchMesas();
  }

  Future<int> obtenerUltimoIdPedido() async {
  final response = await supabase
      .from('pedido')
      .select('id')
      .order('id', ascending: false)
      .limit(1);
  
  if (response.length > 0) {
    return response[0]['id'] + 1;
  } else {
    return 1; // En caso de que no haya pedidos, empieza con el ID 1
  }
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
                  Navigator.push(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MesaScreen()),
                  );
                },
                child: Text(
                  'Mesas',
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
                'Asignar mesa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Center(
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
                                    onPressed: mesa['estatus'] == 'Disponible'
                                    ? () async {
                                        final int comanda = await obtenerUltimoIdPedido();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            final TextEditingController clienteController = TextEditingController();
                                            return AlertDialog(
                                              title: Text('Asignar'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: clienteController,
                                                    decoration: InputDecoration(
                                                      labelText: 'Nombre del Cliente',
                                                    ),
                                                  ),
                                                  SizedBox(height: 28),
                                                  Text('Número de Comanda: $comanda'),
                                                  SizedBox(height: 8),
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
                                      }
                                    : null,

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

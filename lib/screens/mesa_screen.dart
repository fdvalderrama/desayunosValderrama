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
        .select();
    if (response.length > 0) {
      setState(() {
        mesas = response as List<dynamic>;
      });
    } else {
      print('Error fetching mesas: ${response.error!.message}');
    }
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
                  // Acción para 'Home'
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Inicio')),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mesas')),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ordenes')),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asignar mesa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: mesas.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Número')),
                        DataColumn(label: Text('Estatus')),
                      ],
                      rows: mesas
                          .map((mesa) => DataRow(cells: [
                                DataCell(Text(mesa['id'].toString())),
                                DataCell(Text(mesa['numero'].toString())),
                                DataCell(Text(mesa['estatus'].toString())),
                              ]))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
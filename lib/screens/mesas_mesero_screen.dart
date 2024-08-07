import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/pedido_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeseroMesasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desayunos Valderrama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MeseroHomePage(),
    );
  }
}

class MeseroHomePage extends StatefulWidget {
  @override
  _MeseroHomePageState createState() => _MeseroHomePageState();
}

class _MeseroHomePageState extends State<MeseroHomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> mesas = [];

  @override
  void initState() {
    super.initState();
    fetchMesas();
  }

  Future<void> fetchMesas() async {
    final userId = await _getUserId();
    if (userId == null) {
      print('Error: User ID not found in SharedPreferences');
      return;
    }

    final response = await supabase
        .from('mesasAsignadas')
        .select('mesa(id, numero, estatus, cliente)')
        .eq('idUsuario', userId)
        .order('id', ascending: true);

    if (response.length > 0) {
      setState(() {
        mesas = response.map((mesaAsignada) => mesaAsignada['mesa']).toList();
      });
    } else {
      print('Error fetching mesas');
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
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
                  // Acción para 'Mesas'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MeseroMesasScreen()),
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
              SizedBox(width: 100),
              InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PedidoScreen()),
                        );
                      },
                      child: Text(
                        'Pedidos',
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
                'Mesas Asignadas',
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
                        child: Center(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Número')),
                              DataColumn(label: Text('Estatus')),
                              DataColumn(label: Text('Cliente')),
                            ],
                            rows: mesas
                                .map((mesa) => DataRow(cells: [
                                      DataCell(Text(mesa['numero'].toString())),
                                      DataCell(Text(mesa['estatus'].toString())),
                                      DataCell(Text(mesa['cliente'] ?? '')),
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

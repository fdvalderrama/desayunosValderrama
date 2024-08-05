import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CocinaScreen extends StatefulWidget {
  @override
  _CocinaScreenState createState() => _CocinaScreenState();
}

class _CocinaScreenState extends State<CocinaScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> pedidos = [];
  List<dynamic> detallePedido = [];

  @override
  void initState() {
    super.initState();
    fetchPedidos();
  }

  Future<void> fetchPedidos() async {
    final response = await supabase
        .from('pedido')
        .select('*, mesa(numero, comanda)')
        .eq('estatus', 'Aceptado');

    setState(() {
      pedidos = response as List<dynamic>;
    });
  }

  Future<void> fetchDetallePedido(int idPedido) async {
    final response = await supabase
        .from('detallePedido')
        .select('*, producto(nombre)')
        .eq('idPedido', idPedido);

    setState(() {
      detallePedido = response as List<dynamic>;
    });
  }

  Future<void> finalizarPedido(int idPedido, int idMesa) async {
    await supabase
        .from('pedido')
        .update({'estatus': 'Entregado'}).eq('id', idPedido);

    await supabase
        .from('mesa')
        .update({'estatus': 'Comiendo'}).eq('id', idMesa);

    fetchPedidos();
    setState(() {
      detallePedido.clear();
    });
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text(
                  'Inicio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        14.0, // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),
              SizedBox(width: 100), // Espacio entre los textos
              InkWell(
                onTap: () {
                  // Acción para 'Ordenes'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CocinaScreen()),
                  );
                },
                child: Text(
                  'Cocina',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          14.0 // Ajusta el tamaño del texto según sea necesario
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    // Añadido Center para centrar el título
                    child: Text(
                      'Pedido',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID Pedido')),
                            DataColumn(label: Text('Número de Comanda')),
                            DataColumn(label: Text('Estatus')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: pedidos.map((pedido) {
                            return DataRow(
                              cells: [
                                DataCell(Text(pedido['id'].toString())),
                                DataCell(
                                    Text(pedido['mesa']['comanda'].toString())),
                                DataCell(Text(pedido['estatus'].toString())),
                                DataCell(Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        fetchDetallePedido(pedido['id']);
                                      },
                                      child: Text('Ver Detalles'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        finalizarPedido(
                                            pedido['id'], pedido['idMesa']);
                                      },
                                      child: Text('Finalizar'),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    // Añadido Center para centrar el título
                    child: Text(
                      'Detalle pedido',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: detallePedido.isEmpty
                        ? Center(
                            child: Text(
                                'Selecciona un pedido para ver los detalles'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID Detalle')),
                                  DataColumn(label: Text('Cantidad')),
                                  DataColumn(
                                      label: Text('Nombre del Producto')),
                                  DataColumn(
                                      label: Text('Ingredientes Opcionales')),
                                ],
                                rows: detallePedido.map((detalle) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Container(
                                        width: 80,
                                        child: Text(detalle['id'].toString()),
                                      )),
                                      DataCell(Container(
                                        width: 80,
                                        child: Text(
                                            detalle['cantidad'].toString()),
                                      )),
                                      DataCell(Container(
                                        width: 150,
                                        child: Text(detalle['producto']
                                                ['nombre']
                                            .toString()),
                                      )),
                                      DataCell(Container(
                                        width: 200,
                                        child: Text(
                                            detalle['ingredientesOpcionales']
                                                .toString()),
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

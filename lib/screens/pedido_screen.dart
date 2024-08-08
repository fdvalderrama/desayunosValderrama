import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/mesas_mesero_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PedidoScreen extends StatefulWidget {
  @override
  _PedidoScreenState createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> productos = [];
  List<dynamic> ingredientesOpcionales = [];
  List<Map<String, dynamic>> pedido = [];
  List<dynamic> mesas = [];
  int? selectedMesa;

  @override
  void initState() {
    super.initState();
    fetchProductos();
    fetchMesas();
  }

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<void> fetchProductos() async {
    final response =
        await supabase.from('producto').select().order('id', ascending: true);
    setState(() {
      productos = response as List<dynamic>;
    });
  }

  Future<void> fetchMesas() async {
    final userId = await _getUserId();
    if (userId == null) {
      print('Error: User ID not found in SharedPreferences');
      return;
    }

    final response = await supabase
        .from('mesasAsignadas')
        .select('mesa!inner(id, numero, comanda, cliente)')
        .eq('idUsuario', userId)
        .eq('mesa.estatus', 'Asignada')
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

  Future<void> fetchIngredientesOpcionales(int idProducto) async {
    final response = await supabase
        .from('ingredienteOpcional')
        .select()
        .eq('idProducto', idProducto);
    setState(() {
      ingredientesOpcionales = response as List<dynamic>;
    });
  }

  void agregarProductoAlPedido(Map<String, dynamic> producto, int cantidad,
      String? ingredienteOpcional) {
    setState(() {
      pedido.add({
        'producto': producto,
        'cantidad': cantidad,
        'ingredienteOpcional': ingredienteOpcional,
      });
    });
  }

  Future<void> generarPedido() async {
    if (selectedMesa == null) return;

    final fechaActual = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final mesaResponse = await supabase
        .from('mesa')
        .select()
        .eq('id', selectedMesa)
        .single();

    final comanda = mesaResponse['comanda'];
    final cliente = mesaResponse['cliente'];

    await supabase.from('pedido').insert({
      'estatus': 'En cocina',
      'idMesa': selectedMesa,
      'fecha': fechaActual,
      'comanda': comanda,
      'cliente': cliente,
    });

    final latestPedidoResponse = await supabase
        .from('pedido')
        .select()
        .order('id', ascending: false)
        .limit(1);

    final idPedido = latestPedidoResponse[0]['id'];

    for (var item in pedido) {
      var cantidadItem = item['cantidad'];
      var idProductoItem = item['producto']['id'];
      var ingredienteOpcionalItem = item['ingredienteOpcional'];
      await supabase.from('detallePedido').insert({
        'cantidad': cantidadItem,
        'idPedido': idPedido,
        'idProducto': idProductoItem,
        'ingredienteOpcional': ingredienteOpcionalItem,
      });
    }

    await supabase
        .from('mesa')
        .update({'estatus': 'Orden tomada'}).eq('id', selectedMesa);

    setState(() {
      pedido.clear();
      selectedMesa = null;
    });

    fetchMesas();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido generado con éxito')),
    );
  }

  void mostrarFormularioAgregar(
      BuildContext context, Map<String, dynamic> producto) async {
    await fetchIngredientesOpcionales(producto['id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController cantidadController = TextEditingController();
        String? selectedIngredienteOpcional;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Agregar platillo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cantidadController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (ingredientesOpcionales.isNotEmpty)
                      Column(
                        children: [
                          Text('Agregar ingrediente opcional'),
                          DropdownButton<String>(
                            hint: Text('Selecciona el ingrediente'),
                            value: selectedIngredienteOpcional,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedIngredienteOpcional = newValue;
                              });
                            },
                            items: ingredientesOpcionales
                                .map<DropdownMenuItem<String>>((i) {
                              return DropdownMenuItem<String>(
                                value: i['nombre'],
                                child: Text(i['nombre']),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
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
                    int cantidad = int.tryParse(cantidadController.text) ?? 1;
                    agregarProductoAlPedido(
                        producto, cantidad, selectedIngredienteOpcional);
                    Navigator.of(context).pop();
                  },
                  child: Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
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
                  'Pedido',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
              SizedBox(width: 100),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Productos',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: productos.isEmpty
                                ? Center(child: CircularProgressIndicator())
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: constraints.maxWidth,
                                            ),
                                            child: DataTable(
                                              columns: const [
                                                DataColumn(
                                                  label: Center(
                                                    child: Text('Producto'),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Center(
                                                    child: Text('Descripción'),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Center(
                                                    child: Text('Precio'),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Center(
                                                    child: Text('Agregar'),
                                                  ),
                                                ),
                                              ],
                                              rows: productos.map((producto) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Center(
                                                        child: Container(
                                                          width: 100,
                                                          child: Text(
                                                            producto['nombre']
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Center(
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            maxWidth:
                                                                constraints
                                                                        .maxWidth *
                                                                    0.4,
                                                          ),
                                                          child: Text(
                                                            producto[
                                                                    'descripcion']
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Center(
                                                        child: Text(
                                                          producto['precio']
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Center(
                                                        child: ElevatedButton(
                                                          onPressed: () =>
                                                              mostrarFormularioAgregar(
                                                                  context,
                                                                  producto),
                                                          child:
                                                              Text('Agregar'),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Pedido',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                    label: Center(
                                      child: Text('Producto'),
                                    )),
                                DataColumn(
                                    label: Center(
                                      child: Text('Cantidad'),
                                    )),
                                DataColumn(
                                    label: Center(
                                      child: Text('Ingrediente Opcional'),
                                    )),
                              ],
                              rows: pedido
                                  .map((item) => DataRow(cells: [
                                        DataCell(Center(
                                          child: Text(
                                              item['producto']['nombre'],
                                              textAlign: TextAlign.center),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                              item['cantidad'].toString(),
                                              textAlign: TextAlign.center),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                              item['ingredienteOpcional'] ??
                                                  '',
                                              textAlign: TextAlign.center),
                                        )),
                                      ]))
                                  .toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Seleccionar Mesa'),
                                  content: DropdownButton<int>(
                                    hint: Text('Selecciona la mesa'),
                                    value: selectedMesa,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedMesa = newValue;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    items: mesas
                                        .map<DropdownMenuItem<int>>((mesa) {
                                      return DropdownMenuItem<int>(
                                        value: mesa['id'],
                                        child: Text('Mesa ${mesa['numero']}'),
                                      );
                                    }).toList(),
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
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Seleccionar'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (selectedMesa != null) {
                              await generarPedido();
                            }
                          },
                          child: Text('Generar Pedido'),
                        ),
                      ],
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

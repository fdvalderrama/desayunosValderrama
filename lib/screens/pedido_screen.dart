import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/mesas_mesero_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        .select('mesa(id, numero)')
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
      List<String> ingredientesOpcionales) {
    setState(() {
      pedido.add({
        'producto': producto,
        'cantidad': cantidad,
        'ingredientesOpcionales': ingredientesOpcionales,
      });
    });
  }

  Future<void> generarPedido() async {
    if (selectedMesa == null) return;

    await supabase.from('pedido').insert({
      'estatus': 'En revisión',
      'idMesa': selectedMesa,
    });

    final latestPedidoResponse = await supabase
        .from('pedido')
        .select()
        .order('id',
            ascending:
                false) // Asegúrate de usar el campo correcto para ordenar
        .limit(1);

    final idPedido = latestPedidoResponse[0]['id'];

    for (var item in pedido) {
      var cantidadItem = item['cantidad'];
      var idProductoItem = item['producto']['id'];
      var ingredienteOpcionalItem = item['ingredientesOpcionales'].join(', ');
      await supabase.from('detallePedido').insert({
        'cantidad': cantidadItem,
        'idPedido': idPedido,
        'idProducto': idProductoItem,
        'ingredientesOpcionales': ingredienteOpcionalItem,
      });
    }

    await supabase
        .from('mesa')
        .update({'estatus': 'Orden tomada'}).eq('id', selectedMesa);

    setState(() {
      pedido.clear();
    });

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
        final TextEditingController cantidadController =
            TextEditingController();
        List<String> selectedIngredientesOpcionales = [];
        String? selectedDropdownIngrediente;

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
                          Text('Agregar ingredientes opcionales'),
                          if (ingredientesOpcionales
                              .any((i) => i['tipo'] != 'Agrega'))
                            DropdownButton<String>(
                              hint: Text('Selecciona el ingrediente'),
                              value: selectedDropdownIngrediente,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDropdownIngrediente = newValue;
                                  if (newValue != null) {
                                    selectedIngredientesOpcionales = [newValue];
                                  }
                                });
                              },
                              items: ingredientesOpcionales
                                  .where((i) => i['tipo'] != 'Agrega')
                                  .map<DropdownMenuItem<String>>((i) {
                                return DropdownMenuItem<String>(
                                  value: i['nombre'],
                                  child: Text(i['nombre']),
                                );
                              }).toList(),
                            ),
                          ...ingredientesOpcionales
                              .where((i) => i['tipo'] == 'Agrega')
                              .map<Widget>((ingrediente) {
                            return CheckboxListTile(
                              title: Text(ingrediente['nombre']),
                              value: selectedIngredientesOpcionales
                                  .contains(ingrediente['nombre']),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedIngredientesOpcionales
                                        .add(ingrediente['nombre']);
                                  } else {
                                    selectedIngredientesOpcionales
                                        .remove(ingrediente['nombre']);
                                  }
                                });
                              },
                            );
                          }).toList(),
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
                        producto, cantidad, selectedIngredientesOpcionales);
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
                  // Acción para 'Mesas'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeseroMesasScreen()),
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
                  // Acción para 'Ordenes'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PedidoScreen()),
                  );
                },
                child: Text(
                  'Pedido',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          14.0 // Ajusta el tamaño del texto según sea necesario
                      ),
                ),
              ),
              SizedBox(width: 100), // Espacio entre los textos
            ],
          ),
        ),
        automaticallyImplyLeading: false, // Esto oculta el botón de atrás
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Pedido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: productos.isEmpty
                              ? Center(child: CircularProgressIndicator())
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(
                                          label: Text('Producto',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Descripción',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Precio',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Agregar',
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                      rows: productos.map((producto) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Container(
                                                width:
                                                    100, // Ajusta el ancho según sea necesario
                                                child: Text(
                                                  producto['nombre'].toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                width:
                                                    150, // Ajusta el ancho según sea necesario
                                                child: Text(
                                                  producto['descripcion']
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  softWrap:
                                                      true, // Permite el ajuste de texto
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                producto['precio'].toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            DataCell(
                                              ElevatedButton(
                                                onPressed: () =>
                                                    mostrarFormularioAgregar(
                                                        context, producto),
                                                child: Text('Agregar'),
                                              ),
                                            ),
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
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text('Producto',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Cantidad',
                                      textAlign: TextAlign.center)),
                              DataColumn(
                                  label: Text('Ingredientes Opcionales',
                                      textAlign: TextAlign.center)),
                            ],
                            rows: pedido
                                .map((item) => DataRow(cells: [
                                      DataCell(Text(item['producto']['nombre'],
                                          textAlign: TextAlign.center)),
                                      DataCell(Text(item['cantidad'].toString(),
                                          textAlign: TextAlign.center)),
                                      DataCell(Text(
                                          item['ingredientesOpcionales']
                                              .join(', '),
                                          textAlign: TextAlign.center)),
                                    ]))
                                .toList(),
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

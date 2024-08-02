import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:desayunos_valderrama/screens/mesa_screen.dart';
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

  Future<void> fetchProductos() async {
    final response = await supabase.from('producto').select().order('id', ascending: true);
    setState(() {
      productos = response as List<dynamic>;
    });
  }

  Future<void> fetchMesas() async {
    final response = await supabase.from('mesa').select('id, numero').order('numero', ascending: true);
    setState(() {
      mesas = response as List<dynamic>;
    });
  }

  Future<void> fetchIngredientesOpcionales(int idProducto) async {
    final response = await supabase.from('ingredienteOpcional').select().eq('idProducto', idProducto);
    setState(() {
      ingredientesOpcionales = response as List<dynamic>;
    });
  }

  void agregarProductoAlPedido(Map<String, dynamic> producto, int cantidad, List<String> ingredientesOpcionales) {
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

    final pedidoResponse = await supabase.from('pedido').insert({
      'estatus': 'En espera',
      'idMesa': selectedMesa,
    });

    final idPedido = pedidoResponse.data[0]['id'];

    for (var item in pedido) {
      await supabase.from('detallePedido').insert({
        'cantidad': item['cantidad'],
        'idPedido': idPedido,
        'idProducto': item['producto']['id'],
        'ingredientesOpcionales': item['ingredientesOpcionales'].join(', '),
      });
    }

    setState(() {
      pedido.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido generado con éxito')),
    );
  }

  void mostrarFormularioAgregar(BuildContext context, Map<String, dynamic> producto) async {
    await fetchIngredientesOpcionales(producto['id']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController cantidadController = TextEditingController();
        List<String> selectedIngredientesOpcionales = [];

        return AlertDialog(
          title: Text('Agregar platillo'),
          content: Column(
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
                    ...ingredientesOpcionales
                        .map<Widget>((ingrediente) {
                          if (ingrediente['tipo'] == 'Agrega') {
                            return CheckboxListTile(
                              title: Text(ingrediente['nombre']),
                              value: selectedIngredientesOpcionales.contains(ingrediente['nombre']),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedIngredientesOpcionales.add(ingrediente['nombre']);
                                  } else {
                                    selectedIngredientesOpcionales.remove(ingrediente['nombre']);
                                  }
                                });
                              },
                            );
                          } else {
                            return DropdownButton<String>(
                              hint: Text('Selecciona el ingrediente'),
                              value: selectedIngredientesOpcionales.isEmpty ? null : selectedIngredientesOpcionales.first,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedIngredientesOpcionales = [newValue!];
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
                            );
                          }
                        }).toList(),
                  ],
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
                int cantidad = int.tryParse(cantidadController.text) ?? 1;
                agregarProductoAlPedido(producto, cantidad, selectedIngredientesOpcionales);
                Navigator.of(context).pop();
              },
              child: Text('Agregar'),
            ),
          ],
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
                    fontSize: 14.0, // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),
              SizedBox(width: 100), // Espacio entre los textos
              InkWell(
                onTap: () {
                  // Acción para 'Mesas'
                  Navigator.push(
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
                                  DataColumn(label: Text('Producto', textAlign: TextAlign.center)),
                                  DataColumn(label: SizedBox(width: 150, child: Text('Descripción', textAlign: TextAlign.center))),
                                  DataColumn(label: Text('Precio', textAlign: TextAlign.center)),
                                  DataColumn(label: Text('Agregar', textAlign: TextAlign.center)),
                                ],
                                rows: productos
                                    .map((producto) => DataRow(cells: [
                                          DataCell(Text(producto['nombre'].toString(), textAlign: TextAlign.center)),
                                          DataCell(SizedBox(width: 150, child: Text(producto['descripcion'].toString(), textAlign: TextAlign.center))),
                                          DataCell(Text(producto['precio'].toString(), textAlign: TextAlign.center)),
                                          DataCell(
                                            ElevatedButton(
                                              onPressed: () => mostrarFormularioAgregar(context, producto),
                                              child: Text('Agregar'),
                                            ),
                                          ),
                                        ]))
                                    .toList(),
                              ),
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
                                  })
                                  .toList(),
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
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Producto', textAlign: TextAlign.center)),
                        DataColumn(label: Text('Cantidad', textAlign: TextAlign.center)),
                        DataColumn(label: Text('Ingredientes Opcionales', textAlign: TextAlign.center)),
                      ],
                      rows: pedido
                          .map((item) => DataRow(cells: [
                                DataCell(Text(item['producto']['nombre'], textAlign: TextAlign.center)),
                                DataCell(Text(item['cantidad'].toString(), textAlign: TextAlign.center)),
                                DataCell(Text(item['ingredientesOpcionales'].join(', '), textAlign: TextAlign.center)),
                              ]))
                          .toList(),
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
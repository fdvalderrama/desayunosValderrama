import 'package:desayunos_valderrama/screens/empleados_screen.dart';
import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String? selectedPeriod;
  DateTime? startDate;
  DateTime? endDate;
  List<dynamic> reportData = [];
  double totalSales = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> generateReport() async {
    setState(() {
      // Limpiar datos de la tabla y total antes de generar el nuevo reporte
      reportData = [];
      totalSales = 0.0;
    });

    if (startDate != null && endDate != null) {
      var response;
      if (selectedPeriod == 'Día') {
        // Filtrar pedidos solo para el día específico
        response = await supabase
            .from('pedido')
            .select('id')
            .eq('fecha', startDate!.toIso8601String().split('T')[0]);
      } else {
        // Filtrar pedidos para el período seleccionado
        response = await supabase
            .from('pedido')
            .select('id')
            .gte('fecha', startDate!.toIso8601String())
            .lte('fecha', endDate!.toIso8601String());
      }

      final List<int> pedidoIds = [];

      if (response.length > 0) {
        for (var pedido in response) {
          pedidoIds.add(pedido['id']);
        }
        final detalleResponse = await supabase
            .from('detallePedido')
            .select('idProducto, cantidad')
            .in_('idPedido', pedidoIds);

        Map<int, int> productQuantities = {};
        for (var item in detalleResponse) {
          int idProducto = item['idProducto'];
          int cantidad = item['cantidad'];
          if (productQuantities.containsKey(idProducto)) {
            productQuantities[idProducto] =
                productQuantities[idProducto]! + cantidad;
          } else {
            productQuantities[idProducto] = cantidad;
          }
        }

        final productResponse = await supabase
            .from('producto')
            .select('id, nombre, precio')
            .in_('id', productQuantities.keys.toList());

        setState(() {
          reportData = productResponse.map((product) {
            int id = product['id'];
            String nombre = product['nombre'];
            double precio = product['precio'];
            int cantidad = productQuantities[id]!;
            double subtotal = precio * cantidad;
            totalSales += subtotal;
            return {
              'Producto': nombre,
              'Precio': precio,
              'Cantidad': cantidad,
              'Subtotal': subtotal,
            };
          }).toList();
        });
      }
    }
  }

  void updateEndDate() {
    if (startDate != null) {
      if (selectedPeriod == 'Día') {
        endDate = startDate;
      } else if (selectedPeriod == 'Semana') {
        endDate = startDate!.add(Duration(days: 6));
      } else if (selectedPeriod == 'Mes') {
        endDate =
            DateTime(startDate!.year, startDate!.month + 1, startDate!.day);
      }
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ReportesScreen()),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Reportes de Ventas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButton<String>(
                hint: Text("Selecciona el periodo del reporte"),
                value: selectedPeriod,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPeriod = newValue;
                    updateEndDate();
                  });
                },
                items: ['Día', 'Semana', 'Mes']
                    .map<DropdownMenuItem<String>>((String period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Fecha Inicio',
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            startDate = pickedDate;
                            updateEndDate();
                          });
                        }
                      },
                      controller: TextEditingController(
                        text: startDate != null
                            ? "${startDate!.toLocal()}".split(' ')[0]
                            : '',
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Fecha Fin',
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: endDate != null
                            ? "${endDate!.toLocal()}".split(' ')[0]
                            : '',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: generateReport,
                  child: Text('Generar Reporte'),
                ),
              ),
              SizedBox(height: 20.0),
              if (reportData.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Reporte de ventas del ${selectedPeriod?.toLowerCase() ?? ''}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Producto')),
                            DataColumn(label: Text('Precio')),
                            DataColumn(label: Text('Cantidad')),
                            DataColumn(label: Text('Subtotal')),
                          ],
                          rows: reportData.map((data) {
                            return DataRow(
                              cells: [
                                DataCell(Text(data['Producto'])),
                                DataCell(Text(data['Precio'].toString())),
                                DataCell(Text(data['Cantidad'].toString())),
                                DataCell(Text(data['Subtotal'].toString())),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Ventas Totales: \$${totalSales.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

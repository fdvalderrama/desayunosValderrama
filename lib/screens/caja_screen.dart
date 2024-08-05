import 'package:desayunos_valderrama/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CajaScreen extends StatefulWidget {
  @override
  _CajaScreenState createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> mesas = [];
  List<dynamic> detallePedido = [];
  int? selectedMesaId;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    fetchMesas();
  }

  Future<void> fetchMesas() async {
    final response =
        await supabase.from('mesa').select('*').order('id', ascending: true);

    setState(() {
      mesas = response as List<dynamic>;
    });
  }

  Future<void> fetchDetallePedido(int idMesa) async {
    final pedidoResponse = await supabase
        .from('pedido')
        .select('*')
        .eq('idMesa', idMesa)
        .eq('estatus', 'Entregado')
        .single();

    if (pedidoResponse != null) {
      final int idPedido = pedidoResponse['id'];
      final detalleResponse = await supabase
          .from('detallePedido')
          .select('*, producto(nombre, precio)')
          .eq('idPedido', idPedido);

      setState(() {
        detallePedido = detalleResponse as List<dynamic>;
        calculateTotal();
      });
    }
  }

  void calculateTotal() {
    total = detallePedido.fold(0.0, (sum, item) {
      final double price = item['producto']['precio'];
      final int quantity = item['cantidad'];
      return sum + (price * quantity);
    });
  }

  void pagar() async {
    if (selectedMesaId != null) {
      final pedidoResponse = await supabase
          .from('pedido')
          .select('*')
          .eq('idMesa', selectedMesaId)
          .eq('estatus', 'Entregado')
          .single();

      if (pedidoResponse.length > 0) {
        final int idPedido = pedidoResponse['id'];
        await supabase
            .from('pedido')
            .update({'estatus': 'Pagado'}).eq('id', idPedido);

        await supabase
            .from('mesa')
            .update({'estatus': 'Por limpiar'}).eq('id', selectedMesaId);

        setState(() {
          detallePedido.clear();
          total = 0.0;
          selectedMesaId = null;
        });

        fetchMesas();
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
                    MaterialPageRoute(builder: (context) => CajaScreen()),
                  );
                },
                child: Text(
                  'Caja',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Caja',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            DropdownButton<int>(
              hint: Text("Selecciona una mesa"),
              value: selectedMesaId,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMesaId = newValue;
                  if (newValue != null) {
                    fetchDetallePedido(newValue);
                  }
                });
              },
              items: mesas.map<DropdownMenuItem<int>>((dynamic mesa) {
                return DropdownMenuItem<int>(
                  value: mesa['id'],
                  child: Text(mesa['numero'].toString()),
                );
              }).toList(),
            ),
            Expanded(
              child: detallePedido.isEmpty
                  ? Center(
                      child: Text('Selecciona una mesa para ver los productos'))
                  : ListView.builder(
                      itemCount: detallePedido.length,
                      itemBuilder: (context, index) {
                        final item = detallePedido[index];
                        return ListTile(
                          title: Text(item['producto']['nombre']),
                          subtitle: Text('Cantidad: ${item['cantidad']}'),
                          trailing: Text(
                              '\$${(item['producto']['precio'] * item['cantidad']).toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: pagar,
                child: Text('Pagar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

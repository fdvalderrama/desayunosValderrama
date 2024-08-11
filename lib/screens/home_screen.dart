
import 'package:desayunos_valderrama/screens/caja_screen.dart';
import 'package:desayunos_valderrama/screens/cocina_screen.dart';
import 'package:desayunos_valderrama/screens/corredor_screen.dart';
import 'package:desayunos_valderrama/screens/empleados_screen.dart';
import 'package:desayunos_valderrama/screens/mesa_screen.dart';
import 'package:desayunos_valderrama/screens/mesas_mesero_screen.dart';
import 'package:desayunos_valderrama/screens/pedido_screen.dart';
import 'package:desayunos_valderrama/screens/reporte_screen.dart';
import 'package:desayunos_valderrama/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 70.0,
        title: Center(
          child: FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final userRole = snapshot.data;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 30),
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
                  if (userRole == 'Host' || userRole == 'Admin') ...[
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MesaScreen()),
                        );
                      },
                      child: Text(
                        'Host',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                  if (userRole == 'Mesero' || userRole == 'Admin') ...[
                    SizedBox(width: 100), // Espacio entre los textos
                    InkWell(
                      onTap: () {
                        Navigator.push(
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
                  ],
                  if (userRole == 'Mesero' || userRole == 'Admin') ...[
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PedidoScreen()),
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
                  if (userRole == 'Cocina' || userRole == 'Admin') ...[
                    SizedBox(width: 100), // Espacio entre los textos
                    InkWell(
                      onTap: () {
                        // Acción para 'Ordenes'
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CocinaScreen()),
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
                  if (userRole == 'Caja' || userRole == 'Admin') ...[
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
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
                  if (userRole == 'Corredor' || userRole == 'Admin') ...[
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CorredorScreen()),
                        );
                      },
                      child: Text(
                        'Corredor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                  if (userRole == 'Admin') ...[
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EmpleadosScreen()),
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
                  ],
                  if (userRole == 'Admin') ...[
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportesScreen()),
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
                  Spacer(),
                  InkWell(
                    onTap: () => _logout(context),
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                ],
              );
            },
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Image.asset('assets/logo.png'),
            ),
          ),
        ],
      ),
    );
  }
}

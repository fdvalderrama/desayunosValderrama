import 'package:desayunos_valderrama/screens/mesa_screen.dart';
import 'package:desayunos_valderrama/screens/pedido_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
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


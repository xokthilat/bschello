import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Web3Client ethClient;

  @override
  void initState() {
    var apiUrl = "https://data-seed-prebsc-1-s1.binance.org:8545/";
    var httpClient = Client();
    ethClient = Web3Client(apiUrl, httpClient);
    super.initState();
  }

  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x2B53776921b30606aED25C66d88141502aea67e1";
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "hello"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<String> query() async {
    final contract = await loadContract();
    final ethFunction = contract.function("message");
    final data = await ethClient
        .call(contract: contract, function: ethFunction, params: []);
    return data[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: query(),
              builder: (context, AsyncSnapshot<String> snap) {
                if (snap.hasData) {
                  return Text(snap.data!);
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

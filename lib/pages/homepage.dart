import 'dart:convert';
import 'dart:developer';

import 'package:crypto_wallet_app/model/model.dart';
import 'package:crypto_wallet_app/widgets/coin.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Box? box;
  List data = [];
  Future openBox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    box = await Hive.openBox('data');
  }

  Future<bool> getAllData() async {
    await openBox();
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true';

    try {
      var response = await http.get(Uri.parse(url));
      var decode = jsonDecode(response.body);
      await putData(decode);
    } catch (socketException) {
      log('NO internet');
    }

    var myMap = box!.toMap().values.toList();
    if (myMap.isEmpty) {
      data.add('empty');
    } else {
      data = myMap.map((e) => CoinModel.fromJson(e)).toList();
    }
    return Future.value(true);
  }

  Future putData(data) async {
    await box!.clear();
    for (var d in data) {
      box!.add(d);
    }
  }

  // @override
  // void initState() {
  //   getcoinMarket();
  //   super.initState();
  // }

  // List? coinMarket = [];
  // bool isRefreshing = true;
  // String? errorMessage;

  // Future<List<CoinModel>?> getcoinMarket() async {
  //   const url =
  //       'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true';

  //   setState(() {
  //     isRefreshing = true;
  //     errorMessage = null;
  //   });
  //   var response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Accept": 'application/json',
  //     },
  //   );
  //   setState(() {
  //     isRefreshing = false;
  //   });
  //   if (response.statusCode == 200) {
  //     final List<dynamic> jsonList = jsonDecode(response.body);
  //     final List<CoinModel> coinList = jsonList
  //         .map((json) => CoinModel.fromJson(json as Map<String, dynamic>))
  //         .toList();

  //     setState(() {
  //       coinMarket = coinList;
  //     });
  //   } else if (response.statusCode == 429) {
  //     // 2. Set the custom error message for 429
  //     final retryAfter = response.headers['retry-after'];
  //     String waitTime = retryAfter != null && int.tryParse(retryAfter) != null
  //         ? ' in $retryAfter seconds'
  //         : '';

  //     setState(() {
  //       errorMessage =
  //           'Rate limit exceeded. You\'ve made too many requests. Please try again$waitTime.';
  //       log('Rate limit error: ${errorMessage!}');
  //     });
  //   } else {
  //     // Handle other non-200 status codes
  //     setState(() {
  //       errorMessage = 'Failed to load data (Status: ${response.statusCode}).';
  //     });
  //     log(response.statusCode.toString());
  //   }
  //   return null; // Return value is not actually used here
  // }

  Widget _homeIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),

      child: IconButton(onPressed: () {}, icon: Icon(icon, size: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Widget content;

    // if (isRefreshing == true) {
    //   content = Center(
    //     child: CircularProgressIndicator(
    //       color: Theme.of(context).colorScheme.onPrimary,
    //     ),
    //   );
    // } else if (errorMessage != null) {
    //   content = Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(24.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const Icon(
    //             Icons.warning_amber_rounded,
    //             color: Colors.red,
    //             size: 48,
    //           ),
    //           const SizedBox(height: 10),
    //           Text(
    //             errorMessage!,
    //             textAlign: TextAlign.center,
    //             style: const TextStyle(
    //               color: Colors.red,
    //               fontSize: 16,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //           const SizedBox(height: 20),
    //           TextButton.icon(
    //             onPressed: getcoinMarket,
    //             icon: const Icon(Icons.refresh),
    //             label: const Text('Try Again'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // } else if (coinMarket != null && coinMarket!.isNotEmpty) {
    //   content = ListView.builder(
    //     itemCount: coinMarket!.length,
    //     itemBuilder: (context, index) => Coin(coin: coinMarket![index]),
    //   );
    // } else {
    //   content = const Center(child: Text('No coin data available.'));
    // }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(title: Text('RiverWallet')),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("\$0.00", style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _homeIconButton(Icons.call_made),
                        Text("send"),
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        _homeIconButton(Icons.call_received),
                        Text("Receive"),
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [_homeIconButton(Icons.money), Text("Buy")],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        _homeIconButton(Icons.swap_horiz),
                        Text("Trade"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,

              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: FutureBuilder(
                future: getAllData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (data.contains('empty')) {
                      return Center(
                        child: Text(
                          "Connect to Internet",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) =>
                            Coin(coin: data[index]),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

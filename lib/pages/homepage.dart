import 'dart:convert';
import 'dart:developer';

import 'package:crypto_wallet_app/model/model.dart';
import 'package:crypto_wallet_app/widgets/coin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    getcoinMarket();
    super.initState();
  }

  List? coinMarket = [];
  bool isRefreshing = true;

  Future<List<CoinModel>?> getcoinMarket() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true';

    setState(() {
      isRefreshing = true;
    });
    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": 'application/json',
      },
    );
    setState(() {
      isRefreshing = false;
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final List<CoinModel> coinList = jsonList
          .map((json) => CoinModel.fromJson(json as Map<String, dynamic>))
          .toList();
      // var x = response.body;
      // coinMarketList = coinModelFromJson(x);
      setState(() {
        coinMarket = coinList;
      });
    } else {
      log(response.statusCode.toString());
    }
  }

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
              child: isRefreshing == true
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: coinMarket!.length,
                      itemBuilder: (context, index) =>
                          Coin(coin: coinMarket![index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

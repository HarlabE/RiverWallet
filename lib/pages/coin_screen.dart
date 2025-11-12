import 'dart:convert';
import 'dart:developer';

import 'package:crypto_wallet_app/model/chart_model.dart';
import 'package:crypto_wallet_app/model/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key, required this.coin});

  final CoinModel coin;
  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  late TrackballBehavior trackballBehavior;
  @override
  void initState() {
    getChart();
    trackballBehavior = TrackballBehavior(
      activationMode: ActivationMode.singleTap,
      enable: true,
    );
    super.initState();
  }

  int days = 30;
  bool isRefresh = true;
  List<ChartModel>? itemChart;
  String? errorMessage;
  Future<void> getChart() async {
    String url =
        'https://api.coingecko.com/api/v3/coins/${widget.coin.id}/ohlc?vs_currency=usd&days=$days';
    setState(() {
      isRefresh = true;
      errorMessage = null;
      itemChart = null;
    });
    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": 'application/json',
      },
    );
    setState(() {
      isRefresh = false;
    });
    if (response.statusCode == 200) {
      Iterable x = json.decode(response.body);

      List<ChartModel> modelList = x
          .map((e) => ChartModel.fromJson(e))
          .toList();
      setState(() {
        itemChart = modelList;
      });
    } else if (response.statusCode == 429) {
      final retryAfter = response.headers['retry-after'];
      String waitTime = retryAfter != null && int.tryParse(retryAfter) != null
          ? ' in $retryAfter seconds'
          : '';

      setState(() {
        errorMessage =
            'Rate limit exceeded. You\'ve made too many requests. Please try again$waitTime.';
        log('Rate limit error: ${errorMessage!}');
      });
    } else {
      setState(() {
        errorMessage =
            'Failed to load chart data (Status: ${response.statusCode}).';
      });
      log(response.statusCode.toString());
    }
  }

  List<String> text = [' D ', ' W ', ' M ', '3M', '6M', ' Y '];
  List<bool> textbool = [false, false, true, false, false, false];
  @override
  Widget build(BuildContext context) {
    setDays(String txt) {
      if (txt == ' D ') {
        setState(() {
          days = 1;
        });
      } else if (txt == ' W ') {
        setState(() {
          days = 7;
        });
      } else if (txt == ' M ') {
        setState(() {
          days = 30;
        });
      } else if (txt == '3M') {
        setState(() {
          days = 90;
        });
      } else if (txt == '6M') {
        setState(() {
          days = 180;
        });
      } else if (txt == ' Y ') {
        setState(() {
          days = 365;
        });
      }
    }

    Widget chartContent;

    if (isRefresh) {
      chartContent = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      chartContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 36),
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: getChart,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (itemChart != null && itemChart!.isNotEmpty) {
      // Display the chart
      chartContent = SfCartesianChart(
        trackballBehavior: trackballBehavior,
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          zoomMode: ZoomMode.x,
        ),
        series: [
          CandleSeries<ChartModel, int>(
            enableSolidCandles: true,
            enableTooltip: true,
            bullColor: Colors.green,
            bearColor: Colors.red,
            dataSource: itemChart!,
            xValueMapper: (ChartModel sales, _) => sales.time,
            lowValueMapper: (ChartModel sales, _) => sales.low,
            highValueMapper: (ChartModel sales, _) => sales.high,
            openValueMapper: (ChartModel sales, _) => sales.open,
            closeValueMapper: (ChartModel sales, _) => sales.close,
            animationDuration: 55,
          ),
        ],
      );
    } else {
      chartContent = const Center(child: Text('No chart data available.'));
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.coin.symbol.toUpperCase())),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Image.network(widget.coin.image, width: 50),
                Spacer(),
                Column(
                  children: [
                    Text(
                      widget.coin.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(widget.coin.symbol),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text(widget.coin.currentPrice.toStringAsFixed(1)),
                    Text(
                      widget.coin.marketCapChangePercentage24H.toString(),
                      style: TextStyle(
                        color: widget.coin.marketCapChangePercentage24H <= 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30),
          SizedBox(height: 200, child: chartContent),
          SizedBox(height: 10),
          SizedBox(
            height: 40,

            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: text.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      textbool = [false, false, false, false, false, false];
                      textbool[index] = true;
                      errorMessage = null;
                    });
                    setDays(text[index]);
                    getChart();
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: textbool[index] == true
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                    child: Text(text[index], style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Column(
                  children: [
                    Text('24H High'),
                    Text(widget.coin.high24H.toStringAsFixed(1)),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text('24H Low'),
                    Text(widget.coin.low24H.toStringAsFixed(1)),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text('Volume'),
                    Text(widget.coin.totalVolume.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

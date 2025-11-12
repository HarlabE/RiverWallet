import 'package:crypto_wallet_app/model/model.dart';
import 'package:crypto_wallet_app/pages/coin_screen.dart';
import 'package:flutter/material.dart';

class Coin extends StatelessWidget {
  const Coin({super.key, required this.coin});
  final CoinModel coin;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoinScreen(coin: coin)),
        );
      },
      child: Card(
        child: ListTile(
          leading: Image.network(coin.image, width: screenWidth * 0.1),
          title: Text(coin.name),
          subtitle: Text(coin.symbol),
          trailing: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$ ${coin.currentPrice.toStringAsFixed(1)}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                ),
              ),
              Spacer(),
              Text(
                '\$ ${coin.priceChange24H.toStringAsFixed(1)}',
                textAlign: TextAlign.left,
              ),
            ],
          ),
          titleAlignment: ListTileTitleAlignment.center,
        ),
      ),
    );
  }
}

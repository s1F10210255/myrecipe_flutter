import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdInterstitialWidget extends StatefulWidget {
  @override
  _AdInterstitialWidgetState createState() => _AdInterstitialWidgetState();

  void showAd() {
    _AdInterstitialWidgetState.showAdStatic();
  }
}

class _AdInterstitialWidgetState extends State<AdInterstitialWidget> {
  static InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1327127606116802/2939016691', // テスト用広告ユニットID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // UIコンポーネントは不要なのでコンテナを返します。
  }

  static void showAdStatic() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    }
  }
}

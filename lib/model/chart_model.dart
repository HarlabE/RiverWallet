class ChartModel {
  ChartModel({this.close, this.high, this.low, this.open, required this.time});
  int time;
  double? open;
  double? high;
  double? low;

  double? close;

  factory ChartModel.fromJson(List l) {
    return ChartModel(
   time: l[0] ?? 0,
    open: l[1] as double? ?? 0.0, 
    high: l[2] as double? ?? 0.0,
    low: l[3] as double? ?? 0.0,
    close: l[4] as double? ?? 0.0,
    );
  }
}

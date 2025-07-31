

class AvailabilityWeekModel {
  bool? isAvailable;
  String? day;
  String? startTime;
  String? endTime;

  AvailabilityWeekModel({this.isAvailable, this.day, this.startTime, this.endTime});

  AvailabilityWeekModel.fromJson(Map<String, dynamic> json) {
    isAvailable = json['isAvailable'];
    day = json['day'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isAvailable'] = isAvailable;
    data['day'] = day;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    return data;
  }

  @override
  String toString() {

    return 'Day: $day, Value: $isAvailable, Start: $startTime, End: $endTime';
  }
}
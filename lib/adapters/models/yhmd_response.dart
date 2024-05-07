class YhdmResponse {
  int aid;
  int playindex;
  int epindex;

  YhdmResponse(this.aid, this.playindex, this.epindex);

  Map<String, dynamic> toJson() {
    return {
      'aid': aid,
      'playindex': playindex,
      'epindex': epindex,
    };
  }

  static YhdmResponse extractNumbers(String input) {
    RegExp regex = RegExp(r'/(\d+)-(\d+)-(\d+)\.html');
    RegExpMatch? match = regex.firstMatch(input);
    if (match != null) {
      int aid = int.parse(match.group(1)!);
      int playindex = int.parse(match.group(2)!);
      int epindex = int.parse(match.group(3)!);
      return YhdmResponse(aid, playindex, epindex);
    }
    throw Exception('No match found');
  }
}

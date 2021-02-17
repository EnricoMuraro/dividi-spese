
class Exchange {
  String userFrom;
  String userTo;
  double value;

  Exchange({this.userFrom, this.userTo, this.value});
  @override
  String toString() {
    // TODO: implement toString
    return userFrom + ", " + value.toString() + ", " + userTo;
  }
}
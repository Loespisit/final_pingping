class ListProductType {
  int? value;
  String? name;

  ListProductType(this.value, this.name);

  static List<ListProductType> getListProductType() {
    return [
      ListProductType(1, 'สด'),
      ListProductType(2, 'แห้ง'),
    ];
  }
}

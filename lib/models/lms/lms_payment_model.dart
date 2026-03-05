class LmsPaymentModel {
  String? adminName;
  String? description;
  bool? enabled;
  String? id;
  Object? instructions;
  bool? isSelected;
  String? orderButtonText;
  Object? settings;
  String? title;
  String? appClientId;
  String? appClientSecret;

  LmsPaymentModel({this.adminName, this.description, this.enabled, this.id, this.instructions, this.isSelected, this.orderButtonText, this.settings, this.title, this.appClientId, this.appClientSecret});

  factory LmsPaymentModel.fromJson(Map<String, dynamic> json) {
    return LmsPaymentModel(
      adminName: json['admin_name'],
      description: json['description'],
      enabled: json['enabled'],
      id: json['id'],
      instructions: json['instructions'] != null ? json['instructions'] : null,
      isSelected: json['is_selected'],
      orderButtonText: json['order_button_text'],
      settings: json['settings'] != null ? json['settings'] : null,
      title: json['title'],
      appClientId: json['app_client_id']?.toString() ?? "",
      appClientSecret: json['app_client_secret']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_name'] = this.adminName;
    data['description'] = this.description;
    data['enabled'] = this.enabled;
    data['id'] = this.id;
    data['is_selected'] = this.isSelected;
    data['order_button_text'] = this.orderButtonText;
    data['title'] = this.title;
    data['app_client_id'] = this.appClientId;
    data['app_client_secret'] = this.appClientSecret;
    if (this.instructions != null) {
      data['instructions'] = this.instructions;
    }
    if (this.settings != null) {
      data['settings'] = this.settings;
    }
    return data;
  }
}

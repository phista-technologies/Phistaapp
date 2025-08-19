

class AppleUserDataModel {
  String? userIdentifier;
  String? email;
  String? givenName;
  String? familyName;
  String? authorizationCode;
  String? identityToken;
  String? state;

  AppleUserDataModel({this.userIdentifier, this.email, this.givenName, this.familyName, this.authorizationCode, this.identityToken,this.state});

  AppleUserDataModel.fromJson(Map<String, dynamic> json) {
    userIdentifier = json['userIdentifier'];
    email = json['email'];
    givenName = json['givenName'];
    familyName = json['familyName'];
    authorizationCode = json['authorizationCode'];
    identityToken = json['identityToken'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userIdentifier'] = userIdentifier;
    data['email'] = email;
    data['givenName'] = givenName;
    data['familyName'] = familyName;
    data['authorizationCode'] = authorizationCode;
    data['identityToken'] = identityToken;
    data['state'] = state;
    return data;
  }
}
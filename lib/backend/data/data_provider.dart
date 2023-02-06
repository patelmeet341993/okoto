import 'package:flutter/foundation.dart';

import '../../model/property/property_model.dart';

class DataProvider extends ChangeNotifier {
  //region PropertyModel
  PropertyModel _propertyModel = PropertyModel();

  PropertyModel get propertyModel => _propertyModel;

  void setPropertyModel({required PropertyModel model, bool isNotify = true}) {
    _propertyModel = model;
    if(isNotify) notifyListeners();
  }
  //endregion
}
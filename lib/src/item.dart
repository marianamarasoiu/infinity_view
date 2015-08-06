part of infinity_view;

class Item {

  /// The HTML element representing this item. It's only loaded when the item
  /// should become visible to the user, and once loaded, it is stored here
  /// as a cache.
  DivElement _element;

  /// The user provided method to create the element.
  ItemElementFromDataFunction _builderFunction;

  /// The data associated with this item. It should be passed to the
  /// [_builderFunction].
  var _data;

  /// Default constructor setting the [_builderFunction] that will be used to
  /// create the HTML element corresponding to this item and the [_data]
  /// from which the element will be created.
  Item(this._builderFunction, this._data) {}

  /// Getter for the HTML element of this item.
  DivElement get element {
    if (_element == null) {
      _element = _builderFunction(_data);
    }
    return _element;
  }

  void remove() {
    if (_element != null) {
      _element.remove();
    }
  }
}

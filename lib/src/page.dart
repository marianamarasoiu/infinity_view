part of infinity_view;

class Page {

  /// The HTML element representing this page. It's only loaded when the items
  /// should become visible to the user, and once loaded, it is stored here
  /// as a cache.
  DivElement _element;

  /// The list of [Items] that belong to this page.
  List<Item> _items = [];

  /// The page id used for constructing the CSS id.
  int id;

  /// Default constructor setting the [id] of the page.
  Page(this.id);

  /// Add an item to the list of items.
  void add(Item item) {
    _items.add(item);
  }

  /// The method used to load this page. Fills up [_element] and attaches it
  /// to the [_parentElement].
  DivElement get element {
    if (_element == null) {
      _element = _blankDiv();
      _element.classes.add('page');
      _element.style.height = 'auto';
      _element.attributes[_PAGE_ID_ATTRIBUTE] = '${id}';

      // Element is empty, we have to load the items into it.
      for (Item item in _items) {
        _element.append(item.element);
      }
    }
    return _element;
  }

  void remove() {
    if (_element != null) {
      _element.remove();
    }
  }
}

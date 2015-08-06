part of infinity_view;

/// Provides an infinite scrolling list of images loaded on demand.
class InfinityView {
  /// The number of items that fit vertically on a page.
  int pageVerticalItemCount = 7;

  /// The number of items that fit horizontally on a page.
  int pageHorizontalItemCount = 5;

  /// The list of images that will be loaded.
  List _itemDataList;

  /// A template div to use for each item.
  /// The image will be loaded in the first <img> element of the div.
  ItemElementFromDataFunction _itemElementFromData;

  /// The pages with the elements. We display maximum of three at a time:
  /// the current page, and one page beforehand and one page afterwards.
  List<Page> _pages;

  /// A reference to the parent <div> where the list is in.
  DivElement _container;

  /// A black div element used to fill the space before the pages in view.
  DivElement _preFiller;

  /// The total number of items to be displayed.
  int _itemCount;

  /// The index of the curent page.
  int _currentPageIndex;

  /// The height of a page. Is set once in [attachToElement].
  int _pageHeight;

  InfinityView(this._itemDataList, this._itemElementFromData) {
    _itemCount = _itemDataList.length;
  }

  /// Adds the infinity list view to [element] and creates the necessary
  /// listeners.
  attachToElement(Element element) {
    _container = element;

    _preFiller = _blankDiv();
    _container.append(_preFiller);

    // Create pages and append the first two to the parent.
    _pages = [];
    int itemsPerPage = pageVerticalItemCount * pageHorizontalItemCount;
    int pagesCount = (_itemCount / itemsPerPage).ceil();

    for (int i = 0; i < pagesCount; i++) {
      Page page = new Page(i);
      _pages.add(page);

      int start = i * itemsPerPage;
      int end = _math.min((i + 1) * itemsPerPage, _itemDataList.length);

      for (int j = start; j < end; j++) {
        page.add(new Item(_itemElementFromData, _itemDataList[j]));
      }
    }

    if (_pages.length == 0) {
      return;
    }

    // Append first two pages
    _appendPageInContainer(_pages[0].element, _container);
    if (_pages.length > 1) {
      _appendPageInContainer(_pages[1].element, _container);
    }
    _currentPageIndex = 0;

    _pageHeight = _container.querySelector('.page').clientHeight;
    _container.style.height = '${pagesCount * _pageHeight}px';
    _container.parent.onMouseWheel.listen(_scrollHandler);
  }

  /// Handle scrolling through the list. Use the WheelEvent instead of the
  /// (non-existent in Dart) "scroll" event in order to get the direction
  /// of the scroll.
  void _scrollHandler(WheelEvent e) {
    int newPageIndex = _currentPageIndex;
    Page currentPage = _pages[_currentPageIndex];
    DivElement currentPageElement = currentPage.element;
    // Jump to the next page, unless we're at the last one already
    if (e.deltaY > 0.0 &&
        _atBottomOfWindow(_container.parent, currentPageElement)) {
      newPageIndex = _math.min(_currentPageIndex + 1, _pages.length - 1);
    }
    // Jump to the previous page, unless we're at the first one already
    if (e.deltaY < 0.0 &&
        _atTopOfWindow(_container.parent, currentPageElement)) {
      newPageIndex = _math.max(_currentPageIndex - 1, 0);
    }
    if (newPageIndex != _currentPageIndex) {
      _updatePages(newPageIndex);
    }
  }

  /// Updates the pages displayed based on the value of [newPageIndex].
  /// After this runs, the pages displayed should be the page before
  /// [newPageIndex], the [newPageIndex] page and the page after [newPageIndex].
  _updatePages(int newPageIndex) {
    int nodeToRemoveIndex = null;
    int nodeToAddIndex = null;
    bool prependInsteadOfAdd = null;
    if (newPageIndex > _currentPageIndex) {
      // scrolling down
      if (_currentPageIndex != 0) {
        nodeToRemoveIndex = _math.max(_currentPageIndex - 1, 0);
      }
      if (newPageIndex != _pages.length - 1) {
        nodeToAddIndex = _math.min(newPageIndex + 1, _pages.length - 1);
        prependInsteadOfAdd = false;
      }
    } else if (newPageIndex < _currentPageIndex) {
      // scrolling up
      if (_currentPageIndex != _pages.length - 1) {
        nodeToRemoveIndex = _math.min(_currentPageIndex + 1, _pages.length - 1);
      }
      if (newPageIndex != 0) {
        nodeToAddIndex = _math.max(newPageIndex - 1, 0);
        prependInsteadOfAdd = true;
      }
    }
    _currentPageIndex = newPageIndex;

    if (nodeToRemoveIndex != null) {
      Page pageToRemove = _pages[nodeToRemoveIndex];
      pageToRemove.remove();
    }

    if (nodeToAddIndex != null) {
      if (prependInsteadOfAdd) {
        // The node we insert should be after the filler node.
        int insertIndex = _container.nodes.indexOf(_preFiller) + 1;
        _insertPageInContainer(
            insertIndex, _pages[nodeToAddIndex].element, _container);
      } else {
        _appendPageInContainer(_pages[nodeToAddIndex].element, _container);
      }
    }

    int fillerHeight = _math.max(_currentPageIndex - 1, 0) * _pageHeight;
    _preFiller.style.height = '${fillerHeight}px';
  }
}

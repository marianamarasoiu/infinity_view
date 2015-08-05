library infinity_view;

import 'dart:html';
import 'dart:math' as math;

/// Creates an empty div (without an image). Must contain an <img> element
/// where the image will be loaded.
/// Callback supplied by the user of the library.
typedef DivElement ItemElementFromDataFunction(data);

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

  /// A reference to the parent <div> where the list is in.
  DivElement _container;

  /// A black div element used to fill the space before the pages in view.
  DivElement _preFiller;

  /// The pages with the elements. We display maximum of three at a time:
  /// the current page, and one page beforehand and one page afterwards.
  List<List<DivElement>> _pages;

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

    // Create pages and append the first three to the parent.
    _pages = [];
    int itemsPerPage = pageVerticalItemCount * pageHorizontalItemCount;
    int pagesCount = (_itemCount / itemsPerPage).ceil();

    for (int i = 0; i < pagesCount; i++) {
      List pageItems = [];
      _pages.add(pageItems);

      int start = i * itemsPerPage;
      int end = math.min((i + 1) * itemsPerPage, _itemDataList.length);

      for (int j = start; j < end; j++) {
        DivElement item = _itemElementFromData(_itemDataList[j]);
        pageItems.add(item);
      }
    }

    if (_pages.length == 0) {
      return;
    }
    // Append first two pages
    appendPageInContainer(0, _container);
    if (_pages.length > 1) {
      appendPageInContainer(1, _container);
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
    DivElement currentPage = _container.querySelector('.page[data-infinity-page="${_currentPageIndex}"');
    // Jump to the next page, unless we're at the last one already
    if (e.deltaY > 0.0 &&
        _atBottomOfWindow(_container.parent, currentPage)) {
      newPageIndex = math.min(_currentPageIndex + 1, _pages.length - 1);
    }
    // Jump to the previous page, unless we're at the first one already
    if (e.deltaY < 0.0 &&
        _atTopOfWindow(_container.parent, currentPage)) {
      newPageIndex = math.max(_currentPageIndex - 1, 0);
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
        nodeToRemoveIndex = math.max(_currentPageIndex - 1, 0);
      }
      if (newPageIndex != _pages.length - 1) {
        nodeToAddIndex = math.min(newPageIndex + 1, _pages.length - 1);
        prependInsteadOfAdd = false;
      }
    } else if (newPageIndex < _currentPageIndex) {
      // scrolling up
      if (_currentPageIndex != _pages.length - 1) {
        nodeToRemoveIndex = math.min(_currentPageIndex + 1, _pages.length - 1);
      }
      if (newPageIndex != 0) {
        nodeToAddIndex = math.max(newPageIndex - 1, 0);
        prependInsteadOfAdd = true;
      }
    }
    _currentPageIndex = newPageIndex;

    if (nodeToRemoveIndex != null) {
      DivElement nodeToRemove = _container.nodes.firstWhere((e) {
        if (e is DivElement && e.attributes.containsKey('data-infinity-page')) {
          int id = int.parse(e.attributes['data-infinity-page']);
          return id == nodeToRemoveIndex;
        }
      });
      nodeToRemove.nodes.clear();
      nodeToRemove.remove();
    }

    if (nodeToAddIndex != null) {
      if (prependInsteadOfAdd) {
        // The node we insert should be after the filler node.
        int insertIndex = _container.nodes.indexOf(_preFiller) + 1;
        insertPageInContainer(nodeToAddIndex, insertIndex, _container);
      } else {
        appendPageInContainer(nodeToAddIndex, _container);
      }
    }

    int fillerHeight = math.max(_currentPageIndex - 1, 0) * _pageHeight;
    _preFiller.style.height = '${fillerHeight}px';
  }

  DivElement _pageDiv(int index) {
    DivElement page = _blankDiv();
    page.classes.add('page');
    page.style.height = 'auto';
    page.attributes['data-infinity-page'] = '${index}';

    for (int i = 0; i < _pages[index].length; i++) {
      page.append(_pages[index][i]);
    }
    return page;
  }

  void appendPageInContainer(int pageIndex, DivElement container) {
    DivElement page = _pageDiv(pageIndex);
    container.append(page);
  }

  void insertPageInContainer(int pageIndex, int atIndex, DivElement container) {
    DivElement page = _pageDiv(pageIndex);
    container.nodes.insert(atIndex, page);
  }
}

DivElement _blankDiv() {
  DivElement element = new DivElement();
  element.style
    ..padding = '0px'
    ..margin = '0px'
    ..border = 'none'
    ..height = '0px';
  return element;
}

bool _atBottomOfWindow(Element window, Element element) {
  return _scrollDistanceFromBottom(window, element) <= 0;
}

num _scrollDistanceFromBottom(Element window, Element element) {
  return (element.marginEdge.top + element.marginEdge.height) -
      (window.marginEdge.top + window.marginEdge.height);
}

bool _atTopOfWindow(Element window, Element element) {
  int distance = _scrollDistanceFromTop(window, element);
  return distance <= 0;
}

num _scrollDistanceFromTop(Element window, Element element) {
  return window.marginEdge.top - element.marginEdge.top;
}

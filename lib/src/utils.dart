part of infinity_view;

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

void _appendPageInContainer(Element element, DivElement container) {
  container.append(element);
}

void _insertPageInContainer(int index, Element element, DivElement container) {
  container.nodes.insert(index, element);
}

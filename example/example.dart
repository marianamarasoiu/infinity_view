import 'dart:html';

import 'package:infinity_view/infinity_view.dart';

main() {
  String img = 'http://evilloop.com/ceilingcat.png';
  UListElement container = querySelector('.selector-items-container');

  List<String> imgUrls = [];
  for (int i = 0; i < 10000; i++) {
    imgUrls.add(img);
  }

  Function divTemplateFn = (String imageUrl) {
    DivElement element = new DivElement();
    element.classes.add('item');

    ImageElement img = new ImageElement();
    img.style
        ..maxWidth = '100%'
        ..maxHeight = '100%';
    img.src = imageUrl;
    element.append(img);
    return element;
  };
  InfinityView view = new InfinityView(imgUrls, divTemplateFn);
  view.pageHorizontalItemCount = 10;
  view.pageVerticalItemCount = 8;
  view.attachToElement(container);
}

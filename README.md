# A simple infinite list view

A simplified Dart approach to http://airbnb.io/infinity/demo-on.html

Allows for now only mouse wheel scrolling, not through up/down keys and
moving the scrollbar.

# Usage

You can create an InfinityView object by providing it with a list of information
associated with each item (e.g. URLs to images, numbers, strings etc.) and a
function that returns a div element given the information for a given item.

```
List dataList = [1, 2, 3];
Function createDiv = (data) {
  DivElement div = new DivElement();
  div.text = data.toString()
}
InfinityView view = new InfinityView(dataList, createDiv);
```

The prototype for the element creating function is:

```
DivElement ItemElementFromDataFunction(data);
```

You can also set the number of items you want displayed horizontally and
vertically.

```
view.pageHorizontalItemCount = 10;
view.pageVerticalItemCount = 8;
```

When you want it displayed on the screen, just attach it to an existing element.

```
view.attachToElement(querySelector('#container');
```

Note that changing the horizontal and vertical item count after calling
```attachToElement``` has no effect.

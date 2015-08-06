library infinity_view;

import 'dart:html';
import 'dart:math' as _math;

part 'src/infinity_view.dart';
part 'src/item.dart';
part 'src/page.dart';
part 'src/utils.dart';

/// Creates an empty div (without an image). Must contain an <img> element
/// where the image will be loaded.
/// Callback supplied by the user of the library.
typedef DivElement ItemElementFromDataFunction(data);

const String _PAGE_ID_ATTRIBUTE = 'data-infinity-pageid';
const int _NUM_BUFFER_PAGES = 1;

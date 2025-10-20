import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CookbookViewType { grid, list }

class CookbookViewModel extends StateNotifier<CookbookViewType> {
  CookbookViewModel() : super(CookbookViewType.grid);

  void setViewType(CookbookViewType viewType) {
    state = viewType;
  }

  void toggleViewType() {
    state = state == CookbookViewType.grid
        ? CookbookViewType.list
        : CookbookViewType.grid;
  }
}

final cookbookViewModelProvider =
    StateNotifierProvider<CookbookViewModel, CookbookViewType>(
  (ref) => CookbookViewModel(),
);

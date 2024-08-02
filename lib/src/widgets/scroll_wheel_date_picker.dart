import 'package:flutter/material.dart';

import '../themes/scroll_wheel_date_picker_theme.dart';
import '../constants/theme_constants.dart';
import '../constants/date_constants.dart';
import 'overlays/highlight_overlay.dart';
import 'overlays/holo_overlay.dart';
import 'overlays/line_overlay.dart';
import '../date_controller.dart';
import 'curve_scroll_wheel.dart';
import 'flat_scroll_wheel.dart';

enum DateComponent {
  year,
  month,
  day,
}

class ScrollWheelDatePicker extends StatefulWidget {
  /// A scroll wheel date picker that has two types:
  ///
  /// `CurveScrollWheel` - Uses [ListWheelScrollView] to create a date picker with a curve perspective.
  ///
  /// `FlatScrollWheel` - Based on [ListWheelScrollView] to create a date picker with a flat perspective.
  const ScrollWheelDatePicker({
    super.key,
    this.initialDate,
    this.startDate,
    this.lastDate,
    this.loopDays = true,
    this.loopMonths = true,
    this.loopYears = false,
    this.onSelectedItemChanged,
    required this.theme,
    this.listenAfterAnimation = true,
    this.scrollBehavior,
    this.order = const [
      DateComponent.year,
      DateComponent.month,
      DateComponent.day,
    ],
  });

  /// The initial date for the [ScrollWheelDatePicker]. Defaults to [DateTime.now].
  final DateTime? initialDate;

  /// Sets the start date for the [ScrollWheelDatePicker]. Defaults to [startDate].
  final DateTime? startDate;

  /// Sets the last date for the [ScrollWheelDatePicker]. Defaults to [lastDate].
  final DateTime? lastDate;

  /// Whether to loop through all of the items in the days scroll wheel. Defaults to `true`.
  final bool loopDays;

  /// Whether to loop through all of the items in the months scroll wheel. Defaults to `true`.
  final bool loopMonths;

  /// Whether to loop through all of the items in the years scroll wheel. Defaults to `false`.
  final bool loopYears;

  /// Callback fired when an item is changed. Returns a [DateTime].
  final Function(DateTime value)? onSelectedItemChanged;

  /// An abstract class for common themes of the `WheelDatePicker`.
  ///
  /// Types of Themes supported by the [ScrollWheelDatePickerTheme].
  ///
  /// [CurveDatePickerTheme] - Theme for the [CurveScrollWheel].
  ///
  /// [FlatDatePickerTheme] - Theme for the [FlatScrollWheel].
  final ScrollWheelDatePickerTheme theme;

  /// Whether to call the [onSelectedItemChanged] when the scroll wheel animation is completed. Defaults to `true`.
  final bool listenAfterAnimation;

  /// Describes how [Scrollable] widgets should behave.
  final ScrollBehavior? scrollBehavior;

  /// config the order of the date components.
  final List<DateComponent> order;

  @override
  State<ScrollWheelDatePicker> createState() => _ScrollWheelDatePickerState();
}

class _ScrollWheelDatePickerState extends State<ScrollWheelDatePicker> {
  /// Manages the initialization and changes of the days, months and years [ScrollWheelDatePicker].
  late final DateController _dateController;

  @override
  void initState() {
    super.initState();

    _dateController = DateController(
      initialDate: widget.initialDate,
      startDate: widget.startDate,
      lastDate: widget.lastDate,
    );
  }

  @override
  void didUpdateWidget(covariant ScrollWheelDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialDate != widget.initialDate) {
      _dateController.changeInitialDate(widget.initialDate ?? DateTime.now());
    }

    if (oldWidget.startDate != widget.startDate) {
      _dateController.changeStartDate(
          widget.startDate ?? DateTime.parse(defaultStartDate));
    }

    if (oldWidget.lastDate != widget.lastDate) {
      _dateController
          .changeLastDate(widget.lastDate ?? DateTime.parse(defaultLastDate));
    }

    if (oldWidget.theme.monthFormat != widget.theme.monthFormat) {
      _dateController.changeMonthFormat(format: widget.theme.monthFormat);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();

    super.dispose();
  }

  /// Selects what type of scroll wheel to use based on [widget.theme].
  Widget _scrollWidget({
    required IDateController controller,
    Function(int value)? controllerItemChanged,
    required bool looping,
    int? startOffset,
    int? lastOffset,
  }) {
    return widget.theme is CurveDatePickerTheme
        ? CurveScrollWheel(
            items: controller.items,
            selectedIndex: controller.selectedIndex,
            onSelectedItemChanged: controllerItemChanged,
            looping: looping,
            diameterRatio: (widget.theme as CurveDatePickerTheme).diameterRatio,
            itemExtent: widget.theme.itemExtent,
            overAndUnderCenterOpacity: widget.theme.overAndUnderCenterOpacity,
            textStyle: widget.theme.itemTextStyle,
            listenAfterAnimation: widget.listenAfterAnimation,
            scrollBehavior: widget.scrollBehavior,
            startOffset: startOffset,
            lastOffset: lastOffset,
          )
        : FlatScrollWheel(
            items: controller.items,
            selectedIndex: controller.selectedIndex,
            onSelectedItemChanged: controllerItemChanged,
            looping: looping,
            itemExtent: widget.theme.itemExtent,
            textStyle: widget.theme.itemTextStyle,
            listenAfterAnimation: widget.listenAfterAnimation,
            scrollBehavior: widget.scrollBehavior,
            startOffset: startOffset,
            lastOffset: lastOffset,
          );
  }

  /// Selects center overlay base on [ScrollWheelDatePickerOverlay].
  Widget _overlay() {
    switch (widget.theme.overlay) {
      case ScrollWheelDatePickerOverlay.highlight:
        return HightlightOverlay(
          height: widget.theme.itemExtent,
          color: widget.theme.overlayColor,
        );
      case ScrollWheelDatePickerOverlay.holo:
        return HoloOverlay(
          height: widget.theme.itemExtent,
          color: widget.theme.overlayColor,
        );
      case ScrollWheelDatePickerOverlay.line:
        return LineOverlay(
          height: widget.theme.itemExtent,
          color: widget.theme.overlayColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _yearWidget() {
    return Expanded(
      child: _scrollWidget(
        controller: _dateController.yearController,
        controllerItemChanged: (value) {
          _dateController.changeYear(year: value);
          widget.onSelectedItemChanged?.call(_dateController.dateTime);
        },
        looping: widget.loopYears,
      ),
    );
  }

  Widget _monthWidget() {
    return Expanded(
      child: ListenableBuilder(
        listenable: _dateController,
        builder: (_, __) {
          return _scrollWidget(
            controller: _dateController.monthController,
            controllerItemChanged: (value) {
              _dateController.changeMonth(month: value);
              widget.onSelectedItemChanged?.call(_dateController.dateTime);
            },
            looping: widget.loopMonths,
            startOffset: _dateController.startMonth,
            lastOffset: _dateController.lastMonth,
          );
        },
      ),
    );
  }

  Widget _dayWidget() {
    return Expanded(
      child: ListenableBuilder(
        listenable: _dateController,
        builder: (_, __) {
          return _scrollWidget(
            controller: _dateController.dayController,
            controllerItemChanged: (value) {
              _dateController.changeDay(day: value);
              widget.onSelectedItemChanged?.call(_dateController.dateTime);
            },
            looping: widget.loopDays,
            startOffset: _dateController.startDay,
            lastOffset: _dateController.lastDay,
          );
        },
      ),
    );
  }

  List<Widget> _orderedDateComponents() {
    // Create a map of date components to their corresponding widgets
    Map<DateComponent, Widget> dateComponentWidgets = {
      DateComponent.year: _yearWidget(),
      DateComponent.month: _monthWidget(),
      DateComponent.day: _dayWidget(),
    };

    // Map the order parameter to a list of widgets
    return widget.order
        .map((component) => dateComponentWidgets[component]!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _overlay(),
        SizedBox(
          height: widget.theme.wheelPickerHeight,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: widget.theme.fadeEdges
                    ? [
                        Colors.black,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black
                      ]
                    : [Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: widget.theme.fadeEdges ? [0.0, 0.08, 0.92, 1.0] : [0.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstOut,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ..._orderedDateComponents(),
              ],
            ),
          ),
        ),
        widget.theme is FlatDatePickerTheme
            ? IgnorePointer(
                child: SizedBox(
                  height: defaultWheelPickerHeight,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: (widget.theme as FlatDatePickerTheme)
                                .backgroundColor
                                .withOpacity(
                                  1.0 -
                                      widget.theme.overAndUnderCenterOpacity
                                          .clamp(0.0, 1.0),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultItemExtent),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: (widget.theme as FlatDatePickerTheme)
                                .backgroundColor
                                .withOpacity(
                                  1.0 -
                                      widget.theme.overAndUnderCenterOpacity
                                          .clamp(0.0, 1.0),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

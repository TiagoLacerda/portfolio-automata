import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:overlay_options_button/overlay_options_button.dart';
import 'package:portfolio_design_system/portfolio_design_system.dart';

import '../../app_controller.dart';
import '../../core/grid/widgets/grid_widget.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  final HomeController controller;
  final double spacing;

  const HomeView({
    super.key,
    required this.controller,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          final brightnessSwitch = PortfolioBrightnessSwitch(
            onPressed: () => AppController.instance.toggleThemeMode(),
          );

          final localeButton = OverlayOptionsButton(
            initialValue: AppController.instance.locale,
            items: AppController.instance.supportedLocales,
            onChanged: (value) => AppController.instance.locale = value,
            itemBuilder: (context, index, value, select) {
              final assetName = switch (value.languageCode) {
                'pt' => PortfolioIcons.pt,
                'en' => PortfolioIcons.en,
                _ => PortfolioIcons.pt,
              };

              return IconButton(
                onPressed: () => select(),
                icon: SizedBox.square(
                  dimension: 24.0,
                  child: ClipOval(
                    child: SvgPicture.asset(
                      assetName,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );

          final clearButton = IconButton(
            onPressed: () {
              controller.grid.clear();
            },
            icon: Icon(
              Icons.delete_outline_rounded,
            ),
          );

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 80.0,
              elevation: 3.0,
              actions: [
                Expanded(
                  child: Center(
                    child: PortfolioResponsiveBox(
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: spacing,
                        ),
                        child: Row(
                          children: [
                            brightnessSwitch,
                            localeButton,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    spacing: spacing,
                    children: [
                      clearButton,
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox.expand(
                    child: GridWidget(
                      grid: controller.grid,
                    ),
                  ),
                ),
                // SingleChildScrollView(
                //   padding: EdgeInsets.all(spacing),
                //   child: Column(
                //     spacing: spacing,
                //     children: [
                //       Container(
                //         width: 160,
                //         height: 160,
                //         color: Colors.white,
                //       ),
                //       Container(
                //         width: 160,
                //         height: 160,
                //         color: Colors.white,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

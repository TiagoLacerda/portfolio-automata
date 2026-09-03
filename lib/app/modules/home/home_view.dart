import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:overlay_options_button/overlay_options_button.dart';
import 'package:portfolio_design_system/portfolio_design_system.dart';
import 'package:url_launcher/url_launcher.dart';

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
          final homeButton = IconButton(
            onPressed: () => launchUrl(
              Uri.parse('https://tiagomlbrasil.com'),
              webOnlyWindowName: '_self',
            ),
            icon: Icon(
              Icons.arrow_back_rounded,
            ),
          );

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

          final stepButton = IconButton(
            onPressed: () {
              controller.step();
            },
            icon: Icon(
              Icons.skip_next_outlined,
            ),
          );

          final toggleButton = IconButton(
            onPressed: () {
              controller.toggle();
            },
            icon: Icon(
              controller.running ? Icons.pause_outlined : Icons.play_arrow_outlined,
            ),
          );

          final clearButton = IconButton(
            onPressed: () {
              controller.game.clear();
            },
            icon: Icon(
              Icons.delete_outline_rounded,
            ),
          );

          Color cellColor, emptyColor0, emptyColor1;

          if (Theme.of(context).brightness == Brightness.dark) {
            cellColor = Colors.white;
            emptyColor0 = Color(0xFF0F0F0F);
            emptyColor1 = Color(0xFF1F1F1F);
          } else {
            cellColor = Colors.black;
            emptyColor0 = Color(0xFFF0F0F0);
            emptyColor1 = Color(0xFFF1F1F1);
          }

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
                          horizontal: 40.0,
                        ),
                        child: Row(
                          children: [
                            homeButton,
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
                      stepButton,
                      toggleButton,
                      clearButton,
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox.expand(
                    child: GridWidget(
                      grid: controller.game.world,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    spacing: spacing,
                    children: [
                      Container(
                        width: (controller.neighborhoodGridSize * controller.neighborhoodGridCellSize).toDouble(),
                        height: (controller.neighborhoodGridSize * controller.neighborhoodGridCellSize).toDouble(),
                        color: cellColor.withValues(alpha: 0.5),
                        child: GridWidget(
                          grid: controller.game.neighborhood,
                          initialZoom: controller.initialZoom,
                          initalOffset: controller.initialOffset,
                          enableEditing: true,
                          enablePanAndZoom: false,
                          colorWith: (i, j, value) {
                            if (i == 0 && j == 0) return Colors.red;
                            if (value) return cellColor;
                            if ((i + j % 2) == 0) return emptyColor0;
                            return emptyColor1;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

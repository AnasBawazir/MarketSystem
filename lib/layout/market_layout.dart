import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketsystem/controllers/auth_controller.dart';
import 'package:marketsystem/controllers/facture_controller.dart';
import 'package:marketsystem/controllers/layout_controller.dart';
import 'package:marketsystem/controllers/products_controller.dart';
import 'package:marketsystem/models/details_facture.dart';
import 'package:marketsystem/models/viewmodel/best_selling.dart';
import 'package:marketsystem/models/viewmodel/earn_spent_vmodel.dart';
import 'package:marketsystem/models/viewmodel/low_qty_model.dart';
import 'package:marketsystem/models/viewmodel/profitable_vmodel.dart';
import 'package:marketsystem/screens/dashboard/dashboard_screen.dart';
import 'package:marketsystem/screens/printer_settings/printer_settings_screen.dart';
import 'package:marketsystem/screens/receipts_screen/receipts_screen.dart';
import 'package:marketsystem/services/api/pdf_api.dart';
import 'package:marketsystem/shared/components/default_text_form.dart';
import 'package:marketsystem/shared/constant.dart';
import 'package:marketsystem/shared/styles.dart';
import 'package:marketsystem/shared/toast_message.dart';
import 'package:marketsystem/layout/SearchFieldWidget.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';

import 'drawer_layout.dart';

class MarketLayout extends StatelessWidget {

  // The main screen after splash
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<LayoutController>(context);
    return Scaffold(
      drawer: Consumer<AuthController>(builder: (context, controller, child) {
        return drawer_layout(controller, context);
      }),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: myLinearGradient,
          ),
        ),
        title: controller.issearchingInProducts
            ? SearchFieldWidget(
                context,
                'search in products...',
              )
            : Text(
                controller.appbar_title[controller.currentIndex].toString(),
              ),
        actions: controller.issearchingInProducts == false
            ? [
                IconButton(
                    onPressed: () {
                      controller.onChangeSearchInProductsStatus(true);
                    },
                    icon: Icon(Icons.search)),
              ]
            : [],
      ),
      body: controller.screens[controller.currentIndex],

 /*     bottomNavigationBar: BottomNavigationBar(
        elevation: 30,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: defaultColor,
        onTap: (index) {
          print(index);

          controller.onchangeIndex(index);
        },
        currentIndex: controller.currentIndex,
        items: controller.bottomItems,
      ),*/
    );
  }






  Future<void> deleteDatabase() => databaseFactory.deleteDatabase(databasepath);

}

//For product searching
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/layout_controller.dart';
import '../controllers/products_controller.dart';
import '../shared/components/default_text_form.dart';

SearchFieldWidget(
    BuildContext context,
    String hint,
    ) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: defaultTextFormField(
      //NOTE to open keyboard when pressing on search button
        focus: true,
        onchange: (value) {
          if (value!.length > 1) {
            context.read<ProductsController>().search_In_Products(value);
            //c.search_In_Products(value);
          }
        },
        inputtype: TextInputType.name,
        hinttext: hint,
        border: InputBorder.none,
        cursorColor: Colors.white,
        textColor: Colors.white,
        hintcolor: Colors.white54,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            context.read<ProductsController>().clearSearch();
            context
                .read<LayoutController>()
                .onChangeSearchInProductsStatus(false);
          },
        )),
  );
}
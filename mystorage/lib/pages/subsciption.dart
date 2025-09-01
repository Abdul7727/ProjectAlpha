import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mystorage/buttons/subscription_button.dart';
import 'package:mystorage/pages/settings.dart';
import 'package:mystorage/themes/constants.dart';
import 'package:mystorage/widgets/appbar_widget.dart';
import 'package:mystorage/widgets/custom_bottom_bar.dart';

class CustomCard extends StatelessWidget {
  final String heading;
  final String mntYear;
  final String price;
  final Color cardColor;
  final Color borderColor;

  CustomCard({
    required this.heading,
    required this.price,
    required this.mntYear,
    this.cardColor = const Color(0xFFFFFFFF), // Default color is white
    this.borderColor = Colors.black, // Default border color is black
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: borderColor),
      ),
      color: cardColor, // Set the card color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color:
                    Colors.black, // Black text for contrast against white card
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(''),
                Text(
                  '\$$price/$mntYear',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black text for contrast
                  ),
                ),
              ],
            ),
            Text(
              '\$$price/$mntYear',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey, // Gray text for differentiation
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNestedCard extends StatelessWidget {
  final double sale;
  final double price;
  final double finalPrice;
  const CustomNestedCard(
      {super.key,
      required this.sale,
      required this.price,
      required this.finalPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 500,
        height: 130,
        decoration: BoxDecoration(
            color: const Color(0xffe27676),
            border: Border.all(
              color: Colors.redAccent,
            ),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const Text(
              "Most Popular",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                height: 98,
                width: 500,
                decoration: const BoxDecoration(
                    color: Color(0xfff8f2f0),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12))),
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Monthly",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                      const Size(
                                          100, 35)), // Set width and height
                                  padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16)), // Adjust padding
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20), // Optional: Rounded corners
                                    ),
                                  ),
                                  backgroundColor: WidgetStateProperty.all(
                                      const Color(0xffe27676)),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "save $sale%",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$$price/Month",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "\$$finalPrice/Month",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          ],
                        )
                      ],
                    )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Subscription extends StatelessWidget {
  Subscription({Key? key}) : super(key: key);
  Utils clrScheme = Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clrScheme.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Define action for FAB
        },
        backgroundColor:const Color(0xffA9ABAC),
        shape:const CircleBorder(), // Ensure the FAB is circular
        elevation: 0, // Remove shadow
        child: const ClipOval(
          child: SizedBox(
            width: 60, // Diameter of the FAB
            height: 60,
            child: Icon(Icons.camera_alt,color: Colors.white,size: 30,),
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(

        settings:"assets/images/settings_icon.png" ,
        img: "assets/images/subsfolder.png",
        color: Colors.grey,
        icon: Ic.baseline_folder_copy,
        currentPage: "settings",
        onAddFolder: null,


      ),

      appBar: AppbarWidget(
        title: "Subscription",
        showLeadingButton: true,
        onLeadingPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Settings()));
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Let's Buy Premium\n",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 22,
                        ),
                      ),
                      TextSpan(
                        text: "Upgrade to Premium Version For \n",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "More Features & Ad Free Experience",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            CustomCard(
              mntYear: 'Weekly',
              heading: 'Weekly',
              price: '3.99',
              cardColor: clrScheme.subCardColor,
              borderColor: Colors.grey,
            ),
            const CustomNestedCard(
              sale: 50,
              price: 200,
              finalPrice: 23,
            ),
            CustomCard(
              mntYear: 'Weekly',
              heading: 'Weekly',
              price: '3.99',
              cardColor: clrScheme.subCardColor,
              borderColor: Colors.grey,
            ),
            SubscriptionButton(action: () {}, title: "Subscribe Now"),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

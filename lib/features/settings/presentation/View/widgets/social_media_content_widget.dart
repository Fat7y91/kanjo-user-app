// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher_string.dart';
//
// class SocialMediaContent extends StatelessWidget {
//   final String url;
//   final String image;
//
//   const SocialMediaContent({super.key, required this.url, required this.image});
//
//   @override
//   Widget build(BuildContext context) {
//     final isGoogleAccount = url.contains("@gmail.com");
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w),
//       child: InkWell(
//         onTap: () async {
//           try {
//             if (isGoogleAccount) {
//               final Uri params = Uri(
//                 scheme: 'mailto',
//                 path: 'adelscience2020@gmail.com',
//                 query:
//                     'subject=${"Service".tr}&body=Hello, I want to add some services',
//               );
//
//               String url = params.toString();
//               await launchUrlString(url);
//             } else {
//               await launchUrlString(url);
//             }
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text(e.toString()),
//               backgroundColor: Colors.red,
//             ));
//           }
//         },
//         child: Image.asset(
//           image,
//           width: 40,
//           height: 40,
//           fit: BoxFit.cover,
//           // color: AppColors.primaryColorSALEK1,
//         ),
//       ),
//     );
//   }
// }

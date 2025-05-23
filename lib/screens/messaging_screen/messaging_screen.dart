import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tea_talks/screens/messaging_screen/webview/browser.dart';
import 'package:tea_talks/screens/messaging_screen/widgets/chat_bubble.dart';
import 'package:tea_talks/services/encoding_decoding_service.dart';
import 'package:tea_talks/utility/firebase_constants.dart';
import 'package:tea_talks/utility/ui_constants.dart';

class MessagingScreen extends StatefulWidget {
  final roomData;
  final password;
  final name;

  const MessagingScreen({
    super.key,
    required this.roomData,
    required this.password,
    required this.name,
  });

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _textMessageController = TextEditingController();

  bool showBrowser = false;
  late DocumentReference _documentRef;
  late CollectionReference _chatDataCollectionRef;

  void toggleBrowser() {
    setState(() {
      showBrowser = !showBrowser;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      String url = await uploadImageToFirebaseStorage(File(pickedImage.path));
      if (url != "") {
        sendMessage(url, "image");
      }
    }
  }

  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName.png');

      final UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() => null);
      final String downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return "";
    }
  }

  void sendMessage(String message, String MessageType) {
    var ref = _chatDataCollectionRef.doc();
    var documentId = ref.id;

    Map<String, dynamic> data = {
      kUserName: widget.name,
      kTimestamp: DateFormat('HH:mm, dd MMM yyyy').format(DateTime.now()),
      kMessageBody: message,
      kMessageType: MessageType,
      kIsDoodle: false,
    };

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
      data,
      documentId, // using doc id as IV
      widget.password,
    );

    ref.set({
      'data': encryptedData,
      'id': documentId,
      'date': DateTime.now().toIso8601String().toString(),
    });
  }

  @override
  void initState() {
    super.initState();

    _documentRef = FirebaseFirestore.instance
        .collection(kChatCollection)
        .doc(widget.roomData[kRoomId]);

    _chatDataCollectionRef = _documentRef.collection(kChatDataCollection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            showBrowser
                ? Browser(
                    roomId: widget.roomData[kRoomId],
                    password: widget.password,
                    toggleBrowser: toggleBrowser,
                  )
                : const SizedBox.shrink(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatDataCollectionRef.orderBy('date').snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Send your first text in this Room',
                        style: kTitleTextStyle,
                      ),
                    );
                  }

                  List<Widget> widgets = [];
                  List<DocumentSnapshot> ds =
                      snapshot.data!.docs.reversed.toList();

                  for (var chatData in ds) {
                    widgets.add(ChatBubble(
                      chatData: chatData.data(),
                      name: widget.name,
                      password: widget.password,
                    ));
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: widgets.length,
                    itemBuilder: (ctx, index) {
                      return widgets[index];
                    },
                  );
                },
              ),
            ),
            Container(
              color: kImperialOrange.withOpacity(0.2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MaterialButton(
                        onPressed: () {
                          _pickImageFromCamera();
                          // showModalBottomSheet(
                          //   isScrollControlled: true,
                          //   context: context,
                          //   builder: (ctx) => SingleChildScrollView(
                          //     child: BottomSheetMenu(
                          //       toggleBrowser: toggleBrowser,
                          //       name: widget.name,
                          //       password: widget.password,
                          //       chatDataCollectionReference:
                          //           _chatDataCollectionRef,
                          //     ),
                          //   ),
                          // );
                        },
                        minWidth: 0,
                        elevation: 5.0,
                        color: kWhite,
                        padding: const EdgeInsets.all(10.0),
                        shape: const CircleBorder(),
                        child: const Icon(
                          FontAwesomeIcons.camera,
                          size: 25.0,
                          color: kImperialOrange,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.only(left: 50),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 65,
                          ),
                          child: Card(
                            color: Colors.transparent,
                            elevation: 0.0,
                            margin: const EdgeInsets.all(0.0),
                            child: TextField(
                              controller: _textMessageController,
                              style: kGeneralTextStyle.copyWith(
                                  color: kBlack, fontSize: 20),
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle:
                                    kLabelTextStyle.copyWith(fontSize: 15),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                      onPressed: () {
                        String message = _textMessageController.text.trim();
                        _textMessageController.clear();

                        if (message.isEmpty) {
                          return;
                        }
                        sendMessage(message, 'text');
                      },
                      minWidth: 0,
                      elevation: 5.0,
                      color: kImperialOrange,
                      padding: const EdgeInsets.all(15.0),
                      shape: const CircleBorder(),
                      child: const Icon(
                        FontAwesomeIcons.chevronRight,
                        size: 25.0,
                        color: kWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

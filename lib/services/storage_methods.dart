import 'dart:io';

import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageMethods {
  toUploadFile(String chatRoomId) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'zip',
          'ppt',
          'pptx',
          'hwp',
          'mp3',
          'mp4',
          'wma',
          'wmv',
          '7z',
          'mkv',
          'psd',
          'ai',
          'xls',
          'xlsx',
          'txt',
          'ogg'
        ]);
    if (result != null && result.files.single.size <= 70000) {
      File file = File(result.files.single.path);
      try {
        String fileRef =
            "chat/$chatRoomId/${DateTime.now().millisecondsSinceEpoch}";
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("$fileRef/${result.files.single.name}")
            .putFile(file);

        uploadTask.whenComplete(() async {
          print(
              "다운로드 URL!!: ${FirebaseStorage.instance.ref("$fileRef/${result.files.single.name}").getDownloadURL()}");
          ChatMethods().addFile(chatRoomId, result.files.single.name,
              "$fileRef/${result.files.single.name}");
          return "업로드가 완료되었습니다.";
        }).catchError((Object e) {
          print("업로드 중 에러 발생!!: $e");
        });
      } on FirebaseException catch (e) {
        print("파이어베이스 오류!!: $e");
      }
    } else {
      return "파일 용량이 70MB를 넘어섰거나 선택한 파일이 없습니다!";
    }
  }

  toUploadImage(String chatRoomId) async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path);
      try {
        String fileRef =
            "chat/$chatRoomId/${DateTime.now().millisecondsSinceEpoch}";
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("$fileRef/${result.files.single.name}")
            .putFile(file);
        uploadTask.whenComplete(() {
          print(
              "다운로드 URL!!: ${FirebaseStorage.instance.ref("$fileRef/${result.files.single.name}").getDownloadURL()}");
          if (result.files.single.size <= 10000) {
            ChatMethods().addImage(chatRoomId, result.files.single.name,
                "$fileRef/${result.files.single.name}");
          } else if (10000 < result.files.single.size &&
              result.files.single.size <= 20000) {
            ChatMethods().addFile(chatRoomId, result.files.single.name,
                "$fileRef/${result.files.single.name}");
          } else {
            return "사진 첨부 용량을 초과하였습니다. 사진 1장은 20MB를 넘어서는 안됩니다.";
          }
        }).catchError((Object e) {
          print("업로드 중 에러 발생!!: $e");
          return "업로드 중 문제가 발생했습니다! $e";
        });
      } on FirebaseException catch (e) {
        print("파이어베이스 오류!!: $e");
        return "업로드 중 문제가 발생했습니다! (서버 오류)";
      }
    } else {
      return "사진을 선택하셔야 합니다!";
    }
  }

  Future<String> toDownloadFile(
      String message, String downloadUrl, String chatRoomId) async {
    await Permission.storage.request();
    if (await Permission.storage.request().isGranted) {
      Dio dio = Dio();
      Directory downDir = await getDownloadsDirectory();
      String downPath = downDir.path;

      File downloadToFile = File('$downPath/$message');
      String downloadedFile = '$downPath/$message';
      print(downloadToFile);
      if (downloadToFile.existsSync()) {
        print('이미 다운로드됨!!:: ${downloadToFile.toString()}');
        await OpenFile.open('$downPath/$message');
        return "이미 다운로드 된 파일입니다.";
      } else {
        try {
          await FirebaseStorage.instance
              .ref('$downloadUrl')
              .writeToFile(downloadToFile)
              .whenComplete(() {
            print('다운로드됨!!:: $downloadToFile');
            OpenFile.open(downloadedFile);
            return "다운로드 되었습니다.";
          }).catchError((e) {
            return "다음과 같은 이유로 다운로드에 실패하였습니다. \n$e";
          });
        } on FirebaseException catch (e) {
          print("파이어베이스 오류!!: $e");
          return "다음과 같은 이유로 다운로드에 실패하였습니다. \n$e";
        }
      }
    } else {
      return null;
    }
  }

  // toDeleteLocalFile(
  //     String message, String downloadUrl, String chatRoomId) async {
  //   await Permission.storage.request();
  //   if (await Permission.storage.request().isGranted) {
  //     if (Platform.isAndroid) {
  //       String appDocDir = await ExtStorage.getExternalStoragePublicDirectory(
  //           ExtStorage.DIRECTORY_DOWNLOADS);
  //       File downloadToFile = File('$appDocDir/$message');
  //       print(downloadToFile);
  //       if (downloadToFile.existsSync()) {
  //         downloadToFile.delete();
  //         return "정상적으로 삭제되었습니다.";
  //       } else {
  //         return "파일을 찾을 수 없습니다.\n이미 삭제를 했거나 파일의 위치나 이름이 바뀌었나 봅니다.";
  //       }
  //     } else if (Platform.isIOS) {
  //       Directory appDocDir = await getApplicationDocumentsDirectory();
  //       File downloadToFile = File('${appDocDir.path}/$message');
  //       print(downloadToFile);
  //       print(downloadToFile);
  //       if (downloadToFile.existsSync()) {
  //         downloadToFile.delete();
  //         return "정상적으로 삭제되었습니다.";
  //       } else {
  //         return "파일을 찾을 수 없습니다.\n이미 삭제를 했거나 파일의 위치나 이름이 바뀌었나 봅니다.";
  //       }
  //     }
  //   } else {
  //     return "파일 엑세스 권한을 거부하셔서\n파일 삭제를 할 수 없습니다!";
  //   }
  // }
}

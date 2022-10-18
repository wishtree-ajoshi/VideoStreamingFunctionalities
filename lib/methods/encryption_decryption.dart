import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart';

class EncryptionDecryption {
  encryptFile(videoFileName) async {
    File inFile = File("$videoFileName");

    File outFile = File("$videoFileName.aes");

    bool outFileExists = await outFile.exists();

    if (!outFileExists) {
      await outFile.create();
    }
    final videoFileContents = inFile.readAsStringSync(encoding: latin1);

    final key = Key.fromUtf8('_THISISTHEENCRYPTIONKEYFORVIDEOS');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(videoFileContents, iv: iv);
    return await outFile.writeAsBytes(encrypted.bytes);
  }

  decryptFile(videoFileName) async {
    File inFile = File("$videoFileName");
    File outFile = File("${videoFileName.toString().split('.').first}.mp4");

    bool outFileExists = await outFile.exists();

    if (!outFileExists) {
      await outFile.create();
    }

    final videoFileContents = inFile.readAsBytesSync();

    final key = Key.fromUtf8('_THISISTHEENCRYPTIONKEYFORVIDEOS');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encryptedFile = Encrypted(videoFileContents);
    final decrypted = encrypter.decrypt(encryptedFile, iv: iv);

    final decryptedBytes = latin1.encode(decrypted);
    return await outFile.writeAsBytes(decryptedBytes);
  }
}

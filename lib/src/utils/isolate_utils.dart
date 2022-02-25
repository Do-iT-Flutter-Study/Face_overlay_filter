// 출처 : https://github.com/JaeHeee/Flutter_TIL/tree/main/lib/dart/isolate
// 설명 : https://velog.io/@kjha2142/Flutter-Isolate

import 'dart:isolate';

class IsolateUtils {
  late Isolate? _isolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  SendPort get sendPort => _sendPort;

  Future<void> initIsolate() async {
    _receivePort = ReceivePort();
    _isolate =
        await Isolate.spawn<SendPort>(_entryPoint, _receivePort.sendPort);
    _sendPort = await _receivePort.first;
  }

  static void _entryPoint(SendPort mainSendPort) async {
    final childReceivePort = ReceivePort();
    mainSendPort.send(childReceivePort.sendPort);

    await for (final _IsolateData isolateData in childReceivePort) {
      if (isolateData != null) {
        final results = await isolateData.handler(isolateData.params);

        isolateData.responsePort.send(results);
      }
    }
  }

  void sendMessage(
    Function handler,
    SendPort sendPort,
    ReceivePort responsePort, {
    dynamic params,
  }) {
    final isolateData = _IsolateData(
      handler,
      params,
      responsePort.sendPort,
    );
    sendPort.send(isolateData);
  }

  void dispose() {
    _receivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
  }
}

class _IsolateData {
  Function handler;
  dynamic params;
  SendPort responsePort;

  _IsolateData(this.handler, this.params, this.responsePort);
}

// isolate_utils를 사용하는 widget에서 구현

// final IsolateUtils _isolateUtils = IsolateUtils();
// final String _url = 'https://randomuser.me/api';
// int _count = 0;
// String _isolateResult = 'isolateResult';
// String _computeResult = 'computeResult';
// void _isolateSpawn() async {
//   final responsePort = ReceivePort();
//
//   _isolateUtils.sendMessage(
//     handler,
//     _isolateUtils.sendPort,
//     responsePort,
//     params: _url,
//   );
//
//   final result = await responsePort.first;
//   setState(() {
//     _isolateResult = result.toString();
//   });
// }
//
// void _compute() async {
//   final result = await compute(handler, _url);
//   setState(() {
//     _computeResult = result;
//   });
// }
//
// static Future<dynamic> handler(String url) async {
// final response = await http.get(Uri.parse(url));
// final json = jsonDecode(response.body);
//
// return json['results'][0]['email'];
// }
loginErrorDialog({context, String titleText, String contentText}) {
  ///오류 발생시 알려줌.
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(titleText),
          content: new Text(contentText),
          actions: <Widget>[
            new TextButton(
              child: new Text("확인"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}
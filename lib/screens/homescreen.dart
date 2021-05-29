import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _startDate, _endDate;
  List<Uint8List> imageList = [];
  List<AssetPathEntity> pathList = [];
  int pageCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Memories",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Re-live your travel memories",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        DateTime? startDate =
                            await pickedDate(_startDate ?? DateTime.now());
                        setState(() {
                          _startDate = startDate;
                        });
                      },
                      child: Text(
                        _startDate == null
                            ? "Pick Start Date"
                            : "${_startDate!.day}-${_startDate!.month}-${_startDate!.year}",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? endDate =
                            await pickedDate(_endDate ?? DateTime.now());
                        setState(() {
                          _endDate = endDate;
                        });
                      },
                      child: Text(
                        _endDate == null
                            ? "Pick End Date"
                            : "${_endDate!.day}-${_endDate!.month}-${_endDate!.year}",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: loadPhotos,
                    child: Text("Show Photos"),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Photos:",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15.0,
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: imageList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      crossAxisCount: 4),
                  itemBuilder: (context, index) => Container(
                    color: Colors.grey[200],
                    child: Image.memory(
                      imageList[index],
                    ),
                  ),
                ),
                //If no images , then dont display the show more button
                if (imageList.isNotEmpty)
                  Center(
                    child: TextButton(
                      child: Text("Load more"),
                      onPressed: loadMore,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> pickedDate(DateTime initial) async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(DateTime.now().year - 20),
        lastDate: DateTime(DateTime.now().year + 20));
    return date;
  }

  Future<List<AssetPathEntity>> getPathList() async {
    // Request storage permission if not granted
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      //  Get all of asset list (gallery)

      List<AssetPathEntity> pathList = [];
      pathList = await PhotoManager.getAssetPathList(
          onlyAll: true,
          type: RequestType.common,
          filterOption: FilterOptionGroup(
              createTimeCond: DateTimeCond(
                  max: _endDate!.add(Duration(days: 1)), min: _startDate!)));
      return pathList;
    } else {
      Fluttertoast.showToast(msg: "Permisson required!");
      PhotoManager.openSetting();
      return [];
    }
  }

  Future<List<Uint8List>> getThumbList(
      List<AssetPathEntity> pathList, int pageCount) async {
    // Get asset list from AssetPathEntity in form of thumbnail
    // page: The page number of the page, starting at 0.
    // perPage: The number of pages per page.

    List<Uint8List> thumbs = [];
    int perPage = 100;
    // Loop through to the path list from page which aren't loaded i.e from pageCount
    for (var page = pageCount; page <= pageCount; page++) {
      final assets = await pathList[0].getAssetListPaged(page, perPage);
      for (AssetEntity asset in assets) {
        Uint8List? thumb = await asset.thumbData;
        thumbs.add(thumb!);
      }
    }
    return thumbs;
  }

  void loadMore() async {
    int _pageCount = pageCount + 1;
    // Get thumb list of next page
    List<Uint8List> thumbList = await getThumbList(this.pathList, _pageCount);

    // if next page if empty
    if (thumbList.isEmpty) {
      Fluttertoast.showToast(msg: "No more images to load");
    } else {
      // add unloaded data from next page to imageList to display
      setState(() {
        this.pageCount = pageCount + 1;
        this.imageList.addAll(thumbList);
      });
    }
  }

  void loadPhotos() async {
    if (_startDate == null || _endDate == null) {
      // If dates are null, dont load photos
      Fluttertoast.showToast(msg: "Pick date first");
    } else {
      // Else fetch and add thumbnail of photos to the image list
      // Empty the list when there are date changes to avoid incorrect data
      this.imageList = [];
      // Set page Count to zero again when there are date changes to avoid incorrect data
      int pgCount = 0;
      this.pathList = await getPathList();
      if (this.pathList.isEmpty) {
        Fluttertoast.showToast(msg: "No images to show");
        setState(() {
          this.pageCount = pgCount;
          this.imageList = [];
        });
      } else {
        List<Uint8List> thumbList = await getThumbList(this.pathList, pgCount);

        setState(() {
          this.pageCount = pgCount;
          this.imageList = thumbList;
        });
      }
    }
  }
}

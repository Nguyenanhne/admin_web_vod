import 'package:admin/viewmodel/ffmpeg_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
class FFMPEGPAGE extends StatefulWidget {
  const FFMPEGPAGE({super.key});

  @override
  State<FFMPEGPAGE> createState() => _FFMPEGPAGEState();
}

class _FFMPEGPAGEState extends State<FFMPEGPAGE> {
  final contentStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: GoogleFonts.roboto().fontFamily
  );
  final labelStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
      fontFamily: GoogleFonts.roboto().fontFamily
  );
  final titleStyle = TextStyle(
      fontSize: 25,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.roboto().fontFamily
  );
  @override
  void initState() {
    final ffmpegVM = Provider.of<FfmpegViewModel>(context, listen: false);
    ffmpegVM.reset();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text("FFmegp", style: titleStyle),
                  Expanded(child: SizedBox())
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vui lòng chọn: ", style: labelStyle),
                  Consumer<FfmpegViewModel>(
                    builder: (context, ffmpegVM, child){
                      return TextButton(
                        onPressed: () {
                          ffmpegVM.videoOnTap();
                        },
                        child: Text(
                          "Video",
                          style: TextStyle(
                            color: ffmpegVM.isVideo? Colors.blue : Colors.white,
                            fontWeight: ffmpegVM.isVideo? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }
                  ),
                  Consumer<FfmpegViewModel>(
                    builder: (context, ffmpegVM, child) {
                  return TextButton(
                    onPressed: () {
                      ffmpegVM.trailerOnTap();
                    },
                    child: Text(
                      "Trailer",
                      style: TextStyle(
                        color: ffmpegVM.isTrailer? Colors.blue : Colors.white,
                        fontWeight: ffmpegVM.isTrailer? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
            Consumer<FfmpegViewModel>(
              builder: (context, viewmodel, child) {
                return viewmodel.isVideo ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Độ phân giải: ", style: labelStyle),
                      Expanded(
                        child: Consumer<FfmpegViewModel>(
                          builder: (context, ffmpegVM, child) {
                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: ffmpegVM.resolutions.map((res) {
                                bool isSelected = ffmpegVM.selectedResolutions.contains(res);
                                return ChoiceChip(
                                  label: Text(
                                    "${res}p",
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.grey[300],
                                  onSelected: (selected) {
                                    ffmpegVM.toggleResolution(res);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox.shrink();
              }
            ),
            SizedBox(height: 16),
            Consumer<FfmpegViewModel>(
              builder: (context, ffmpegVM, child) {
                return ffmpegVM.isProcess
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Đang tiến hành xử lý video, vui lòng không tắt!"),
                      ),
                      CircularProgressIndicator()
                    ]
                   )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: (){
                          ffmpegVM.pickFileOnTap();
                        },
                        icon: Icon(Icons.folder)),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: TextFormField(
                            enabled: false,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis
                            ),
                            controller: ffmpegVM.pathController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder()
                            ),
                            maxLines: 1,
                          ),
                        )
                      ),
                      IconButton(
                        onPressed: () async {
                          ffmpegVM.uploadToServerOnTap(context);
                        },
                        icon: Icon(Icons.upload)
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  );
              }
            )
          ],
        ),
      ),
    );
  }
}

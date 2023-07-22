import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sail/constant/app_colors.dart';
import 'package:sail/models/app_model.dart';
import 'package:sail/models/server_model.dart';
import 'package:flutter/material.dart';
import 'package:sail/utils/common_util.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({Key? key}) : super(key: key);

  @override
  ServerListPageState createState() => ServerListPageState();
}

class ServerListPageState extends State<ServerListPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late AppModel _appModel;
  late ServerModel _serverModel;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _appModel = Provider.of<AppModel>(context);
    _serverModel = Provider.of<ServerModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
        child: _contentWidget(),
      ),
    );
  }

  Widget _contentWidget() {
    if (_serverModel.serverEntityList.isEmpty) {
      return _emptyWidget();
    }

    return _serversContainerWidget();
  }

  Widget _emptyWidget() {
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(1080),
        height: ScreenUtil().setWidth(200),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(75), vertical: ScreenUtil().setWidth(0)),
        child: Material(
          elevation: _appModel.isOn ? 3 : 0,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
          color: _appModel.isOn ? Colors.white : AppColors.darkSurfaceColor,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              '节点列表为空，请确认是否已经订阅',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setWidth(40),
                  color: _appModel.isOn ? Colors.black : Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _serversContainerWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
                text: TextSpan(
                    text: '请选择 ',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: _appModel.isOn ? AppColors.grayColor : Colors.white),
                    children: [
                  TextSpan(
                      text: '节点',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.normal, color: _appModel.isOn ? AppColors.grayColor : Colors.white))
                ])),
            InkWell(
              onTap: _serverModel.pingAll,
              child: Text("Ping",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal, color: _appModel.isOn ? AppColors.grayColor : Colors.white)),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: _serverListWidget(),
        )
      ],
    );
  }

  Widget _tagsWidget(List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      return Container();
    }

    for (var i = 0; i < tags.length; i++) {
      tags[i] = tags[i].replaceAll(' ', '');
      if (tags[i].isEmpty) {
        tags.removeAt(i);
      }
    }

    var tagsWidget = tags
        .map((tag) => Chip(
            backgroundColor: AppColors.themeColor,
            padding: const EdgeInsets.all(5),
            label: Text(
              tag,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            )))
        .toList();

    return Row(
      children: tagsWidget,
    );
  }

  Widget _serverListWidget() {
    return ListView.separated(
      controller: ModalScrollController.of(context),
      physics: const ClampingScrollPhysics(),
      itemCount: _serverModel.serverEntityList.length,
      itemBuilder: (_, index) => InkWell(
        onTap: () {
          _serverModel.setSelectServerEntity(_serverModel.serverEntityList[index]);
          _serverModel.setSelectServerIndex(index);
          _appModel.setConfigRule(_serverModel.serverEntityList[index].name);
        },
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color:
          _serverModel.selectServerIndex == index ? Theme.of(context).highlightColor : Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(10),
                    ),
                    CircleAvatar(
                      radius: ScreenUtil().setWidth(10),
                      backgroundColor: (DateTime.now().microsecondsSinceEpoch / 1000000 -
                          (int.parse(_serverModel.serverEntityList[index].lastCheckAt)) <
                          60 * 10)
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _serverModel.serverEntityList[index].name,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        _tagsWidget(_serverModel.serverEntityList[index].tags),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    _serverModel.serverEntityList[index].ping != null
                        ? Container(
                      padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                      child: Text(
                        _serverModel.serverEntityList[index].ping!.inSeconds > 10
                            ? '超时'
                            : "${_serverModel.serverEntityList[index].ping!.inMilliseconds}ms",
                        style: TextStyle(
                            color: _serverModel.serverEntityList[index].ping!.inSeconds > 10
                                ? Colors.red
                                : Colors.green),
                      ),
                    )
                        : Container(),
                    InkWell(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
                      onTap: () => _serverModel.ping(index),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(10), horizontal: ScreenUtil().setWidth(30)),
                          child: Text(
                            'ping',
                            style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.w500),
                          )),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      separatorBuilder: (_, index) => const SizedBox(height: 10),
    );
  }
}

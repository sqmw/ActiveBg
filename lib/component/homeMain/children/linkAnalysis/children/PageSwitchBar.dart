import 'package:active_bg/component/homeMain/children/linkAnalysis/children/PageSwitchController.dart';
import 'package:flutter/material.dart';

/// 只能是真正的页码变化的时候才进行切换
class PageSwitchBar extends StatefulWidget {
  const PageSwitchBar({Key? key, required this.pageSwitchController, required this.onPageIndexChange}):super(key: key);
  final PageSwitchController pageSwitchController;
  /// 参数为变化之后的 pageIndex
  final void Function(int index) onPageIndexChange;

  @override
  State<PageSwitchBar> createState() => _PageSwitchBarState();
}

class _PageSwitchBarState extends State<PageSwitchBar> {

  @override
  void initState() {
    super.initState();
    widget.pageSwitchController.stateOwner = this;
  }
  @override
  Widget build(BuildContext context) {
    /// 页面切换逻辑已经完成 switchBar 的
    return Row(
      children: [
        /// 首页
        IconButton(
            onPressed: (){
              if(widget.pageSwitchController.currentPageIndex == 1){
                return;
              }
              setState(() {
                widget.pageSwitchController.currentPageIndex = 1;
                widget.onPageIndexChange(widget.pageSwitchController.currentPageIndex);
              });
            },
            icon: const Icon(Icons.first_page)
        ),
        /// 上一页
        IconButton(
          onPressed: (){
            if(widget.pageSwitchController.currentPageIndex <= 1){
              return;
            }
            setState(() {
              widget.pageSwitchController.currentPageIndex -= 1;
              widget.onPageIndexChange(widget.pageSwitchController.currentPageIndex);
            });
          },
          icon: const Icon(Icons.navigate_before),
        ),
        /// 当前页
        Text("${widget.pageSwitchController.currentPageIndex}/"),
        /// 页总数
        Text("${widget.pageSwitchController.countAllPages}",style: const TextStyle(color: Colors.red)),
        /// 下一页
        IconButton(
          onPressed: (){
            if(widget.pageSwitchController.currentPageIndex
                >= (widget.pageSwitchController.count / widget.pageSwitchController.countEachPage).ceil()){
              return;
            }
            setState(() {
              widget.pageSwitchController.currentPageIndex += 1;
              widget.onPageIndexChange(widget.pageSwitchController.currentPageIndex);
            });
          },
          icon: const Icon(Icons.navigate_next),
        ),
        /// 最后一页
        IconButton(
            onPressed: (){
              if(widget.pageSwitchController.currentPageIndex == (widget.pageSwitchController.count / widget.pageSwitchController.countEachPage).ceil()){
                return;
              }
              setState(() {
                widget.pageSwitchController.currentPageIndex = (widget.pageSwitchController.count / widget.pageSwitchController.countEachPage).ceil();
                widget.onPageIndexChange(widget.pageSwitchController.currentPageIndex);
              });
            },
            icon: const Icon(Icons.last_page)
        ),
      ],
    );
  }


}

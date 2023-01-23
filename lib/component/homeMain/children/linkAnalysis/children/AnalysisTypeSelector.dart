import 'package:flutter/material.dart';


/// 下拉选择框
/// 已经封装好了，基本不用管
class AnalysisTypeSelector extends StatefulWidget {
  const AnalysisTypeSelector({super.key,required this.onChangeFatherDo, required this.data});
  final void Function() onChangeFatherDo;
  final Map<String, dynamic> data;

  @override
  State<AnalysisTypeSelector> createState() => _AnalysisTypeSelectorState();
}

class _AnalysisTypeSelectorState extends State<AnalysisTypeSelector> {
  late String dropdownValue ;
  @override
  void initState() {
    super.initState();
    dropdownValue = widget.data["options"].keys.first;
  }

  @override
  Widget build(BuildContext context) {
    /// 通过container实现自定义的ComboBox的自定义样式
    return Container(
      margin: const EdgeInsets.fromLTRB(5,5,20,5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.deepPurple,
          width: 2
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5))
      ),
      child: DropdownButton<String>(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        isExpanded: true,
        value: dropdownValue,
        underline: Container(color: Colors.white),
        icon: const Icon(Icons.arrow_downward),
        style: const TextStyle(color: Colors.deepPurple),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
            widget.onChangeFatherDo();
            widget.data["index"] = widget.data["options"][value];
          });
        },
        items: widget.data["options"].keys.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

}

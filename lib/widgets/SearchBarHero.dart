import 'package:flutter/material.dart';

class SearchBarHero extends StatelessWidget {
  final Object tag;
  final TextEditingController? controller;
  final void Function()? onTap;
  final BoxConstraints? constraints;
  final MaterialStateProperty<Color>? shadowColor;
  final String? hintText;
  final void Function(String)? onSubmitted;
  const SearchBarHero(
      {super.key,
      this.tag = "SearchBarHero",
      this.controller,
      this.onTap,
      this.constraints,
      this.shadowColor,
      this.hintText,this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: SearchBar(
        trailing: [Icon(Icons.search)],
        onTap: onTap,
        constraints: constraints,
        padding: MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16)),
        hintText: hintText,
        shadowColor: shadowColor,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

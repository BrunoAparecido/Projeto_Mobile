import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final bool isPassword;
  final TextEditingController controller;

  CustomInputField({
    super.key,
    required this.label,
    this.isPassword = false,
    required this.controller,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool estaVazio = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: _isFocused ? Color.fromARGB(255, 229, 230, 230) : Color.fromARGB(255, 236, 238, 238),
          border: UnderlineInputBorder(
            borderSide: BorderSide( 
              color: estaVazio ? Colors.red : Colors.black54,
            ),
          ),
          labelText: widget.label, labelStyle: TextStyle(color: estaVazio ? Colors.red : Colors.black54),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: estaVazio
                  ? Colors.red
                  : const Color.fromARGB(255, 15, 135, 233),
            ),
          ),
        ),
        onChanged: (text) {
          setState(() {
            estaVazio = text.isEmpty;
          });
        },
        onTap: () {
          setState(() {
            estaVazio = widget.controller.text.isEmpty;
          });
        },
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
  });
  final String label;
  final TextEditingController controller;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  bool estaVazio = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: _isFocused ? Color.fromARGB(255, 229, 230, 230) : Color.fromARGB(255, 236, 238, 238),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: estaVazio ? Colors.red : Colors.black54,
            ),
          ),
          labelText: widget.label, labelStyle: TextStyle(color: estaVazio ? Colors.red : Colors.black54),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: estaVazio
                  ? Colors.red
                  : const Color.fromARGB(255, 15, 135, 233),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility
                  : Icons.visibility_off, // Change icon based on visibility
            ),
            onPressed: _togglePasswordVisibility, // Toggle visibility on press
          ),
        ),
        onChanged: (text) {
          setState(() {
            estaVazio = text.isEmpty;
          });
        },
        onTap: () {
          setState(() {
            estaVazio = widget.controller.text.isEmpty;
          });
        },
      ),
    );
  }
}

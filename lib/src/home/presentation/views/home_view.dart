import 'package:flutter/material.dart';
import 'package:subby/src/home/presentation/widgets/cidr_field.dart';
import 'package:subby/src/home/presentation/widgets/octet_field.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<TextEditingController> _addressControllers = List.generate(
    4,
    (_) => TextEditingController(text: '\u200B'),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final cidrPrefixController = TextEditingController();
  final cidrPrefixFocusNode = FocusNode();

  int _getOctetValue(TextEditingController octetController) {
    return int.parse(octetController.text.trim().replaceAll('\u200B', ''));
  }

  @override
  void dispose() {
    for (var i = 0; i < _addressControllers.length; i++) {
      _focusNodes[i].dispose();
      _addressControllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const .all(16),
          child: Center(
            child: Column(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              spacing: 20,
              children: [
                Form(
                  key: _formKey,
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: .center,
                        mainAxisSize: .min,
                        spacing: 10,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const OutlineInputBorder().borderRadius,
                            ),
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: .zero,
                              scrollDirection: .horizontal,
                              shrinkWrap: true,
                              itemCount: 4,
                              separatorBuilder: (_, index) {
                                return const Center(child: Text('.'));
                              },
                              itemBuilder: (_, index) {
                                final controller = _addressControllers[index];
                                final focusNode = _focusNodes[index];
                                final nextFocusNode = index == 3
                                    ? null
                                    : _focusNodes[index + 1];
                                final previousFocusNode = index == 0
                                    ? null
                                    : _focusNodes[index - 1];

                                return OctetField(
                                  key: ValueKey(index),
                                  controller: controller,
                                  focusNode: focusNode,
                                  nextFocusNode: nextFocusNode,
                                  previousFocusNode: previousFocusNode,
                                );
                              },
                            ),
                          ),
                          const Text(
                            '/',
                            style: TextStyle(fontSize: 30),
                          ),
                          CidrField(
                            controller: cidrPrefixController,
                            focusNode: cidrPrefixFocusNode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    _formKey.currentState!.validate();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

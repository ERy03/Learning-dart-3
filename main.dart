import 'dart:convert';
import 'package:flutter/material.dart';

// Document class
// Mock of a JSON data
class Document {
  final Map<String, Object?> _json;
  Document() : _json = jsonDecode(documentJson);

  // Creating and returning a record (adding a new getter method)
  // The first field (String) is positional / unnamed while the second field (DateTime) is named modified
  (String, {DateTime modified}) get metadata {
    // if-case. The case body only executes if the case pattern matches the data in _json
    if (_json                                                
        case {
          'metadata': {
            'title': String title,
            'modified': String localModified,
          }
        }) {
      // The return type of this function is a record with twho fields: a String and a DateTime
      // Enclose the two values in parenthesis to construct a new record
      return (title, modified: DateTime.parse(localModified));
    } else {
      throw const FormatException('Unexpected JSON');
    }                                                        
  }
  
  List<Block> getBlocks() {                                  
    if (_json case {'blocks': List blocksJson}) {
      return [for (final blockJson in blocksJson) Block.fromJson(blockJson)];
    } else {
      throw const FormatException('Unexpected JSON format');
    }
  }                                    
}

// sealed Block class
sealed class Block {
  Block();

  factory Block.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'type': 'h1', 'text': String text} => HeaderBlock(text),
      {'type': 'p', 'text': String text} => ParagraphBlock(text),
      {'type': 'checkbox', 'text': String text, 'checked': bool checked} =>
        CheckboxBlock(text, checked),
      _ => throw const FormatException('Unexpected JSON format'),
    };
  }
}

class HeaderBlock extends Block {
  final String text;
  HeaderBlock(this.text);
}

class ParagraphBlock extends Block {
  final String text;
  ParagraphBlock(this.text);
}

class CheckboxBlock extends Block {
  final String text;
  final bool isChecked;
  CheckboxBlock(this.text, this.isChecked);
}

const documentJson = '''
{
  "metadata": {
    "title": "My Document",
    "modified": "2023-05-10"
  },
  "blocks": [
    {
      "type": "h1",
      "text": "Chapter 1"
    },
    {
      "type": "p",
      "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    },
    {
      "type": "checkbox",
      "checked": true,
      "text": "Learn Dart 3"
    }
  ]
}
''';

void main() {
  runApp(const DocumentApp());
}

class DocumentApp extends StatelessWidget {
  const DocumentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: DocumentScreen(
        document: Document(),
      ),
    );
  }
}

class BlockWidget extends StatelessWidget {
  final Block block;

  const BlockWidget({
    required this.block,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: switch (block) {
        HeaderBlock(:final text) => Text(
            text,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ParagraphBlock(:final text) => Text(text),
        CheckboxBlock(:final text, :final isChecked) => Row(
            children: [
              Checkbox(value: isChecked, onChanged: (_) {}),
              Text(text),
            ],
          ),
      },
    );
  }
}

String formatDate(DateTime dateTime) {
  final today = DateTime.now();
  final difference = dateTime.difference(today);

  return switch (difference) {
    Duration(inDays: 0) => 'today',
    Duration(inDays: 1) => 'tomorrow',
    Duration(inDays: -1) => 'yesterday',
      // use of guard clauses
    Duration(inDays: final days) when days > 7 => '${days ~/ 7} weeks from now', // Add from here
    Duration(inDays: final days) when days < -7 && days > -14 =>
      '${days.abs() ~/ 7} week ago',       
    Duration(inDays: final days) when days < -7 =>
      '${days.abs() ~/ 7} weeks ago',                                            // to here.
    Duration(inDays: final days, isNegative: true) => '${days.abs()} days ago',
    Duration(inDays: final days) => '$days days from now',
  };
}


// Document Screen
class DocumentScreen extends StatelessWidget {
  final Document document;

  const DocumentScreen({
    required this.document,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Calling the metadata getter method in order to get the records and access the values by assigning it to metadataRecord
    // final metadataRecord = document.metadata;
    // same as (title, modified: modified)
    final (title, :modified) = document.metadata;
    final blocks = document.getBlocks();
    final formattedModifiedDate = formatDate(modified);   

    return Scaffold(
      appBar: AppBar(
        // Access a positional (unnamed) field by using the getter $<num>
        title: Text(
          //metadataRecord.$1
          title,
        ),
      ),
      body: Column(
        children: [
          Text('Last modified: $formattedModifiedDate'),                        
          Expanded(
            child: ListView.builder(
              itemCount: blocks.length,
              itemBuilder: (context, index) {
                return BlockWidget(block: blocks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
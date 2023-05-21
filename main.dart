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

/*
 Learning points: 
 
 > Why use records? 
 You can define a class to return different types of data in a type-safe way but that can be more verbose in some cases
 
 > How to create a record: 
   (String, {DateTime modified}) get metadata {
      const title = 'My Document'; 
      final now = DateTime.now();
    
      return (title, modified: now);
    }
    
    Record fields can contain both named and positonal fields
 
 > How to access record fields
    final metadataRecord = document.metadata;
    metadataRecord.$1
    metadataRecord.modified
   
   Use getter $<num> on positional fields
   Use the name directly for named fields
   
   ? $<num> starts at $1 and skips named fields
   ex. 
    var record = (named: 'a', 'b', named2: 'c', 'd');
    print(record.$1); // prints b
    print(record.$2); // prints d
 
 > What are patterns?
 They represent a structure that one or more values can take. They are like blueprints that compare against the actual values to determine if they match. If they match, the record values are binded to a new local variable of the same types and names.
 
  Instead of this
    final metadataRecord = document.metadata;
  do this
    final (title, modified: modified) = document.metadata;
 
 > Using patterns
  final (title, modified: localVariableName) = document.metadata;
  
    Text(title)
    'Last modified $localVariableName'
   
  If the name of the field and the variable populating it are the same, you can used a shorthand
    :modified // same as modified: modified
    
 > Types of patterns
  - Refutable:
    Used in control flow context
      They expect that some values they compare against will not match
      They don't interrupt execution with an error if they don't match, just moves to the next statement
      They can destructure and bind variables that are only usable when they match
      
  - Irrefutable:
    Values must match the pattern. If not, it will be considered an error and destructuring will not occur
  
 > Usesace of Refutable patterns
 Reading JSON values without patterns: 
 
  class Document {
    final Map<String, Object?> _json;
    Document() : _json = jsonDecode(documentJson);

    (String, {DateTime modified}) get metadata {
      if (_json.containsKey('metadata')) {                     
        final metadataJson = _json['metadata'];
        if (metadataJson is Map) {
          final title = metadataJson['title'] as String;
          final localModified =
              DateTime.parse(metadataJson['modified'] as String);
          return (title, modified: localModified);
        }
      }
      throw const FormatException('Unexpected JSON');          
    }
  }
  
  With patterns:
  
    class Document {
    final Map<String, Object?> _json;
    Document() : _json = jsonDecode(documentJson);

    (String, {DateTime modified}) get metadata {
      if (_json                                                
          case {
            'metadata': {
              'title': String title,
              'modified': String localModified,
            }
          }) {
        return (title, modified: DateTime.parse(localModified));
      } else {
        throw const FormatException('Unexpected JSON');
      }                                                        
    }
  }
  
  This is the new if-case introduced in Dart3.
  The case body only executes if the case pattern matches the data in _json
  
  This checks
    - _json is a Map type.
    - _json contains a metadata key.
    - _json is not null.
    - _json['metadata'] is also a Map type.
    - _json['metadata'] contains the keys title and modified.
    - title and localModified are strings and aren't null.
   
   If the value doesn't match, the pattern refuses to continue execution and proceeds to the else clause.
  
 > Switch statements
 As of Dart 3, switch statements do not require break 
 
 > Switch expressions
 Instead of this 
    switch (block.type) {
      case 'h1':
        textStyle = Theme.of(context).textTheme.displayMedium;
      case 'p' || 'checkbox':
        textStyle = Theme.of(context).textTheme.bodyMedium;
      case _:
        textStyle = Theme.of(context).textTheme.bodySmall;
    }
 do this 
    textStyle = switch (block.type) {
      'h1' => Theme.of(context).textTheme.displayMedium,
      'p' || 'checkbox' => Theme.of(context).textTheme.bodyMedium,
      _ => Theme.of(context).textTheme.bodySmall
    }; 

  You can provide values directly to a variable.
  Unlike switch statements, switch expressions return a value and can be used anywhere an expression can be used
  
  > Guard clauses
    A guard clause uses the when keyword after a case pattern.
    They can be used in if-cases, switch statements, and switch expressions.
    They only add a condition to a pattern after it's matched.
    If the guard clause evaluates to false, the entire pattern is refuted, and execution proceeds to the next case.
    
  > Exhaustive Switching
    When every case in a switch is handled it's called an exhaustive switch
    
    Dart 3 extended exhaustiveness checking to objects and class hierarchies with the new class modifier sealed
    
  > Sealed 
  Instead of this 
    class Block {
      final String type;
      final String text;
      Block(this.type, this.text);

      factory Block.fromJson(Map<String, dynamic> json) {
        //Map patterns ignore any entries in the map object that aren't explicitly accounted for in the pattern.
        if (json case {'type': final type, 'text': final text}) {
          return Block(type, text);
        } else {
          throw const FormatException('Unexpected JSON format');
        }
      }
    }
  do this 
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
  
  The sealed keyword is a class modifier that means you can only extend or implement this class in the same library.
  
  > More info
  https://medium.com/dartlang/announcing-dart-3-53f065a10635
 */

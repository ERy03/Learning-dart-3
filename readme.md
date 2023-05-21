# Dart 3 Learning

Created with <3 with [dartpad.dev](https://dartpad.dev).


 Learning points: 
 
 ### Why use records? 
 You can define a class to return different types of data in a type-safe way but that can be more verbose in some cases
 
 ### How to create a record:

   (String, {DateTime modified}) get metadata {
      const title = 'My Document'; 
      final now = DateTime.now();
      return (title, modified: now);
    }
    
 Record fields can contain both named and positonal fields
 
 ### How to access record fields
 
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
 
 ### What are patterns?
 
 They represent a structure that one or more values can take. They are like blueprints that compare against the actual values to determine if they match. If they match, the record values are binded to a new local variable of the same types and names.
 
  Instead of this
    final metadataRecord = document.metadata;
  do this
    final (title, modified: modified) = document.metadata;
 
 ### Using patterns
  final (title, modified: localVariableName) = document.metadata;
  
    Text(title)
    'Last modified $localVariableName'
   
  If the name of the field and the variable populating it are the same, you can used a shorthand
    :modified // same as modified: modified
    
 ### Types of patterns
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
 
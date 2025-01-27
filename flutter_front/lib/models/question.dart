Map<String, dynamic> toJson() {
  print('Question: Converting to JSON');
  print('Question: Text: $text');
  print('Question: Choices: $choices');
  print('Question: Correct choice index: $correctChoiceIndex');
  
  final json = {
    'text': text,
    'choices': List.generate(choices.length, (index) => {
      'text': choices[index],
      'is_correct': index == correctChoiceIndex,
    }),
    'order': 0, // Sera défini par le backend
  };
  
  print('Question: Generated JSON: $json');
  return json;
} 
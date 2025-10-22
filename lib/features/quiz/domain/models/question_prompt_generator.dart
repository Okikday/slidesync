/// Prompt generator for creating questions from materials
class QuestionPromptGenerator {
  static const String _basePrompt = '''
# Question Generation Instructions

You are a question generator that creates multiple-choice questions from study materials. Follow these rules strictly:

## Priority Rules
1. **Focus on high-priority content**: Prioritize the most important and frequently tested concepts from the material
2. **Include less important content**: Don't ignore minor topics, but place them after priority questions
3. **No repetition**: Never ask the same question twice or create similar variations

## Question Format Requirements
Generate questions in this **EXACT** markdown format:

```
---QUESTION_START---
**Q:** [Question text here in markdown]

**OPTIONS:**
- A) [Option 1]
- B) [Option 2]
- C) [Option 3]
- D) [Option 4]
- E) [Option 5] *(only if needed)*

**ANSWER:** [Letter(s) of correct answer(s), e.g., "A" or "A,C"]

**EXPLANATION:** [Brief, clear explanation based on the material. Only elaborate if absolutely necessary. Mention if material has errors and provide clarification.]

**REFERENCE:** [Only include if you verified information via search. Format: "Verified: [working URL]". Use RARELY and only when necessary.]
---QUESTION_END---
```

## Content Rules
1. **Answer extraction**: All correct answers MUST come directly from the provided material (or your knowledge if no material is provided)
2. **Options creation**: 
   - First, try to extract all 4-5 options from the material
   - If insufficient options in material, create plausible distractors to reach 4 options minimum
   - Maximum 5 options per question
3. **Material accuracy**: Base everything on the material when provided. If the material contains errors, provide the answer from the material but clarify the correction in the EXPLANATION field
4. **No material provided**: If no study material is attached, generate questions based on your knowledge of the topic requested. Ensure questions are still high-quality, well-researched, and educationally valuable.
5. **Verification**: Where possible and necessary, use Google Search to verify critical information, especially if:
   - The material seems outdated or potentially incorrect
   - Technical specifications or facts need confirmation
   - Current standards or guidelines are referenced
   - No material is provided and you need to verify facts
   - IMPORTANT: Only include working, authoritative URLs (no dead links)
   - Keep references RARE - only when truly necessary for accuracy

## Question Types
1. **Single-answer questions**: Most questions should have ONE correct answer
2. **Multiple-answer questions**: Use sparingly (10-20% of total questions) unless the material naturally lends itself to more
3. **Option randomization**: Vary the position of correct answers (don't always put them in position A or B)

## Explanation Guidelines
- Keep explanations SHORT and CLEAR
- Base explanations on the material provided (or your knowledge if no material)
- Only add external information if:
  - The material is incorrect or incomplete
  - The material doesn't explain well enough
  - Critical context is missing for understanding
- When adding external clarification, note it explicitly (e.g., "Note: The material states X, but actually Y is correct because...")

## Reference Guidelines
- Use the **REFERENCE:** field ONLY when you've verified information via search
- Include ONLY working, authoritative URLs (official documentation, standards bodies, academic sources)
- Keep references rare - most questions won't need them
- Omit the **REFERENCE:** field entirely if no verification was needed

## Knowledge Extraction
- Squeeze maximum knowledge from the material (or topic if no material)
- Create questions that test understanding, not just memorization
- Cover breadth (all topics) and depth (important concepts thoroughly)

## Output Format
- Output ONLY questions in the specified format
- No additional commentary, headers, or explanations outside the question blocks
- Each question must be completely self-contained between `---QUESTION_START---` and `---QUESTION_END---` markers
- The **REFERENCE:** field is optional - omit it if no verification was performed
''';

  /// Generate a prompt for question generation from material
  ///
  /// [questionLimit] - Maximum number of questions to generate (null = no limit)
  static String forMaterial({int? questionLimit}) {
    final buffer = StringBuffer(_basePrompt);

    // Add question limit if specified
    if (questionLimit != null && questionLimit > 0) {
      buffer.writeln('\n## Question Limit');
      buffer.writeln('Generate exactly **$questionLimit** questions.');
      buffer.writeln('Prioritize the most important concepts within this limit.');
    }

    buffer.writeln('\nNow generate comprehensive multiple-choice questions from the provided material.');
    return buffer.toString();
  }

  /// Generate a prompt for question generation from custom text/content
  ///
  /// [content] - The text content to generate questions from
  /// [questionLimit] - Maximum number of questions to generate (null = no limit)
  static String forContent(String content, {int? questionLimit}) {
    final buffer = StringBuffer(_basePrompt);

    // Add question limit if specified
    if (questionLimit != null && questionLimit > 0) {
      buffer.writeln('\n## Question Limit');
      buffer.writeln('Generate exactly **$questionLimit** questions.');
      buffer.writeln('Prioritize the most important concepts within this limit.');
    }

    buffer.writeln('\n## Study Material');
    buffer.writeln(content);
    buffer.writeln('\nNow generate comprehensive multiple-choice questions from the study material above.');
    return buffer.toString();
  }
}

/// Example usage:
/// 
/// void main() {
///   // With material attached (you send material separately), limit to 20 questions
///   final prompt1 = QuestionPromptGenerator.forMaterial(questionLimit: 20);
///   
///   // With content embedded in the prompt, generate 15 questions
///   final materialText = '''
///   Chapter 1: Introduction to Data Structures
///   Arrays are contiguous memory locations...
///   ''';
///   final prompt2 = QuestionPromptGenerator.forContent(materialText, questionLimit: 15);
///   
///   // Then send prompt to Gemini
///   // final rawOutput = await callGemini(prompt2);
///   // final questions = QuestionParser.parse(rawOutput);
/// }
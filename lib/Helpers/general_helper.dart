import '../Core/Vars/enums.dart';

class GeneralHelper {
  static String capitalizeFirstCharacter(String text) {
    if (text.isEmpty) {
      return text; // Return an empty string if the input is empty
    }

    String firstChar = text[0].toUpperCase(); // Get the first character and convert it to uppercase
    String remainingText = text.substring(1); // Get the remaining text starting from index 1

    return '$firstChar$remainingText'; // Concatenate the first character and the remaining text
  }

  static List<String> formActionList(List<AppAction> actions) {
    List<String> actionList = [];
    for (var action in actions) {actionList.add(capitalizeFirstCharacter(action.name)); }
    return actionList;
  }
}
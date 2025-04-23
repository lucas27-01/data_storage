extension StringExtension on String {
  String substringLength(int maxLength){
    /// Return a string with a provided maximum lenth [maxLength]
    /// If the string is smaller than [maxLength] then return the same string
    /// else return the substring starting with zero and with and ending "..."
    
    if (length > maxLength){
      return "${substring(0, maxLength)}...";
    }
    return this;
  }
}
class Alerts {
  static AlertText noPath = AlertText(
    title: "Error Loading Offline Data", 
    content: "Kunde inte hitta någon lokalt sparad data", 
    button: "Använd standarddata"
  );
  static AlertText wrongPlatform = AlertText(
    title: "Error Loading Offline Data", 
    content: "This software has not been configured to store locally on this platform", 
    button: "Använd standarddata"
  );
  static AlertText jsonError(Object e) {
    return AlertText(
      title: "Unexpected json Error", 
      content: e.toString(), 
      button: "Använd standarddata"
    );
  }
  static AlertText apiError(Object e) {
    return AlertText(
      title: "Could not call api", 
      content: e.toString(), 
      button: "Kör offline"
    );
  }
  static AlertText collitions = AlertText(
    title: "Överlappande händelser", 
    content: "Det finns överlappande händelser. Du kan få upp en lista från huvudmenyn. Åtgärda snarast", 
    button: "Fortsätt",
  );
  static AlertText noCollitions = AlertText(
    title: "Inga överlappande händelser", 
    content: "Allt ser ut som det ska", 
    button: "Fortsätt",
  );
  static AlertText noUnreachable = AlertText(
    title: "Inga försvunna händelser", 
    content: "Allt ser ut som det ska", 
    button: "Fortsätt",
  );
  static AlertText badDate = AlertText(
    title: "Ej tillåtet datum", 
    content: "Det är inte tillåtet att välja ett framtida datum", 
    button: "Avbryt",
  );
}

final class AlertText {
  String title;
  String content;
  String button;

  AlertText({
    required this.title, 
    required this.content, 
    required this.button
  });
}
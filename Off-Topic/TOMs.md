# B.3 Technische und Organisatorische Maßnahmen

*Detailliertere Angaben als im Punkt 9 des Verzeichnisses der       Verarbeitungstätigkeiten*

## B.3.1 Zugangskontrolle
*Maßnahmen durch die Unbefugten der Zugang zu den Verarbeitungsanlagen verwehrt wird*

- Siehe Konzepte „Zugang zu den Maschinenräumen"

## B.3.2 Datenträgerkontrolle
*Maßnahmen dagegen, dass Datenträger unbefugt gelesen, kopiert, verändert oder entfernt werden können*

- Die Server befinden sich in gesicherten/abgeschlossenen Maschinenräumen. Ausschließlich dedizierte Administratoren-Accounts sind für den Remote-Zugriff erlaubt.

## B.3.3 Speicherkontrolle
*Maßnahmen, die die unbefugte Eingabe in den Speicher sowie die unbefugte Kenntnisnahme, Veränderung oder Löschung gespeicherter Daten verhindern*

- Ausschließlich dedizierte Administratoren-Accounts sind für den Remote-Zugriff erlaubt. Zugang nur per SSH über SSH-Keys oder Administrator-Accounts der Server- Administratoren dieses Dienstes.

## B.3.4 Benutzerkontrolle

*Maßnahmen gegen die unbefugte Nutzung der Datenverarbeitungssysteme mit Hilfe von Einrichtungen zur Datenübertragung*                     |

- Ausschließlich dedizierte Administratoren-Accounts sind für den Remote-Zugriff erlaubt.                                               |

## B.3.5 Zugriffskontrolle

*Maßnahmen, die gewährleisten, dass die zur Nutzung eines Datenverarbeitungssystems Berechtigten ausschließlich auf die ihrer Zugriffsberechtigung unterliegenden Daten zugreifen können.*

- *Ggf. Berechtigungskonzept*

## B.3.6 Übermittlungskontrolle / Weitergabekontrolle

*Maßnahmen, die gewährleisten, dass überprüft und festgestellt werden kann, welche Daten zu welcher Zeit an wen übermittelt worden sind.*

- Es findet keine Übermittlung außerhalb des Radius Protokolls statt.

## B.3.7 Eingabekontrolle

*Maßnahmen, die gewährleisten, dass überprüft und festgestellt werden kann, welche Daten zu welcher Zeit von wem in Datenverarbeitungssysteme eingegeben worden sind.*

- Liegt beim Benutzer.

## B.3.8 Übermittlungs- und Transportkontrolle

*Maßnahmen, die gewährleisten, dass überprüft und festgestellt werden kann, dass bei der Übermittlung personenbezogener Daten sowie beim Transport von Datenträgern die Vertraulichkeit und Integrität der Daten geschützt werden, also weder unbefugt gelesen, kopiert, verändert oder gelöscht werden können*

-  TLS-Verschlüsselung

## B.3.9 Wiederherstellbarkeitskontrolle

*Maßnahmen, die gewährleisten, dass eingesetzte Systeme im Störungsfall wiederhergestellt werden können.*

- Die virtuellen Server befinden sich auf eigenbetriebenen den ESX-Systemen und werden von diesen durch regelmäßige Backups gesichert.
- Redundanter Betrieb der Server.
- Der Verzeichnisdienst wird in Echtzeit zwischen den Servern synchronisiert.

## B.3.10 Zuverlässigkeit

*Maßnahmen, die gewährleisten, dass alle Funktionen des Systems zur Verfügung stehen und auftretende Fehlfunktionen gemeldet werden.*

- Der Dienst ist redundant eingerichtet.
- ITC-Monitoring
- Mailing von Systemfehlern an die Administratoren.

## B.3.11 Datenintegrität

*Maßnahmen, die gewährleisten, dass gespeicherte personenbezogene Daten nicht durch Fehlfunktionen des Systems beschädigt werden können*

## B.3.12 Auftragskontrolle

*Maßnahmen, die gewährleisten, dass Daten, die im Auftrag verarbeitet werden, nur entsprechend den Weisungen des Auftraggebers verarbeitet werden können.*

- Siehe (T)OMs
  
## B.3.13 Verfügbarkeitskontrolle

*Maßnahmen, die gewährleisten, dass personenbezogene Daten gegen Zerstörung oder Verlust geschützt sind.*

- Die virtuellen Server befinden sich auf den eigenbetriebenen ESX-Systemen und werden von diesen durch regelmäßige Backups gesichert.

## B.3.14 Trennbarkeit

*Maßnahmen, die gewährleisten, dass zu unterschiedlichen Zwecken erhobene personenbezogene Daten getrennt verarbeitet werden (können).*

## B.3.15 Organisationskontrolle

*Maßnahmen, die geeignet sind, die innerbetriebliche Struktur so zu gestalten, dass sie den besonderen Anforderungen des Datenschutzes gerecht wird.*

# B.4 Bewertung der Maßnahmen im Verhältnis zum Risiko

☒ JA / NEIN

## Falls NEIN, folgende Maßnahmen könnten ein angemessenes Schutzniveau ermöglichen:

- ...

Weitere Dokumentationen zur Verarbeitungstätigkeit

*z. B.:*
- *Zu Informationspflichten*
- *Zu Verträgen mit Dienstleistern*
- *Zu Vereinbarungen zur gemeinsamen Verantwortung*
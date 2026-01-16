# Considerations on *Tape Vaulting* with TSM/SP

<!--
AIA Primarily human, Content edits (translation from german to englisch), Human-initiated, Reviewed, DeepL v1.0

# changelog
# date          version     remark
# 2026-01-16    0.1         initial text
-->

In principle, the purpose of removing the tapes is to prevent reuse, i.e., overwriting with new data.

If an attacker remains in the SP backup system for a longer period of time, they can do just that with media that is permanently available online by deleting the “volumes” and reassigning them to the scratch pool. Removing the tapes prevents this. 
Although the “ReUse” option sets a waiting period, it is only of limited help, as this would naturally be reduced by an attacker to enable overwriting.

The situation is similar with database backups. The current assignments of backed-up data and media are stored in DB2. In principle, the assignments of deleted data (whether deleted by the client or admin) are also stored there, but unfortunately only until the next “expiration run.” After that, these are also deleted—even if the data is still on tape, it is no longer accessible.
Therefore, DB2 backups should be retained until the point at which a restore can be performed; the usual three days are certainly not sufficient. Simply increasing the retention period is not helpful, as an attacker will immediately reduce it in order to let old backups expire. It makes more sense to outsource the DB backups, which also increases the “retention period” in practical terms, as in the event of a DR, the DB restore replaces the current DB2 and thus overwrites the DB2 retention settings.

Since the data on the tapes changes after each DB backup, all tapes should be set to “read-only” and removed immediately after a DB backup to ensure a consistent DR concept. Although the data itself is not deleted when tapes are “released” and remains readable in principle (e.g., by importing a DB backup from a point in time before deletion), these tapes remain in the library and are at high risk of being overwritten, resulting in the loss of the “old data.”
(As an attacker, I would make a DB2 backup of these released tapes using `BA DB T=INC VOL=<Tape-Name>`, which would make their old data unreadable.)

Bottom line:

- Increasing the DB backup retention time does not help much; it is more important to move the tapes quickly/immediately.
- Simply removing the DB backup tapes does not prevent the actual data from being overwritten; at a minimum, the COPY pool tapes should be removed from access, so removed immediately after the DB2 backup.
- The `MOVe DRMedia` command helps to remove the tapes from immediate access, but it also allows the tapes to be made available again if they are still in the tape library / library partition. Genuine removal is preferable.

Overall, mapping WORM functionality via outsourcing involves some “sneaker” activities.

In addition to the physical outsourcing of the tapes, logical outsourcing could also be considered, i.e., moving the tapes at the tape robot level to another partition that the TSM cannot access.
For IBM robots, there is additional software called “SafeGuardedTape,” but for other robots, it has to be done manually.


## German Text

Grundsätzlich soll mit dem Auslagern der Bänder eine Wiederbenutzung, also das Überschreiben mit neuen Daten verhindeert werden.

Bleibt ein Angreifer länger im SP-Backup-System kann er genau dies bei permanent online verfügabre Medien herbeiführen, indem die "Volumes" gelöscht und wieder dem Scratchpool zugewiesen werden. Ein Auslagern der Bänder verhindert dies. 
Die "ReUse"-Option setzt zwar eine Karenzzeit, ist nur bedingt hilfreich, da diese natürlich von einem Angreifer heruntergestezt würde, um das Überschreiben zu ermöglichen.

Ähnlich ist es beim Datenbank-Backup. In der DB2 sind die jeweils aktuellen Zuordnungen von gesicherten Daten und Medien abgelegt. Grundsätzlich stehen dort zwar auch die Zuordnungen gelöschter Daten (egal ob vom Client oder Admin gelöscht), aber leider nur bis zum nächsten “Expiration-Lauf”. Anschließend sind auch diese gelöscht – selbst, wenn die Daten noch auf Band stehen, sind diese nicht mehr zugreifbar.
Daher sollten DB2-Backups bis zu jenem Zeitpunkt vorhalten werden, bis zu dem ein Restore erfolgen können soll, die üblichen 3 Tage sind sicherlich nicht ausreichend. Lediglich die Vorhaltezeit zu erhöhen ist nicht hilfreich, da ein Angreifer auch diese sofort herabsetzt, um alte Backups auslaltern zu lassen. Sinnvoller ist es, die DB-Backups auszulagern, praktisch wird damit auch die “Vorhaltezeit” erhöht, da im DR-Fall das DB-Restore die aktuelle DB2 ersetzt und somit Einstellungen zur DB2-Retention überschreibt.

Da sich nach jedem DB-Backup die Datenstände auf den Tapes sich ändern, sollten für ein konsitentes DR-Konzept unmittelbar nach einem DB-Backup alle Bänder “ReadOnly” gehen und ausgelagert werden. Obwohl beim “Freigeben” von Bänder die Daten selbst nicht gelöscht werden, sie grundsätzlilch als lesbar bleiben (z.B. durch das Einspielen eines DB-Backups von einem Zeitpunkt vor dem Löschen), sind diese Bänder sofern in der Library verbleibend einem hohen Risiko ausgesetzt, dass sie überschrieben werden und damit die “alten Daten” verloren gehen.
( Als Angreifer würde ich auf diese freigegebenen Bänder ein DB2-Backup mittels `BA DB T=INC VOL=<Tape-Name>` machen, was deren alten Daten unlesbar macht. )

Quintessenz:

- Die DB-Backup-Retention-Time hochzusetzen bringt nicht viel, das schnelle / umgehende Auslagern der Bänder ist wichtiger.
- Nur die DB-Backup-Bänder auszulagern verhindert kein Überschreiben der eigentlichen Daten, mindestens die COPY-Pool-Bänder sollten unmittelbar nach dem DB2-Backup dem Zugriff entzogen, also ausgelagert werden.
- Der Befehl `MOVe DRMedia` hilft zwar, die Bänder dem unmittelbaren Zugriff zu entziehen, erlaubt aber auch die Bänder wieder verfügbar zu machen, wenn sie noch im Roboter sind. Eine echte Auslagerung ist vorzuziehen.


Insgesamt bedeutet die Abbildung einer WORM-Funktionalität über das Auslagern einige “Turnschuh”-Aktivitäten.

Neben dem physischen Auslagern der Bänder käme noch eine logische Auslagerung in Betracht, also das Verschieben der Bänder auf Ebene des Bandroboters in eine andere Partition, auf die der TSM keinen Zugriff hat.
Für IBM-Roboter gibt es Zusatzsoftware “SafeGuardedTape” für andere Roboter ist es aber Handarbeit.


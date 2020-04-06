codeunit 50100 "DB Search Functions"
{
    procedure CorrectSearchValues(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        Options: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001: TextConst ENU = 'Correct selected values?', ITA = 'Correggere i valori selezionati?';
        Text002: TextConst ENU = 'Correction completed', ITA = 'Correzione completata';
    begin
        OptionValue := Dialog.StrMenu(Options, 1, Text001);
        if OptionValue = 0 then
            exit;

        with DBSearch do begin
            SetRange(Selected, true);
            if FindFirst() then begin
                repeat
                    // Skip the correction if value is equal to current field value
                    if "Current Value" <> "Correct Value" then begin
                        RecRef.Get("Record ID");
                        FldRef := RecRef.Field("Field No.");

                        // Check if the new value is valid
                        if OptionValue = 1 then
                            Evaluate(FldRef, "Correct Value")
                        else
                            FldRef.Value("Correct Value");

                        // Apply the correction to the field value
                        if not RecRef.Modify() then begin
                            RecRef.Insert();
                        end;

                        // Saves original record in ledger entries
                        SaveInLedgerEntries(DBSearch, 'Corrected');
                    end;
                    Delete();
                until (Next = 0);

                Message(Text002);
            end;
        end;
    end;

    procedure DeleteSearchRecords(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        Options: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001: TextConst ENU = 'Delete selected records?', ITA = 'Eliminare i record selezionati?';
        Text002: TextConst ENU = 'Deletion completed', ITA = 'Eliminazione completata';
    begin
        OptionValue := Dialog.StrMenu(Options, 1, Text001);
        if OptionValue = 0 then
            exit;

        if not Confirm(Text001) then exit;
        if not Confirm(Text001) then exit;
        if not Confirm(Text001) then exit;
        if not Confirm(Text001) then exit;
        if not Confirm(Text001) then exit;

        with DBSearch do begin
            SetRange(Selected, true);
            if FindFirst() then begin
                repeat
                    RecRef.GET("Record ID");

                    // Deletes the record
                    if OptionValue = 1 then
                        RecRef.Delete(true)
                    else
                        RecRef.Delete();

                    // Saves original record in ledger entries
                    SaveInLedgerEntries(DBSearch, 'Deleted');

                    Delete();
                until (Next = 0);

                Message(Text002);
            end;
        end;
    end;

    procedure SearchValues()
    begin
        Report.RunModal(Report::"DB Search");
    end;

    procedure SaveInLedgerEntries(DBSearch: Record "DB Search"; Operation: Code[20])
    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";
        DBSearchLedgEntry2: Record "DB Search Ledger Entry";
        PK: Integer;
    begin
        DBSearchLedgEntry2.FindLast();
        with DBSearchLedgEntry do begin
            TransferFields(DBSearch);
            "Entry No." := DBSearchLedgEntry2."Entry No." + 10000;
            "Operation Description" := Operation;
            "Operation DateTime" := CurrentDateTime;
            Insert();
        end;
    end;
}
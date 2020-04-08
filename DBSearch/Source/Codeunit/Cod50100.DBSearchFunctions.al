codeunit 50100 "DB Search Functions"
{
    procedure CorrectValues(DBSearch: Record "DB Search")
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

                        OnBeforeCorrection();

                        // Modify the field with validation
                        if OptionValue = 1 then begin
                            Evaluate(FldRef, "Correct Value");
                            RecRef.Modify(true)
                        end else begin
                            // Modify the field without validation
                            FldRef.Value("Correct Value");
                            RecRef.Modify();
                        end;

                        OnAfterCorrection();

                        // Saves original record in ledger entries
                        SaveInLedgerEntries(DBSearch, DBSearchLedgEntry."Operation Type"::Modified);
                    end;

                    Delete();
                until (Next = 0);

                Message(Text002);
            end;
        end;
    end;

    procedure DeleteRecords(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        Options: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001: TextConst ENU = 'Delete selected records?', ITA = 'Eliminare i record selezionati?';
        Text002: TextConst ENU = 'Deletion completed', ITA = 'Eliminazione completata';
        Text003: TextConst ENU = 'Are you VERY sure you want to proceed with the deletion of selected records? The operation cannot be undone. Make a backup of the database before continuing.',
                           ITA = 'Sei veramente sicuro di voler eliminare i record selezionati? L''operazione è irreversibile. Esegui un backup del database prima di continuare.';
    begin
        OptionValue := Dialog.StrMenu(Options, 2, Text001);
        if OptionValue = 0 then
            exit;

        if not Confirm(Text001) then exit;
        if not Confirm(Text001) then exit;
        if not Confirm(Text001) then exit;
        if not Confirm(Text003) then exit;
        if not Confirm(Text003) then exit;
        if not Confirm(Text003) then exit;

        with DBSearch do begin
            SetRange(Selected, true);
            if FindFirst() then begin
                repeat
                    RecRef.GET("Record ID");

                    OnBeforeDelete();

                    // Delete the record with validation
                    if OptionValue = 1 then
                        RecRef.Delete(true)
                    else
                        // Delete the record without validation
                        RecRef.Delete();

                    OnAfterDelete();

                    // Save original record in ledger entries
                    SaveInLedgerEntries(DBSearch, DBSearchLedgEntry."Operation Type"::Deleted);

                    Delete();
                until (Next = 0);

                Message(Text002);
            end;
        end;
    end;

    procedure RestoreValue(DBSearchLedgEntry: Record "DB Search Ledger Entry")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        Options: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001: TextConst ENU = 'Restore selected value?', ITA = 'Ripristinare il valore selezionato?';
        Text002: TextConst ENU = 'Restore completed', ITA = 'Ripristino completato';
    begin
        OptionValue := Dialog.StrMenu(Options, 1, Text001);
        if OptionValue = 0 then
            exit;

        with DBSearchLedgEntry do begin
            IF "Operation Type" = "Operation Type"::Modified then begin
                RecRef.GET("Record ID");
                FldRef := RecRef.Field("Field No.");

                OnBeforeRestoreField();

                // Insert the original field value with validation
                if OptionValue = 1 then begin
                    Evaluate(FldRef, "Current Value");
                    RecRef.Modify(TRUE)
                end else begin
                    // Insert the original field value without validation
                    FldRef.Value("Current Value");
                    RecRef.Modify();
                end;

                OnAfterRestoreField();

                // Update original record in ledger entries
                "Operation Type" := "Operation Type"::Restored;
                "Operation DateTime" := CURRENTDATETIME;
                Modify();

                Message(Text002);
            end;
        end;
    end;

    procedure SearchValues()
    begin
        Report.RunModal(Report::"DB Search");

        OnAfterSearch();
    end;

    procedure SaveInLedgerEntries(DBSearch: Record "DB Search"; OptionType: Option)
    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";
        DBSearchLedgEntry2: Record "DB Search Ledger Entry";
        PK: Integer;
        NextEntryNo: Integer;
    begin
        if DBSearchLedgEntry2.FindLast() then
            NextEntryNo := DBSearchLedgEntry2."Entry No." + 10000
        else
            NextEntryNo := 10000;

        with DBSearchLedgEntry do begin
            TransferFields(DBSearch);
            "Entry No." := NextEntryNo;
            "Operation Type" := OptionType;
            "Operation DateTime" := CurrentDateTime;
            Insert();
        end;
    end;

    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";


    [IntegrationEvent(false, false)]
    local procedure OnBeforeCorrection()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCorrection()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDelete()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDelete()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRestoreField()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRestoreField()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSearch()
    begin
    end;
}
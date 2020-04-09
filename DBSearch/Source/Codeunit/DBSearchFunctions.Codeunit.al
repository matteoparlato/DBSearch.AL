codeunit 50100 "DB Search Functions"
{
    procedure CorrectValues(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        OptionsQst: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001Txt: TextConst ENU = 'Correct selected values?', ITA = 'Correggere i valori selezionati?';
        Text002Txt: TextConst ENU = 'Correction completed', ITA = 'Correzione completata';
    begin
        OptionValue := Dialog.StrMenu(OptionsQst, 1, Text001Txt);
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
                until (Next() = 0);

                Message(Text002Txt);
            end;
        end;
    end;

    procedure DeleteRecords(DBSearch: Record "DB Search")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        OptionsQst: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001Txt: TextConst ENU = 'Delete selected records?', ITA = 'Eliminare i record selezionati?';
        Text002Txt: TextConst ENU = 'Deletion completed', ITA = 'Eliminazione completata';
        Text003Txt: TextConst ENU = 'Are you VERY sure you want to proceed with the deletion of selected records? The operation cannot be undone. Make a backup of the database before continuing.', ITA = 'Sei veramente sicuro di voler eliminare i record selezionati? L''operazione è irreversibile. Esegui un backup del database prima di continuare.';
    begin
        OptionValue := Dialog.StrMenu(OptionsQst, 2, Text001Txt);
        if OptionValue = 0 then
            exit;

        if not Confirm(Text001Txt) then exit;
        if not Confirm(Text001Txt) then exit;
        if not Confirm(Text001Txt) then exit;
        if not Confirm(Text003Txt) then exit;
        if not Confirm(Text003Txt) then exit;
        if not Confirm(Text003Txt) then exit;

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
                until (Next() = 0);

                Message(Text002Txt);
            end;
        end;
    end;

    procedure RestoreValue(DBSearchLedgEntry: Record "DB Search Ledger Entry")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionValue: Integer;
        OptionsQst: TextConst ENU = 'With validation,Without validation', ITA = 'Con validazione,Senza validazione';
        Text001Txt: TextConst ENU = 'Restore selected value?', ITA = 'Ripristinare il valore selezionato?';
        Text002Txt: TextConst ENU = 'Restore completed', ITA = 'Ripristino completato';
        Text003Txt: TextConst ENU = 'The value you are trying to restore has changed since you applied the correction. Continue?\\Current value: %1\Correction value: %2\Value to restore: %3';
    begin
        OptionValue := Dialog.StrMenu(OptionsQst, 1, Text001Txt);
        if OptionValue = 0 then
            exit;

        with DBSearchLedgEntry do
            IF "Operation Type" = "Operation Type"::Modified then begin
                RecRef.GET("Record ID");
                FldRef := RecRef.Field("Field No.");

                OnBeforeRestoreField();

                // Check if value has changed since the correction
                if Format(FldRef.Value) <> "Correct Value" then
                    if not Confirm(StrSubstNo(Text003Txt, FldRef.Value, "Correct Value", "Current Value")) then
                        exit;

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

                Message(Text002Txt);
            end;
    end;

    procedure SearchValues()
    begin
        Report.RunModal(Report::"DB Search");

        OnAfterSearch();
    end;

    procedure ShowRecord(RecId: RecordId)
    var
        RecRef: RecordRef;
        RecVar: Variant;
    begin
        RecRef := RecId.GetRecord();
        RecVar := RecRef;
        Page.Run(0, RecVar);
    end;

    local procedure SaveInLedgerEntries(DBSearch: Record "DB Search"; OptionType: Option)
    var
        DBSearchLedgEntry: Record "DB Search Ledger Entry";
        NextEntryNo: Integer;
    begin
        with DBSearchLedgEntry do begin
            if FindLast() then
                NextEntryNo := DBSearchLedgEntry."Entry No." + 10000
            else
                NextEntryNo := 10000;

            Reset();
            TransferFields(DBSearch);
            "Entry No." := NextEntryNo;
            "Operation Type" := OptionType;
            Insert(true);
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